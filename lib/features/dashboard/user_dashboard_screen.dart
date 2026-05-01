import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../../core/app_state.dart';
import '../../services/api_service.dart';
import '../../common/widgets/app_state_message.dart';
import '../auth/login_screen.dart';
import 'package:get/get.dart';

// Models
import 'models/marketplace_user.dart';

// Widgets
import 'widgets/profile_field.dart';
import 'widgets/status_chip.dart';
import 'widgets/skills_section.dart';
import 'widgets/verification_section.dart';
import 'widgets/contractor_visiting_card.dart';
import 'widgets/labour_id_card.dart';

// Utils
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
          const BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          const BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Labours'),
          const BottomNavigationBarItem(icon: Icon(Icons.engineering_outlined), label: 'Contractors'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
      case 'contractor':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
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

  List<_QuickAction> _quickActions(String userType) {
    switch (userType.toLowerCase()) {
      case 'labour':
        return const [
          _QuickAction(icon: Icons.work_outline, title: 'Find Work', subtitle: 'Browse jobs'),
          _QuickAction(icon: Icons.people_outline, title: 'Contractors', subtitle: 'Trusted people'),
          _QuickAction(icon: Icons.history, title: 'History', subtitle: 'Past activity'),
        ];
      case 'sub_contractor':
        return const [
          _QuickAction(icon: Icons.add_box_outlined, title: 'Create Job', subtitle: 'Post quickly'),
          _QuickAction(icon: Icons.groups_outlined, title: 'Labours', subtitle: 'Manage team'),
          _QuickAction(icon: Icons.history, title: 'History', subtitle: 'Track status'),
        ];
      case 'contractor':
        return const [
          _QuickAction(icon: Icons.add_box_outlined, title: 'Create Job', subtitle: 'Post requirement'),
          _QuickAction(icon: Icons.people_outline, title: 'Contractors', subtitle: 'Partner network'),
          _QuickAction(icon: Icons.groups_outlined, title: 'Labours', subtitle: 'Find workers'),
        ];
      default:
        return const [
          _QuickAction(icon: Icons.home_outlined, title: 'Home', subtitle: 'Overview'),
          _QuickAction(icon: Icons.person_outline, title: 'Profile', subtitle: 'Your details'),
        ];
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

  Widget _buildJobsView({
    required BuildContext context,
    required String fullName,
    required String userType,
    required bool subscriptionActive,
  }) {
    final theme = Theme.of(context);
    final actions = _quickActions(userType);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${fullName.isEmpty ? 'User' : fullName.split(' ').first}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Role: ${_roleLabel(userType)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Manage your daily work and opportunities',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        if (!subscriptionActive) const SizedBox(height: 12),
        Text(
          'Job Actions',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...actions.map(
          (action) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(action.icon, color: theme.colorScheme.primary),
              ),
              title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(action.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      subscriptionActive
                          ? '${action.title} coming soon'
                          : 'Subscription required to apply jobs and create job posts.',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.support_agent, color: theme.colorScheme.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Support: +91 9172272305',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionView({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(icon, size: 30, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView({
    required BuildContext context,
    required String fullName,
    required String userType,
    required Map<String, dynamic>? profileData,
    required bool subscriptionActive,
    required bool profileLoading,
    required String? profileError,
  }) {
    final theme = Theme.of(context);
    final profilePhotoUrl =
        (profileData?['profilePhotoUrl'] ?? '').toString();
    final companyLogoUrl =
        (profileData?['companyLogoUrl'] ?? '').toString();
    final about = (profileData?['bio'] ?? profileData?['about'] ?? '')
        .toString();
    final age = (profileData?['age'] ?? '').toString();
    final experience = (profileData?['experience'] ??
            profileData?['experienceRange'] ??
            'N/A')
        .toString();
    final email = (profileData?['email'] ?? '').toString();
    final mobile = (profileData?['mobile'] ?? '').toString();
    final location = profileData?['location']
        as Map<String, dynamic>?;
    final city = (profileData?['city'] ?? location?['city'] ?? '').toString();
    final state = (profileData?['state'] ?? location?['state'] ?? '').toString();
    final address = (location?['address'] ?? '').toString();
    final createdAt = _formatDate((profileData?['createdAt'] ?? '').toString());
    final lastLogin = _formatDate((profileData?['lastLogin'] ?? '').toString());
    final skills = _asStringList(profileData?['skills']);

    final displayVerified = (profileData?['display'] as bool?) ?? false;

    final emailVerified = (profileData?['emailVerified'] as bool?) ?? false;
    final mobileVerified = (profileData?['mobileVerified'] as bool?) ?? false;
    final aadharVerified = (profileData?['aadharVerified'] as bool?) ?? false;
    final availability = (profileData?['availability'] as bool?) ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (profileLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(),
          ),
        if (profileError != null)
          Card(
            color: theme.colorScheme.error.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(profileError)),
                  TextButton(onPressed: _loadProfileStatus, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary
                          .withValues(alpha: 0.14),
                      backgroundImage: profilePhotoUrl.isNotEmpty
                          ? NetworkImage(profilePhotoUrl)
                          : null,
                      child: profilePhotoUrl.isEmpty
                          ? Icon(
                              Icons.person_outline,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isEmpty ? 'User' : fullName,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                              'Role: ${_roleLabel(userType)}'),
                        ],
                      ),
                    ),
                    if (companyLogoUrl.isNotEmpty)
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(companyLogoUrl),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatusChip(
                      label: availability ? 'Available' : 'Busy',
                      active: availability,
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: displayVerified ? 'Visible' : 'Not Visible',
                      active: displayVerified,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Details',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                ProfileField(label: 'Email', value: email.isEmpty ? 'Not specified' : email),
                ProfileField(label: 'Mobile', value: mobile.isEmpty ? 'Not specified' : mobile),
                ProfileField(label: 'Age', value: age.isEmpty ? 'Not specified' : age),
                ProfileField(label: 'Experience', value: experience),
                ProfileField(
                  label: 'Location',
                  value: [city, state].where((part) => part.trim().isNotEmpty).join(', ').isEmpty
                      ? 'Not specified'
                      : [city, state].where((part) => part.trim().isNotEmpty).join(', '),
                ),
                ProfileField(label: 'Address', value: address.isEmpty ? 'Not specified' : address),
                ProfileField(label: 'Created On', value: createdAt),
                ProfileField(label: 'Last Login', value: lastLogin),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(about.isEmpty ? 'No bio added yet.' : about),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SkillsSection(skills: skills),
        const SizedBox(height: 10),
        VerificationSection(
          emailVerified: emailVerified,
          mobileVerified: mobileVerified,
          aadharVerified: aadharVerified,
        ),
        const SizedBox(height: 10),
        Card(
          color: subscriptionActive
              ? theme.colorScheme.secondary.withValues(alpha: 0.12)
              : const Color(0xFFFFC107).withValues(alpha: 0.16),
          elevation: subscriptionActive ? 1 : 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      subscriptionActive
                          ? Icons.verified
                          : Icons.warning_rounded,
                      color: subscriptionActive
                          ? theme.colorScheme.secondary
                          : const Color(0xFFF57F17),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subscriptionActive
                            ? 'You Have Subscription'
                            : 'Your profile is hidden',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: subscriptionActive
                              ? theme.colorScheme.secondary
                              : const Color(0xFFF57F17),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (subscriptionActive)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are visible to contractors and can apply for jobs and create job posts freely.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_subscriptionPlan != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Plan Amount:',
                                    style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '₹${_subscriptionPlan!['price']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Duration:',
                                    style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '${_subscriptionPlan!['durationDays']} days',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Per Day:',
                                    style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '₹${(_subscriptionPlan!['pricePerDay'] as num).toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get more interactions with contractors and find more job opportunities.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_subscriptionPlan != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Just',
                                    style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '₹${_subscriptionPlan!['price']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'For',
                                    style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '${_subscriptionPlan!['durationDays']} days',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subscriptionActive
                          ? theme.colorScheme.secondary
                          : const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _showSubscriptionDetails(context, _subscriptionPlan),
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: Text(subscriptionActive ? 'Manage Subscription' : 'Pay Now'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSettingsSheet(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _logout,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _loadProfileStatus,
              ),
            ],
          ),
        ),
      ],
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

    switch (selectedLabel) {
      case 'jobs':
        return _buildJobsView(
          context: context,
          fullName: fullName,
          userType: userType,
          subscriptionActive: _subscriptionActive,
        );
      case 'labours':
        return _LabourListView(canViewSensitiveData: _subscriptionActive);
      case 'contractors':
        return _ContractorListView(canViewSensitiveData: _subscriptionActive);
      case 'history':
        return _buildSectionView(
          context: context,
          icon: Icons.history,
          title: 'History',
          subtitle: 'Track your recent activities and records.',
        );
      case 'profile':
        return _buildProfileView(
          context: context,
          fullName: fullName,
          userType: userType,
          profileData: profileData,
          subscriptionActive: _subscriptionActive,
          profileLoading: _profileLoading,
          profileError: _profileError,
        );
      default:
        return _buildJobsView(
          context: context,
          fullName: fullName,
          userType: userType,
          subscriptionActive: _subscriptionActive,
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

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String _formatDate(String isoDate) {
    if (isoDate.trim().isEmpty) return 'Not available';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return 'Not available';
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
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

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _ContractorListView extends StatefulWidget {
  final bool canViewSensitiveData;

  const _ContractorListView({required this.canViewSensitiveData});

  @override
  State<_ContractorListView> createState() => _ContractorListViewState();
}

class _ContractorListViewState extends State<_ContractorListView> {
  final TextEditingController _searchController = TextEditingController();
  List<MarketplaceUser> _allContractors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadContractors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContractors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await ApiService.fetchContractors();
    if (!mounted) return;

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>?;
      final users = (data?['users'] as List<dynamic>? ?? const []);
      setState(() {
        _allContractors = users
            .map((user) =>
                MarketplaceUser.fromJson(user as Map<String, dynamic>))
            .where((user) =>
                user.userType == 'contractor' ||
                user.userType == 'sub_contractor')
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = (response['message'] ?? 'Unable to load contractors').toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allContractors.where((contractor) {
      final haystack =
          '${contractor.businessName} ${contractor.fullName} ${contractor.city} ${contractor.mobile}'
              .toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppStateMessage(
            icon: Icons.wifi_off,
            title: 'Could not load contractors',
            subtitle: _error!,
          ),
          TextButton(onPressed: _loadContractors, child: const Text('Retry')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContractors,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (!widget.canViewSensitiveData)
            Card(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Subscription inactive. Contact details are masked. Activate subscription to view full details and use job actions.',
                ),
              ),
            ),
          if (!widget.canViewSensitiveData) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Verified Contractors',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${filtered.length}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search contractor',
              hintText: 'Name, city, or mobile',
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const AppStateMessage(
              icon: Icons.search_off,
              title: 'No contractors found',
              subtitle: 'Try another search keyword.',
            )
          else
            ...filtered.map(
              (contractor) => ContractorVisitingCard(
                user: contractor,
                canViewSensitiveData: widget.canViewSensitiveData,
              ),
            ),
        ],
      ),
    );
  }
}

class _LabourListView extends StatefulWidget {
  final bool canViewSensitiveData;

  const _LabourListView({required this.canViewSensitiveData});

  @override
  State<_LabourListView> createState() => _LabourListViewState();
}

class _LabourListViewState extends State<_LabourListView> {
  final TextEditingController _searchController = TextEditingController();
  List<MarketplaceUser> _allLabours = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadLabours();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLabours() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await ApiService.fetchLabours();
    if (!mounted) return;

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>?;
      final users = (data?['users'] as List<dynamic>? ?? const []);
      setState(() {
        _allLabours = users
            .map((user) =>
                MarketplaceUser.fromJson(user as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = (response['message'] ?? 'Unable to load labours').toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allLabours.where((labour) {
      final haystack =
          '${labour.fullName} ${labour.city} ${labour.mobile} ${labour.experienceLabel}'
              .toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppStateMessage(
            icon: Icons.badge_outlined,
            title: 'Could not load labour list',
            subtitle: _error!,
          ),
          TextButton(onPressed: _loadLabours, child: const Text('Retry')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLabours,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (!widget.canViewSensitiveData)
            Card(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Subscription inactive. Labour contact details are masked. Activate subscription to unlock full details and apply/create actions.',
                ),
              ),
            ),
          if (!widget.canViewSensitiveData) const SizedBox(height: 10),
          Text(
            'Labour ID Cards',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search labour',
              hintText: 'Name, city, or mobile',
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const AppStateMessage(
              icon: Icons.credit_card_off,
              title: 'No labour profiles found',
              subtitle: 'Try another search keyword.',
            )
          else
            ...filtered.map(
              (labour) => LabourIdCard(
                user: labour,
                canViewSensitiveData: widget.canViewSensitiveData,
              ),
            ),
        ],
      ),
    );
  }
}

