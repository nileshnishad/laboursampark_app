import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../../core/app_state.dart';
import '../../core/services/permission_service.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// Views
import 'views/all_jobs_view.dart';
import 'views/contractor_list_view.dart';
import 'views/dashboard_home_view.dart';
import 'views/edit_profile_screen.dart';
import 'views/history_view.dart';
import 'views/id_card_screen.dart';
import 'views/labour_list_view.dart';
import 'views/my_jobs_view.dart';
import 'views/profile_view.dart';
import '../../l10n/app_localizations.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _subscriptionActive = false;
  bool _subscriptionStatusLoaded = false;
  bool _profileLoading = true;
  String? _profileError;
  Map<String, dynamic>? _subscriptionPlan;
  bool _subscriptionPlanLoading = false;
  StreamSubscription<Uri>? _linkSub;
  bool _paymentPending =
      false; // true while waiting for user to return from browser

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileStatus();
    _initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PermissionService.requestPostLoginPermissionsIfNeeded(context);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _paymentPending) {
      _paymentPending = false;
      _pollAfterPayment();
    }
  }

  Future<void> _pollAfterPayment() async {
    if (!mounted) return;

    // Wait briefly — UPI apps can cause a spurious resume before payment
    // is actually complete. 5 seconds gives the backend time to process.
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context).verifyingPayment),
          ],
        ),
        duration: const Duration(seconds: 45),
      ),
    );
    bool activated = false;
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 4));
      await _loadProfileStatus();
      if (_subscriptionActive) {
        activated = true;
        break;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activated
              ? AppLocalizations.of(context).subscriptionActivated
              : AppLocalizations.of(context).paymentReceivedInfo,
        ),
        backgroundColor: activated
            ? const Color(0xFF059669)
            : const Color(0xFFF59E0B),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _initDeepLinks() {
    _linkSub = AppLinks().uriLinkStream.listen((uri) {
      if (!mounted) return;
      if (uri.scheme == 'laboursampark' && uri.host == 'payment') {
        final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
        // Dismiss any open dialogs (e.g. the waiting-for-payment dialog)
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        if (path == 'success') {
          _loadProfileStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).paymentSuccessful),
              backgroundColor: const Color(0xFF059669),
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (path == 'failure') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).paymentFailed),
              backgroundColor: const Color(0xFFDC2626),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileStatus() async {
    setState(() {
      _profileLoading = true;
      _profileError = null;
      _subscriptionStatusLoaded = false;
    });

    final userController = Get.find<UserController>();
    final token =
        userController.token.value ?? await AuthService.getAuthToken();

    if (token == null || token.isEmpty) {
      setState(() {
        _profileLoading = false;
        _profileError = 'Session not found. Please login again.';
        _subscriptionActive = false;
        _subscriptionStatusLoaded = true;
      });
      return;
    }

    final response = await ApiService.fetchProfile(token);
    if (!mounted) return;

    if (response['success'] == true &&
        response['data'] is Map<String, dynamic>) {
      final profile = response['data'] as Map<String, dynamic>;
      final userType = (profile['userType'] ?? '').toString();
      userController.setUser(profile, token);

      setState(() {
        _subscriptionActive = (profile['display'] as bool?) ?? false;
        // Admin users never need to subscribe
        if (userType.toLowerCase() == 'admin') _subscriptionActive = true;
        _profileLoading = false;
        _subscriptionStatusLoaded = true;
      });

      // Load subscription plan (skip for admin)
      if (userType.toLowerCase() != 'admin') {
        _loadSubscriptionPlan(userType, token);
      }
    } else {
      setState(() {
        _profileLoading = false;
        _profileError = (response['message'] ?? 'Could not load profile')
            .toString();
        _subscriptionActive = false;
        _subscriptionStatusLoaded = true;
      });
    }
  }

  Future<void> _loadSubscriptionPlan(String userType, String token) async {
    if (_subscriptionPlanLoading) return;
    setState(() => _subscriptionPlanLoading = true);
    final response = await ApiService.fetchSubscriptionPlan(userType, token);
    if (!mounted) return;

    setState(() {
      _subscriptionPlanLoading = false;
      if (response['success'] == true &&
          response['data'] is Map<String, dynamic>) {
        _subscriptionPlan = response['data'] as Map<String, dynamic>;
      }
    });
  }

  List<BottomNavigationBarItem> _getNavItems(
    BuildContext context,
    String userType,
  ) {
    final loc = AppLocalizations.of(context);
    switch (userType.toLowerCase()) {
      case 'labour':
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            label: loc.jobs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.engineering_outlined),
            label: loc.contractors,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: loc.history,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: loc.profile,
          ),
        ];
      case 'sub_contractor':
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.post_add_rounded),
            label: loc.myJobs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            label: loc.jobs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups_outlined),
            label: loc.labours,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: loc.history,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: loc.profile,
          ),
        ];
      case 'contractor':
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.post_add_rounded),
            label: loc.myJobs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups_outlined),
            label: loc.labours,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.engineering_outlined),
            label: loc.contractors,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: loc.history,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: loc.profile,
          ),
        ];
      default:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            label: loc.jobs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: loc.history,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: loc.profile,
          ),
        ];
    }
  }

  // Stable internal keys for tabs (do NOT localize these). These keys
  // correspond positionally to the items returned by `_getNavItems`.
  List<String> _getNavKeys(String userType) {
    switch (userType.toLowerCase()) {
      case 'labour':
        return ['jobs', 'contractors', 'history', 'profile'];
      case 'sub_contractor':
        return ['my_jobs', 'jobs', 'labours', 'history', 'profile'];
      case 'contractor':
        return ['my_jobs', 'labours', 'contractors', 'history', 'profile'];
      default:
        return ['jobs', 'history', 'profile'];
    }
  }

  String _roleLabel(String userType) {
    switch (userType.toLowerCase()) {
      case 'labour':
        return 'Labour Worker';
      case 'sub_contractor':
        return 'Sub Contractor';
      case 'contractor':
        return 'Contractor';
      default:
        return 'User';
    }
  }

  Future<void> _logout() async {
    final userController = Get.find<UserController>();
    userController.clearUser();
    await AuthService.clearSession();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _openEditProfile(
    BuildContext context,
    Map<String, dynamic>? profileData,
    String userType,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          profileData: profileData,
          userType: userType,
          onSaved: (_) {
            _loadProfileStatus();
          },
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final appState = context.read<AppState>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final mq = MediaQuery.of(sheetContext);
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(sheetContext).colorScheme.outline,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text(AppLocalizations.of(sheetContext).settings),
                    ),
                    ListTile(
                      leading: const Icon(Icons.light_mode_outlined),
                      title: Text(AppLocalizations.of(sheetContext).lightMode),
                      onTap: () {
                        appState.setThemeMode(ThemeMode.light);
                        Navigator.pop(sheetContext);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: Text(AppLocalizations.of(sheetContext).darkMode),
                      onTap: () {
                        appState.setThemeMode(ThemeMode.dark);
                        Navigator.pop(sheetContext);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_android_outlined),
                      title: Text(
                        AppLocalizations.of(sheetContext).systemDefault,
                      ),
                      onTap: () {
                        appState.setThemeMode(ThemeMode.system);
                        Navigator.pop(sheetContext);
                      },
                    ),
                    const Divider(height: 12),
                    // Language selection
                    ListTile(
                      leading: const Icon(Icons.translate_outlined),
                      title: Text(AppLocalizations.of(sheetContext).language),
                      subtitle: Text(
                        appState.locale?.languageCode == null
                            ? AppLocalizations.of(sheetContext).systemDefault
                            : appState.locale!.languageCode.toUpperCase(),
                      ),
                      onTap: () {
                        // show a focused dialog for language selection
                        showDialog<void>(
                          context: sheetContext,
                          builder: (dialogCtx) {
                            final loc = AppLocalizations.of(dialogCtx);
                            return AlertDialog(
                              title: Text(loc.selectLanguage),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<String>(
                                    value: 'en',
                                    groupValue:
                                        appState.locale?.languageCode ?? 'en',
                                    title: Text(loc.english),
                                    onChanged: (v) {
                                      appState.setLocale(const Locale('en'));
                                      Navigator.of(dialogCtx).pop();
                                      Navigator.of(sheetContext).pop();
                                    },
                                  ),
                                  RadioListTile<String>(
                                    value: 'hi',
                                    groupValue:
                                        appState.locale?.languageCode ?? 'en',
                                    title: Text(loc.hindi),
                                    onChanged: (v) {
                                      appState.setLocale(const Locale('hi'));
                                      Navigator.of(dialogCtx).pop();
                                      Navigator.of(sheetContext).pop();
                                    },
                                  ),
                                  RadioListTile<String>(
                                    value: 'mr',
                                    groupValue:
                                        appState.locale?.languageCode ?? 'en',
                                    title: Text(loc.marathi),
                                    onChanged: (v) {
                                      appState.setLocale(const Locale('mr'));
                                      Navigator.of(dialogCtx).pop();
                                      Navigator.of(sheetContext).pop();
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogCtx).pop(),
                                  child: Text(
                                    AppLocalizations.of(dialogCtx).cancel,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(AppLocalizations.of(sheetContext).english),
                      trailing: appState.locale?.languageCode == 'en'
                          ? const Icon(Icons.check, color: Color(0xFF059669))
                          : null,
                      onTap: () {
                        appState.setLocale(const Locale('en'));
                        Navigator.pop(sheetContext);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(AppLocalizations.of(sheetContext).hindi),
                      trailing: appState.locale?.languageCode == 'hi'
                          ? const Icon(Icons.check, color: Color(0xFF059669))
                          : null,
                      onTap: () {
                        appState.setLocale(const Locale('hi'));
                        Navigator.pop(sheetContext);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(AppLocalizations.of(sheetContext).marathi),
                      trailing: appState.locale?.languageCode == 'mr'
                          ? const Icon(Icons.check, color: Color(0xFF059669))
                          : null,
                      onTap: () {
                        appState.setLocale(const Locale('mr'));
                        Navigator.pop(sheetContext);
                      },
                    ),
                    const Divider(height: 12),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(AppLocalizations.of(sheetContext).logout),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _logout();
                      },
                    ),
                    const SizedBox(height: 8),
                  ], // children
                ), // Column
              ), // ConstrainedBox
            ), // Padding
          ), // SingleChildScrollView
        ); // SafeArea
      },
    );
  }

  Widget _buildCurrentTabBody({
    required BuildContext context,
    required List<BottomNavigationBarItem> navItems,
    required String fullName,
    required String userType,
    required Map<String, dynamic>? profileData,
  }) {
    // Use stable non-localized keys to decide which tab to show.
    final tabKeys = _getNavKeys(userType);
    final selectedKey = (tabKeys.length > _selectedIndex)
        ? tabKeys[_selectedIndex]
        : (tabKeys.isNotEmpty ? tabKeys.first : 'jobs');
    final userController = Get.find<UserController>();
    final token = userController.token.value ?? '';

    switch (selectedKey) {
      case 'jobs':
        return AllJobsView(
          token: token,
          userType: userType,
          subscriptionActive: _subscriptionActive,
        );
      case 'labours':
        return LabourListView(canViewSensitiveData: _subscriptionActive);
      case 'contractors':
        return ContractorListView(canViewSensitiveData: _subscriptionActive);
      case 'my_jobs':
        return MyJobsView(token: token, userType: userType);
      case 'history':
        return HistoryView(token: token, userType: userType);
      case 'profile':
        return ProfileView(
          fullName: fullName,
          userType: userType,
          profileData: profileData,
          subscriptionActive: _subscriptionActive,
          profileLoading: _profileLoading,
          profileError: _profileError,
          subscriptionPlan: _subscriptionPlan,
          onRetry: _loadProfileStatus,
          onShowSubscription: (plan) => _showSubscriptionDetails(context, plan),
          onSettings: () => _showSettingsSheet(context),
          onLogout: _logout,
          onUpdateProfile: () =>
              _openEditProfile(context, profileData, userType),
        );
      default:
        return DashboardHomeView(
          fullName: fullName,
          userType: userType,
          subscriptionActive: _subscriptionActive,
          subscriptionPlan: _subscriptionPlan,
          onTabSwitch: (label) {
            final navItems = _getNavItems(context, userType);
            final idx = navItems.indexWhere(
              (item) => (item.label ?? '').toLowerCase() == label,
            );
            if (idx != -1) _onItemTapped(idx);
          },
          onShowSubscription: (plan) => _showSubscriptionDetails(context, plan),
        );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showSubscriptionDetails(
    BuildContext context,
    Map<String, dynamic>? plan,
  ) async {
    final userController = Get.find<UserController>();

    // If plan not cached yet, fetch it with a loading dialog
    if (plan == null) {
      final token =
          userController.token.value ?? await AuthService.getAuthToken();
      final userType = (userController.user.value?['userType'] ?? 'labour')
          .toString();

      if (!context.mounted) return;

      // Show loading dialog while we fetch
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Loading plan details...'),
            ],
          ),
        ),
      );

      final response = await ApiService.fetchSubscriptionPlan(
        userType,
        token ?? '',
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

      if (response['success'] == true &&
          response['data'] is Map<String, dynamic>) {
        plan = response['data'] as Map<String, dynamic>;
        setState(() => _subscriptionPlan = plan);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message']?.toString() ??
                  'Could not load subscription plan.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final resolvedPlan = plan;
    final theme = Theme.of(context);
    final price = (resolvedPlan['price'] ?? 0).toString();
    final currency = (resolvedPlan['currency'] ?? 'INR').toString();
    final durationDays = (resolvedPlan['durationDays'] ?? 0).toString();
    final pricePerDay =
        (resolvedPlan['pricePerDay'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final features =
        (resolvedPlan['features'] as List<dynamic>?)?.cast<String>() ?? [];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppLocalizations.of(dialogContext).subscribeNow,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currency $price',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'for $durationDays days (₹$pricePerDay/day)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'What\'s Included:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(feature, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _initiatePayment(context, resolvedPlan);
            },
            child: Text(AppLocalizations.of(dialogContext).proceedToPayment),
          ),
        ],
      ),
    );
  }

  Future<void> _initiatePayment(
    BuildContext context,
    Map<String, dynamic> plan,
  ) async {
    final userController = Get.find<UserController>();
    final token =
        userController.token.value ?? await AuthService.getAuthToken();
    if (token == null || token.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again.')),
        );
      }
      return;
    }

    final amount = (plan['price'] as num?)?.toDouble() ?? 99.0;
    final user = userController.user.value ?? {};
    final userType = (user['userType'] ?? 'labour').toString();
    final name = (user['fullName'] ?? user['name'] ?? '').toString().trim();
    final email = (user['email'] ?? '').toString().trim();
    final phone = (user['mobile'] ?? user['phone'] ?? '').toString().trim();
    final productInfo = switch (userType.toLowerCase()) {
      'labour' => 'Labour profile visibility – LabourSampark',
      'sub_contractor' => 'Sub-Contractor profile visibility – LabourSampark',
      'contractor' => 'Contractor profile visibility – LabourSampark',
      _ => 'Profile visibility – LabourSampark',
    };
    final description =
        '${plan['durationDays'] ?? 90}-day profile visibility subscription for $userType on LabourSampark';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).creatingPayment),
            ],
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }

    final result = await ApiService.createPaymentLink(
      amount: amount,
      productInfo: productInfo,
      description: description,
      token: token,
      name: name,
      email: email,
      phone: phone,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                AppLocalizations.of(context).couldNotCreatePaymentLink,
          ),
        ),
      );
      return;
    }

    final paymentLink = result['data']?['paymentLink']?.toString() ?? '';
    if (paymentLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidPaymentLink),
        ),
      );
      return;
    }

    // Open in Chrome — handles UPI intents, bank OTPs, redirects natively.
    // When user completes payment and returns to app, didChangeAppLifecycleState
    // fires and _pollAfterPayment() automatically verifies subscription.
    final uri = Uri.parse(paymentLink);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotOpenBrowser),
        ),
      );
      return;
    }

    // Mark payment as pending — polling starts when user returns to app
    _paymentPending = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).completePaymentMessage),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final theme = Theme.of(context);
    return Obx(() {
      final user = userController.user.value;
      final fullName = (user?['fullName'] ?? '').toString();
      final userType = (user?['userType'] ?? '').toString();
      final navItems = _getNavItems(context, userType);

      if (_selectedIndex >= navItems.length) {
        _selectedIndex = 0;
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) {
            // Minimize app — don't close it
            const MethodChannel(
              'com.laboursampark.app/navigation',
            ).invokeMethod('moveToBackground');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1F2937),
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: 56,
            titleSpacing: 10,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            title: Row(
              children: [
                Builder(
                  builder: (context) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final photoUrl = (user?['profilePhotoUrl'] ?? '')
                        .toString()
                        .trim();
                    final hasPhoto = photoUrl.isNotEmpty;
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(hasPhoto ? 18 : 10),
                        border: Border.all(
                          color: hasPhoto
                              ? const Color(0xFF2563EB).withValues(alpha: 0.35)
                              : const Color(0xFFE5E7EB),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(hasPhoto ? 18 : 9),
                        child: hasPhoto
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  isDark
                                      ? 'assets/images/app_logo_dark.png'
                                      : 'assets/images/app_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                isDark
                                    ? 'assets/images/app_logo_dark.png'
                                    : 'assets/images/app_logo.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Welcome' : fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: _subscriptionActive
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF8E1),
                          border: Border.all(
                            color: _subscriptionActive
                                ? const Color(0xFF81C784)
                                : const Color(0xFFFFCC80),
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_roleLabel(userType)} • ${_subscriptionActive ? 'Visible' : 'Hidden'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: _subscriptionActive
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFB45309),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // ID Card button
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF6FF),
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(32, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    icon: const Icon(Icons.badge_rounded, size: 16),
                    tooltip: AppLocalizations.of(context).myIdCard,
                    onPressed: () {
                      final u = Get.find<UserController>().user.value;
                      IdCardScreen.show(
                        context,
                        u,
                        (u?['userType'] ?? '').toString(),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: PopupMenuButton<String>(
                    tooltip: AppLocalizations.of(context).settings,
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) async {
                      final appState = context.read<AppState>();
                      if (value == 'settings') {
                        _showSettingsSheet(context);
                      } else if (value == 'language') {
                        // show language dialog
                        showDialog<void>(
                          context: context,
                          builder: (dialogCtx) {
                            final loc = AppLocalizations.of(dialogCtx);
                            return AlertDialog(
                              title: Text(loc.selectLanguage),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<String>(
                                    value: 'en',
                                    groupValue:
                                        appState.locale?.languageCode ?? 'en',
                                    title: Text(loc.english),
                                    onChanged: (v) {
                                      appState.setLocale(const Locale('en'));
                                      Navigator.of(dialogCtx).pop();
                                    },
                                  ),
                                  RadioListTile<String>(
                                    value: 'hi',
                                    groupValue:
                                        appState.locale?.languageCode ?? 'en',
                                    title: Text(loc.hindi),
                                    onChanged: (v) {
                                      appState.setLocale(const Locale('hi'));
                                      Navigator.of(dialogCtx).pop();
                                    },
                                  ),
                                  RadioListTile<String>(
                                    value: 'mr',
                                    groupValue:
                                        appState.locale?.languageCode ?? 'en',
                                    title: Text(loc.marathi),
                                    onChanged: (v) {
                                      appState.setLocale(const Locale('mr'));
                                      Navigator.of(dialogCtx).pop();
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogCtx).pop(),
                                  child: Text(
                                    AppLocalizations.of(dialogCtx).cancel,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (value == 'logout') {
                        _logout();
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'settings',
                        child: Text(AppLocalizations.of(ctx).settings),
                      ),
                      PopupMenuItem(
                        value: 'language',
                        child: Text(AppLocalizations.of(ctx).language),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text(AppLocalizations.of(ctx).logout),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Container(height: 2, color: const Color(0xFFE5E7EB)),
            ),
          ),
          body: Column(
            children: [
              if (_subscriptionStatusLoaded && !_subscriptionActive)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFC107).withValues(alpha: 0.15),
                        const Color(0xFFFF9800).withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFF57F17).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: const Color(0xFFF57F17),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).profileHidden,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF57F17),
                              ),
                            ),
                            Text(
                              'Pay your subscription to get full access and visibility!',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () => _showSubscriptionDetails(
                          context,
                          _subscriptionPlan,
                        ),
                        child: Text(AppLocalizations.of(context).goNow),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _buildCurrentTabBody(
                  context: context,
                  navItems: navItems,
                  fullName: fullName,
                  userType: userType,
                  profileData: user,
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: navItems,
            currentIndex: _selectedIndex,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            onTap: _onItemTapped,
          ),
        ), // Scaffold
      ); // PopScope
    });
  }
}
