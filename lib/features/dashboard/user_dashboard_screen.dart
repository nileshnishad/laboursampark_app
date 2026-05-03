import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../../core/app_state.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'package:get/get.dart';

// Views
import 'views/all_jobs_view.dart';
import 'views/contractor_list_view.dart';
import 'views/dashboard_home_view.dart';
import 'views/history_view.dart';
import 'views/labour_list_view.dart';
import 'views/my_jobs_view.dart';
import 'views/profile_view.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  bool _subscriptionActive = false;
  bool _subscriptionStatusLoaded = false;
  bool _profileLoading = true;
  String? _profileError;
  Map<String, dynamic>? _subscriptionPlan;

  @override
  void initState() {
    super.initState();
    _loadProfileStatus();
  }

  Future<void> _loadProfileStatus() async {
    setState(() {
      _profileLoading = true;
      _profileError = null;
      _subscriptionStatusLoaded = false;
    });

    final userController = Get.find<UserController>();
    final token = userController.token.value ?? await AuthService.getAuthToken();

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

    if (response['success'] == true && response['data'] is Map<String, dynamic>) {
      final profile = response['data'] as Map<String, dynamic>;
      final userType = (profile['userType'] ?? '').toString();
      userController.setUser(profile, token);

      setState(() {
        _subscriptionActive = (profile['display'] as bool?) ?? false;
        _profileLoading = false;
        _subscriptionStatusLoaded = true;
      });

      // Load subscription plan
      _loadSubscriptionPlan(userType, token);
    } else {
      setState(() {
        _profileLoading = false;
        _profileError = (response['message'] ?? 'Could not load profile').toString();
        _subscriptionActive = false;
        _subscriptionStatusLoaded = true;
      });
    }
  }

  Future<void> _loadSubscriptionPlan(String userType, String token) async {
    final response = await ApiService.fetchSubscriptionPlan(userType, token);
    if (!mounted) return;

    if (response['success'] == true && response['data'] is Map<String, dynamic>) {
      setState(() {
        _subscriptionPlan = response['data'] as Map<String, dynamic>;
      });
    }
  }

  List<BottomNavigationBarItem> _getNavItems(String userType) {
    switch (userType.toLowerCase()) {
      case 'labour':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          const BottomNavigationBarItem(icon: Icon(Icons.engineering_outlined), label: 'Contractors'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
      case 'sub_contractor':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.post_add_rounded), label: 'My Jobs'),
          const BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          const BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Labours'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
      case 'contractor':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.post_add_rounded), label: 'My Jobs'),
          const BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Labours'),
          const BottomNavigationBarItem(icon: Icon(Icons.engineering_outlined), label: 'Contractors'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
      default:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final appState = context.read<AppState>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
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
              const ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings'),
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_outlined),
                title: const Text('Light mode'),
                onTap: () {
                  appState.setThemeMode(ThemeMode.light);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                onTap: () {
                  appState.setThemeMode(ThemeMode.dark);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android_outlined),
                title: const Text('System default'),
                onTap: () {
                  appState.setThemeMode(ThemeMode.system);
                  Navigator.pop(sheetContext);
                },
              ),
              const Divider(height: 12),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _logout();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
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
    final selectedLabel = (navItems[_selectedIndex].label ?? '').toLowerCase();
    final userController = Get.find<UserController>();
    final token = userController.token.value ?? '';

    switch (selectedLabel) {
      case 'jobs':
        return AllJobsView(token: token, userType: userType);
      case 'labours':
        return LabourListView(canViewSensitiveData: _subscriptionActive);
      case 'contractors':
        return ContractorListView(canViewSensitiveData: _subscriptionActive);
      case 'my jobs':
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
        );
      default:
        return DashboardHomeView(
          fullName: fullName,
          userType: userType,
          subscriptionActive: _subscriptionActive,
          subscriptionPlan: _subscriptionPlan,
          onTabSwitch: (label) {
            final navItems = _getNavItems(userType);
            final idx = navItems.indexWhere(
                (item) => (item.label ?? '').toLowerCase() == label);
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

  void _showSubscriptionDetails(BuildContext context, Map<String, dynamic>? plan) {
    if (plan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading subscription details...')),
      );
      return;
    }

    final theme = Theme.of(context);
    final price = (plan['price'] ?? 0).toString();
    final currency = (plan['currency'] ?? 'INR').toString();
    final durationDays = (plan['durationDays'] ?? 0).toString();
    final pricePerDay = (plan['pricePerDay'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final features = (plan['features'] as List<dynamic>?)?.cast<String>() ?? [];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Subscribe Now',
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
              ...features.map((feature) => Padding(
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
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
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
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Proceeding to payment for ₹$price...',
                  ),
                ),
              );
              // TODO: Connect to actual payment gateway
            },
            child: const Text('Proceed to Payment'),
          ),
        ],
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
      final navItems = _getNavItems(userType);

      if (_selectedIndex >= navItems.length) {
        _selectedIndex = 0;
      }

      final initials = fullName.trim().isEmpty
          ? 'U'
          : fullName
              .trim()
              .split(' ')
              .where((word) => word.isNotEmpty)
              .take(2)
              .map((word) => word[0].toUpperCase())
              .join();

      return Scaffold(
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
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
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
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFF9FAFB),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      fontSize: 12,
                    ),
                  ),
                ),
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
            Padding(
                padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF9FAFB),
                    foregroundColor: const Color(0xFF374151),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(32, 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                    icon: const Icon(Icons.tune_rounded, size: 16),
                  tooltip: 'Settings',
                  onPressed: () => _showSettingsSheet(context),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(
              height: 2,
              color: const Color(0xFFE5E7EB),
            ),
          ),
        ),
        body: Column(
          children: [
            if (_subscriptionStatusLoaded && !_subscriptionActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            'Your profile is hidden',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF57F17),
                            ),
                          ),
                          Text(
                            'Pay your subscription to get full access and visibility!',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _showSubscriptionDetails(context, _subscriptionPlan),
                      child: const Text('Go Now'),
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
          unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: _onItemTapped,
        ),
      );
    });
  }
}

