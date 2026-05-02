import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../../core/app_state.dart';
import '../../services/api_service.dart';
import '../../common/widgets/app_state_message.dart';
import '../auth/login_screen.dart';
import 'package:get/get.dart';
import 'create_job_screen.dart';

// Models
import 'models/marketplace_user.dart';
import 'models/job_history_entry.dart';

// Widgets
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
          _QuickAction(icon: Icons.post_add_rounded, title: 'My Jobs', subtitle: 'View posted jobs'),
          _QuickAction(icon: Icons.groups_outlined, title: 'Labours', subtitle: 'Manage team'),
        ];
      case 'contractor':
        return const [
          _QuickAction(icon: Icons.add_box_outlined, title: 'Create Job', subtitle: 'Post requirement'),
          _QuickAction(icon: Icons.post_add_rounded, title: 'My Jobs', subtitle: 'View posted jobs'),
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
    required void Function(String tabLabel) onTabSwitch,
  }) {
    final theme = Theme.of(context);
    final actions = _quickActions(userType);
    final isContractor = userType.toLowerCase() == 'contractor' || userType.toLowerCase() == 'sub_contractor';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        // Subscription warning banner (matches web app yellow banner)
        if (!subscriptionActive)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE047)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_rounded, color: Color(0xFFB45309), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your profile is hidden. Pay subscription to get full access!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showSubscriptionDetails(context, _subscriptionPlan),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

        // Section header - matches web app style
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isContractor ? 'WORK OVERVIEW' : 'JOB OVERVIEW',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4 stat cards matching web app — labels differ by role
        Row(
          children: [
            Expanded(child: _StatCard(
              label: isContractor ? 'Jobs Posted' : 'Jobs Available',
              value: isContractor ? '0' : '4',
              color: const Color(0xFF2563EB),
              icon: isContractor ? Icons.post_add_rounded : Icons.work_outline_rounded,
            )),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(
              label: isContractor ? 'Applications' : 'Applied',
              value: '0',
              color: const Color(0xFF7C3AED),
              icon: isContractor ? Icons.inbox_rounded : Icons.send_outlined,
            )),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _StatCard(
              label: isContractor ? 'Hired' : 'Accepted',
              value: '0',
              color: const Color(0xFF059669),
              icon: isContractor ? Icons.handshake_outlined : Icons.check_circle_outline_rounded,
            )),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(
              label: 'Completed',
              value: '0',
              color: const Color(0xFFF59E0B),
              icon: Icons.verified_outlined,
            )),
          ],
        ),
        const SizedBox(height: 20),

        // Quick Actions header
        Row(
          children: [
            Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 10),
            Text(
              isContractor ? 'MANAGE WORK' : 'QUICK ACTIONS',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action cards
        ...actions.map(
          (action) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: const Color(0xFF2563EB), size: 22),
              ),
              title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF111827))),
              subtitle: Text(action.subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
              onTap: () {
                switch (action.title) {
                  case 'Create Job':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateJobScreen(userType: userType),
                      ),
                    );
                    return;
                  case 'My Jobs':
                    onTabSwitch('my jobs');
                    return;
                  case 'Labours':
                    onTabSwitch('labours');
                    return;
                  case 'Contractors':
                    onTabSwitch('contractors');
                    return;
                  case 'History':
                    onTabSwitch('history');
                    return;
                  case 'Find Work':
                    onTabSwitch('jobs');
                    return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      subscriptionActive
                          ? '${action.title} coming soon'
                          : 'Subscription required to use this feature.',
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Support card
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.support_agent_rounded, color: Color(0xFF059669), size: 20),
              ),
              const SizedBox(width: 12),
              Text('Support: +91 9172272305', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
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
    final profilePhotoUrl = (profileData?['profilePhotoUrl'] ?? '').toString();
    final companyLogoUrl = (profileData?['companyLogoUrl'] ?? '').toString();
    final companyName = (profileData?['companyName'] ?? '').toString();
    final about = (profileData?['bio'] ?? profileData?['about'] ?? '').toString();
    final age = (profileData?['age'] ?? '').toString();
    final experience = (profileData?['experience'] ?? profileData?['experienceRange'] ?? '').toString();
    final email = (profileData?['email'] ?? '').toString();
    final mobile = (profileData?['mobile'] ?? '').toString();
    final location = profileData?['location'] as Map<String, dynamic>?;
    final city = (profileData?['city'] ?? location?['city'] ?? '').toString();
    final state = (profileData?['state'] ?? location?['state'] ?? '').toString();
    final address = (location?['address'] ?? '').toString();
    final createdAt = _formatDate((profileData?['createdAt'] ?? '').toString());
    final lastLogin = _formatDate((profileData?['lastLogin'] ?? '').toString());
    final skills = _asStringList(profileData?['skills']);
    final workingHours = (profileData?['workingHours'] ?? '').toString();
    final workTypes = _asStringList(profileData?['workTypes']);
    final serviceCategories = _asStringList(profileData?['serviceCategories']);
    final languages = _asStringList(profileData?['languages']);
    final rawId = (profileData?['userId'] ?? profileData?['_id'] ?? '').toString();
    final shortId = rawId.length > 6 ? 'ID: #${rawId.substring(0, 6).toUpperCase()}' : (rawId.isNotEmpty ? 'ID: #$rawId' : '');

    final displayVerified = (profileData?['display'] as bool?) ?? false;
    final emailVerified = (profileData?['emailVerified'] as bool?) ?? false;
    final mobileVerified = (profileData?['mobileVerified'] as bool?) ?? false;
    final aadharVerified = (profileData?['aadharVerified'] as bool?) ?? false;
    final availability = (profileData?['availability'] as bool?) ?? false;

    // Per-role theming
    final isContractor = userType.toLowerCase() == 'contractor';
    final isSubContractor = userType.toLowerCase() == 'sub_contractor';
    final avatarColor = isContractor
        ? const Color(0xFF059669)
        : isSubContractor
            ? const Color(0xFF7C3AED)
            : const Color(0xFF2563EB);

    // Build initials from name
    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (fullName.isNotEmpty ? fullName.substring(0, fullName.length > 1 ? 2 : 1).toUpperCase() : 'LS');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (profileLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(color: Color(0xFF2563EB)),
          ),
        if (profileError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(profileError, style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13))),
                TextButton(
                  onPressed: _loadProfileStatus,
                  style: TextButton.styleFrom(minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

        // ── Attention / subscription banner ──────────────────────────────
        if (!subscriptionActive)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE047)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Attention Required',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF92400E), fontSize: 14)),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Color(0xFF92400E), fontSize: 13, height: 1.4),
                          children: [
                            TextSpan(text: 'Your profile is currently '),
                            TextSpan(text: 'hidden', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                            TextSpan(text: '. To make your account visible and access all features, please pay the subscription amount.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _showSubscriptionDetails(context, _subscriptionPlan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Pay\nSubscription', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),

        // ── Profile hero card ─────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with verified badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // For contractors: show company logo as main avatar if available
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: avatarColor,
                          backgroundImage: (isContractor || isSubContractor) && companyLogoUrl.isNotEmpty
                              ? NetworkImage(companyLogoUrl)
                              : profilePhotoUrl.isNotEmpty
                                  ? NetworkImage(profilePhotoUrl)
                                  : null,
                          child: (isContractor || isSubContractor)
                              ? (companyLogoUrl.isEmpty
                                  ? Icon(Icons.business_center_rounded, size: 28, color: Colors.white)
                                  : null)
                              : (profilePhotoUrl.isEmpty
                                  ? Text(initials,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))
                                  : null),
                        ),
                        // For contractors: show profile photo as small overlay if both exist
                        if ((isContractor || isSubContractor) && profilePhotoUrl.isNotEmpty && companyLogoUrl.isNotEmpty)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: CircleAvatar(radius: 14, backgroundImage: NetworkImage(profilePhotoUrl)),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: displayVerified ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isEmpty ? 'User' : fullName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                          ),
                          if ((isContractor || isSubContractor) && companyName.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.business_rounded, size: 13, color: avatarColor),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(companyName,
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: avatarColor),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _ProfileBadge(label: _roleLabel(userType).toUpperCase(), color: avatarColor),
                              if (shortId.isNotEmpty) _ProfileBadge(label: shortId),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showSettingsSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: avatarColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'UPDATE\nPROFILE',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, height: 1.4, letterSpacing: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Status row
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(child: _ProfileStatusItem(label: 'STATUS', value: '● ONLINE', valueColor: const Color(0xFF059669))),
                    Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                    Expanded(
                      child: _ProfileStatusItem(
                        label: 'VISIBLE',
                        value: displayVerified ? 'VISIBLE' : 'HIDDEN',
                        valueColor: displayVerified ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                    Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                    Expanded(
                      child: _ProfileStatusItem(
                        label: isContractor ? 'HIRING' : 'AVAILABILITY',
                        value: availability
                            ? (isContractor ? 'OPEN\nTO HIRE' : 'READY TO\nWORK')
                            : (isContractor ? 'NOT HIRING' : 'BUSY'),
                        valueColor: availability ? const Color(0xFF059669) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Contact Information ───────────────────────────────────────────
        _ProfileSectionCard(
          title: 'CONTACT INFORMATION',
          icon: Icons.contact_page_outlined,
          color: const Color(0xFF2563EB),
          child: _ProfileInfoGrid(items: [
            _InfoItem(label: 'FULL NAME', value: fullName.isEmpty ? 'Not specified' : fullName),
            if ((isContractor || isSubContractor) && companyName.isNotEmpty)
              _InfoItem(label: 'COMPANY NAME', value: companyName),
            _InfoItem(label: 'EMAIL', value: email.isEmpty ? 'Not specified' : email),
            _InfoItem(label: 'PHONE', value: mobile.isEmpty ? 'Not specified' : mobile),
            if (!isContractor && !isSubContractor)
              _InfoItem(label: 'AGE', value: age.isEmpty ? 'Not specified' : age),
          ]),
        ),
        const SizedBox(height: 10),

        // ── Work / Business section ───────────────────────────────────────
        _ProfileSectionCard(
          title: (isContractor || isSubContractor) ? 'BUSINESS DETAILS' : 'WORK EXPERIENCE & SKILLS',
          icon: (isContractor || isSubContractor) ? Icons.business_center_rounded : Icons.work_outline_rounded,
          color: const Color(0xFF7C3AED),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileInfoGrid(items: [
                _InfoItem(
                    label: (isContractor || isSubContractor) ? 'YEARS IN BUSINESS' : 'EXPERIENCE',
                    value: experience.isEmpty ? 'Not specified' : experience),
                if (!isContractor && !isSubContractor)
                  _InfoItem(label: 'WORKING HOURS', value: workingHours.isEmpty ? 'Not specified' : workingHours),
                _InfoItem(
                    label: (isContractor || isSubContractor) ? 'WORK TYPES / TRADE' : 'WORK TYPES',
                    value: workTypes.isEmpty ? 'Not specified' : workTypes.join(', ')),
                _InfoItem(
                    label: (isContractor || isSubContractor) ? 'SPECIALIZATION' : 'SKILLS',
                    value: skills.isEmpty ? 'Not specified' : skills.join(', ')),
                _InfoItem(label: 'SERVICE CATEGORIES', value: serviceCategories.isEmpty ? 'Not specified' : serviceCategories.join(', ')),
                _InfoItem(label: 'LANGUAGES', value: languages.isEmpty ? 'Not specified' : languages.join(', ')),
              ]),
              if (about.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (isContractor || isSubContractor) ? 'ABOUT COMPANY' : 'ABOUT',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      Text(about, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.5)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Location Presence ─────────────────────────────────────────────
        _ProfileSectionCard(
          title: 'LOCATION PRESENCE',
          icon: Icons.location_on_outlined,
          color: const Color(0xFF059669),
          child: _ProfileInfoGrid(items: [
            _InfoItem(label: 'CITY', value: city.isEmpty ? 'Not specified' : city),
            _InfoItem(label: 'STATE', value: state.isEmpty ? 'Not specified' : state),
            _InfoItem(label: 'ADDRESS', value: address.isEmpty ? 'Not specified' : address),
          ]),
        ),
        const SizedBox(height: 10),

        // ── Account Trust & Verification ──────────────────────────────────
        _ProfileSectionCard(
          title: 'ACCOUNT TRUST & VERIFICATION',
          icon: Icons.verified_outlined,
          color: const Color(0xFF2563EB),
          child: _ProfileInfoGrid(items: [
            _InfoItem(label: 'EMAIL', value: emailVerified ? '✓ Verified' : '✗ Not Verified', valueColor: emailVerified ? const Color(0xFF059669) : const Color(0xFFDC2626)),
            _InfoItem(label: 'MOBILE', value: mobileVerified ? '✓ Verified' : '✗ Not Verified', valueColor: mobileVerified ? const Color(0xFF059669) : const Color(0xFFDC2626)),
            _InfoItem(label: 'AADHAR', value: aadharVerified ? '✓ Verified' : '✗ Not Verified', valueColor: aadharVerified ? const Color(0xFF059669) : const Color(0xFFDC2626)),
            _InfoItem(label: 'ACCOUNT CREATED', value: createdAt),
            _InfoItem(label: 'LAST LOGIN', value: lastLogin),
          ]),
        ),
        const SizedBox(height: 10),

        // ── Subscription ──────────────────────────────────────────────────
        _ProfileSectionCard(
          title: subscriptionActive ? 'SUBSCRIPTION ACTIVE' : 'SUBSCRIPTION REQUIRED',
          icon: subscriptionActive ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
          color: subscriptionActive ? const Color(0xFF059669) : const Color(0xFFF59E0B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_subscriptionPlan != null) ...[
                _ProfileInfoGrid(items: [
                  _InfoItem(label: 'PLAN AMOUNT', value: '₹${_subscriptionPlan!['price']}'),
                  _InfoItem(label: 'DURATION', value: '${_subscriptionPlan!['durationDays']} days'),
                  if ((_subscriptionPlan!['pricePerDay'] as num?) != null)
                    _InfoItem(label: 'PER DAY', value: '₹${(_subscriptionPlan!['pricePerDay'] as num).toStringAsFixed(2)}'),
                ]),
                const SizedBox(height: 12),
              ] else ...[
                Text(
                  subscriptionActive
                      ? 'You are visible to contractors and can apply for jobs freely.'
                      : 'Get more interactions and find more job opportunities.',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.5),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showSubscriptionDetails(context, _subscriptionPlan),
                  icon: Icon(subscriptionActive ? Icons.manage_accounts_rounded : Icons.payment_rounded, size: 18),
                  label: Text(subscriptionActive ? 'Manage Subscription' : 'Pay Now — Get Visible'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subscriptionActive ? const Color(0xFF059669) : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Actions card ──────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _ProfileActionTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => _showSettingsSheet(context),
              ),
              const Divider(height: 1, indent: 56),
              _ProfileActionTile(
                icon: Icons.refresh_rounded,
                label: 'Refresh Profile',
                onTap: _loadProfileStatus,
              ),
              const Divider(height: 1, indent: 56),
              _ProfileActionTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: const Color(0xFFDC2626),
                onTap: _logout,
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
    final userController = Get.find<UserController>();
    final token = userController.token.value ?? '';

    switch (selectedLabel) {
      case 'jobs':
        return _buildJobsView(
          context: context,
          fullName: fullName,
          userType: userType,
          subscriptionActive: _subscriptionActive,
          onTabSwitch: (label) {
            final navItems = _getNavItems(userType);
            final idx = navItems.indexWhere((item) => (item.label ?? '').toLowerCase() == label);
            if (idx != -1) _onItemTapped(idx);
          },
        );
      case 'labours':
        return _LabourListView(canViewSensitiveData: _subscriptionActive);
      case 'contractors':
        return _ContractorListView(canViewSensitiveData: _subscriptionActive);
      case 'my jobs':
        return _MyJobsView(token: token, userType: userType);
      case 'history':
        return _HistoryView(token: token, userType: userType);
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
          onTabSwitch: (label) {
            final navItems = _getNavItems(userType);
            final idx = navItems.indexWhere((item) => (item.label ?? '').toLowerCase() == label);
            if (idx != -1) _onItemTapped(idx);
          },
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        ],
      ),
    );
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

// ── Profile page helper widgets ───────────────────────────────────────────────

/// Pill badge (e.g. "SKILLED WORKER", "ID: #ABC123")
class _ProfileBadge extends StatelessWidget {
  final String label;
  final Color? color;
  const _ProfileBadge({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color != null ? color!.withValues(alpha: 0.1) : const Color(0xFFF3F4F6);
    final border = color != null ? color!.withValues(alpha: 0.3) : const Color(0xFFD1D5DB);
    final text = color ?? const Color(0xFF374151);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: text, letterSpacing: 0.3)),
    );
  }
}

/// Status info column (label + value) used in the STATUS / VISIBLE / AVAILABILITY row
class _ProfileStatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _ProfileStatusItem({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: valueColor, height: 1.3)),
      ],
    );
  }
}

/// Section card — blue left border, collapsible, with consistent header
class _ProfileSectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  const _ProfileSectionCard({required this.title, required this.icon, required this.color, required this.child});

  @override
  State<_ProfileSectionCard> createState() => _ProfileSectionCardState();
}

class _ProfileSectionCardState extends State<_ProfileSectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: [
          // Section header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 10),
                  Icon(widget.icon, size: 16, color: widget.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF111827), letterSpacing: 0.4),
                    ),
                  ),
                  Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF9CA3AF), size: 20),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(padding: const EdgeInsets.all(14), child: widget.child),
          ],
        ],
      ),
    );
  }
}

/// Data class for a single info chip
class _InfoItem {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoItem({required this.label, required this.value, this.valueColor});
}

/// 2-column grid of info chips (label on top, value below)
class _ProfileInfoGrid extends StatelessWidget {
  final List<_InfoItem> items;
  const _ProfileInfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 76) / 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(item.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: item.valueColor ?? const Color(0xFF111827),
                        height: 1.3)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Action row for Settings / Logout / Refresh
class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ProfileActionTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF374151);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: c),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c))),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFFD1D5DB), size: 20),
          ],
        ),
      ),
    );
  }
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

// ── History View ──────────────────────────────────────────────────────────────

class _HistoryView extends StatefulWidget {
  final String token;
  final String userType;
  const _HistoryView({required this.token, required this.userType});

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  List<JobHistoryEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.fetchJobHistory(widget.token);
    if (!mounted) return;
    if (result['success'] == true) {
      final list = (result['data'] as List? ?? []);
      setState(() {
        _entries = list
            .map((e) => JobHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = (result['message'] ?? 'Failed to load history').toString();
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF059669);
      case 'accepted':
        return const Color(0xFF2563EB);
      case 'applied':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'accepted':
        return Icons.thumb_up_rounded;
      case 'applied':
        return Icons.send_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'COMPLETED';
      case 'accepted':
        return 'ACCEPTED';
      case 'applied':
        return 'APPLIED';
      case 'rejected':
        return 'REJECTED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatShortDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF374151))),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, size: 36, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 14),
            const Text('No History Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const SizedBox(height: 6),
            const Text('Your job applications will appear here.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          ],
        ),
      );
    }

    // Counts by status
    final completedCount = _entries.where((e) => e.status == 'completed').length;
    final acceptedCount = _entries.where((e) => e.status == 'accepted').length;
    final appliedCount = _entries.where((e) => e.status == 'applied').length;
    final rejectedCount = _entries.where((e) => e.status == 'rejected').length;
    final isContractorView = widget.userType == 'contractor';

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Summary stat row
          if (isContractorView)
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Applied', value: appliedCount.toString(), color: const Color(0xFFF59E0B), icon: Icons.send_rounded)),
                const SizedBox(width: 6),
                Expanded(child: _StatCard(label: 'Accepted', value: acceptedCount.toString(), color: const Color(0xFF2563EB), icon: Icons.thumb_up_rounded)),
                const SizedBox(width: 6),
                Expanded(child: _StatCard(label: 'Done', value: completedCount.toString(), color: const Color(0xFF059669), icon: Icons.check_circle_rounded)),
                const SizedBox(width: 6),
                Expanded(child: _StatCard(label: 'Rejected', value: rejectedCount.toString(), color: const Color(0xFFDC2626), icon: Icons.cancel_rounded)),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Applied', value: appliedCount.toString(), color: const Color(0xFFF59E0B), icon: Icons.send_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Accepted', value: acceptedCount.toString(), color: const Color(0xFF2563EB), icon: Icons.thumb_up_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Completed', value: completedCount.toString(), color: const Color(0xFF059669), icon: Icons.check_circle_rounded)),
              ],
            ),
          const SizedBox(height: 16),
          // Section header
          Row(
            children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Text(
                isContractorView
                    ? 'APPLICATIONS RECEIVED (${_entries.length})'
                    : 'JOB APPLICATIONS (${_entries.length})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._entries.map((entry) => _HistoryCard(
                entry: entry,
                isContractorView: isContractorView,
                statusColor: _statusColor(entry.status),
                statusIcon: _statusIcon(entry.status),
                statusLabel: _statusLabel(entry.status),
                formatDate: _formatShortDate,
              )),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final JobHistoryEntry entry;
  final bool isContractorView;
  final Color statusColor;
  final IconData statusIcon;
  final String statusLabel;
  final String Function(DateTime?) formatDate;

  const _HistoryCard({
    required this.entry,
    required this.isContractorView,
    required this.statusColor,
    required this.statusIcon,
    required this.statusLabel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final location = [entry.area, entry.city, entry.state].where((s) => s.isNotEmpty).join(', ');
    final isRejected = entry.status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isRejected ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Job Header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.workTitle.isEmpty ? 'Untitled Job' : entry.workTitle,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabel,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor, letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Description
          if (entry.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 5, 14, 0),
              child: Text(
                entry.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
              ),
            ),
          const SizedBox(height: 8),
          // Job info chips: location, workers, skills, budget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (location.isNotEmpty)
                  _InfoChip(icon: Icons.location_on_outlined, label: location),
                if (entry.workersNeeded > 0)
                  _InfoChip(icon: Icons.groups_outlined, label: '${entry.workersNeeded} workers'),
                if (entry.estimatedBudget != null && entry.estimatedBudget! > 0)
                  _InfoChip(
                    icon: Icons.currency_rupee_rounded,
                    label: entry.estimatedBudget! >= 1000
                        ? '₹${(entry.estimatedBudget! / 1000).toStringAsFixed(1)}k'
                        : '₹${entry.estimatedBudget!.toStringAsFixed(0)}',
                  ),
                ...entry.requiredSkills.take(2).map((s) => _InfoChip(icon: Icons.build_outlined, label: s)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Applicant section (contractor view) ─────────────
          if (isContractorView && entry.applicantName.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 7),
                  const Text('APPLICANT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED), letterSpacing: 0.5)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    backgroundImage: entry.applicantPhoto.isNotEmpty ? NetworkImage(entry.applicantPhoto) : null,
                    child: entry.applicantPhoto.isEmpty
                        ? Text(
                            entry.applicantName.isNotEmpty ? entry.applicantName[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + userType
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.applicantName,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entry.applicantUserType.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED), letterSpacing: 0.3),
                              ),
                            ),
                          ],
                        ),
                        // Rating stars
                        if (entry.applicantRating > 0) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(
                                i < entry.applicantRating.floor()
                                    ? Icons.star_rounded
                                    : (i < entry.applicantRating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                                size: 13,
                                color: const Color(0xFFF59E0B),
                              )),
                              const SizedBox(width: 4),
                              Text(
                                entry.applicantRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                              ),
                            ],
                          ),
                        ],
                        // Experience
                        if (entry.applicantExperience.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.work_outline_rounded, size: 11, color: Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              Text(entry.applicantExperience,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                        // Contact
                        const SizedBox(height: 4),
                        if (entry.applicantMobile.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 11, color: Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              Text(entry.applicantMobile,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        if (entry.applicantEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 11, color: Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(entry.applicantEmail,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF374151))),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Applicant skills
            if (entry.applicantSkills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: entry.applicantSkills.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 10),
          ],

          // ── Posted-by section (labour/sub-contractor view) ───
          if (!isContractorView) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    backgroundImage: entry.postedByPhoto.isNotEmpty ? NetworkImage(entry.postedByPhoto) : null,
                    child: entry.postedByPhoto.isEmpty
                        ? const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF7C3AED))
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.postedByName.isEmpty ? 'Contractor' : entry.postedByName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                        ),
                        if (entry.postedByUserType.isNotEmpty)
                          Text(
                            entry.postedByUserType.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                  // Timeline dates on right
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (entry.appliedAt != null)
                        _DateLabel(label: 'Applied', date: formatDate(entry.appliedAt)),
                      if (entry.acceptedAt != null)
                        _DateLabel(label: 'Accepted', date: formatDate(entry.acceptedAt)),
                      if (entry.completedAt != null)
                        _DateLabel(label: 'Done', date: formatDate(entry.completedAt)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Application message ─────────────────────────────
          if (entry.applicationMessage.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded, size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.applicationMessage,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontStyle: FontStyle.italic, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

          // ── Rejection reason ────────────────────────────────
          if (isRejected && entry.rejectionReason.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rejection Reason',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                        const SizedBox(height: 2),
                        Text(
                          entry.rejectionReason,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Timeline (contractor view) ──────────────────────
          if (isContractorView)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (entry.appliedAt != null)
                    _DateLabel(label: 'Applied', date: formatDate(entry.appliedAt)),
                  if (entry.acceptedAt != null)
                    _DateLabel(label: 'Accepted', date: formatDate(entry.acceptedAt)),
                  if (entry.completedAt != null)
                    _DateLabel(label: 'Completed', date: formatDate(entry.completedAt)),
                  if (entry.rejectedAt != null)
                    _DateLabel(label: 'Rejected', date: formatDate(entry.rejectedAt)),
                ],
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  final String label;
  final String date;
  const _DateLabel({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
      ],
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

// ─────────────────────────────────────────────────────────────────────────────
// My Jobs — posted jobs for contractor / sub_contractor
// ─────────────────────────────────────────────────────────────────────────────

class _MyJob {
  final String id;
  final String workTitle;
  final String description;
  final List<String> target;
  final int workersNeeded;
  final List<String> requiredSkills;
  final List<String> images;
  final num? estimatedBudget;
  final String status;
  final bool visibility;
  final int totalApplications;
  final String city;
  final String area;
  final String state;
  final DateTime? createdAt;

  const _MyJob({
    required this.id,
    required this.workTitle,
    required this.description,
    required this.target,
    required this.workersNeeded,
    required this.requiredSkills,
    required this.images,
    required this.estimatedBudget,
    required this.status,
    required this.visibility,
    required this.totalApplications,
    required this.city,
    required this.area,
    required this.state,
    required this.createdAt,
  });

  factory _MyJob.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : <String, dynamic>{};
    return _MyJob(
      id: (json['_id'] ?? '').toString(),
      workTitle: (json['workTitle'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      target: (json['target'] as List? ?? []).map((e) => e.toString()).toList(),
      workersNeeded: (json['workersNeeded'] as num?)?.toInt() ?? 1,
      requiredSkills:
          (json['requiredSkills'] as List? ?? []).map((e) => e.toString()).toList(),
      images: (json['images'] as List? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      estimatedBudget: json['estimatedBudget'] as num?,
      status: (json['status'] ?? 'open').toString(),
      visibility: (json['visibility'] as bool?) ?? false,
      totalApplications: (json['totalApplications'] as num?)?.toInt() ?? 0,
      city: (loc['city'] ?? '').toString(),
      area: (loc['area'] ?? '').toString(),
      state: (loc['state'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}

class _MyJobsView extends StatefulWidget {
  final String token;
  final String userType;

  const _MyJobsView({required this.token, required this.userType});

  @override
  State<_MyJobsView> createState() => _MyJobsViewState();
}

class _MyJobsViewState extends State<_MyJobsView> {
  List<_MyJob> _jobs = [];
  bool _loading = true;
  String? _error;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.fetchMyJobs(widget.token);
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final jobs = (data?['jobs'] as List? ?? []);
      final pagination = data?['pagination'] as Map<String, dynamic>?;
      setState(() {
        _jobs = jobs
            .map((j) => _MyJob.fromJson(j as Map<String, dynamic>))
            .toList();
        _total = (pagination?['total'] as num?)?.toInt() ?? _jobs.length;
        _loading = false;
      });
    } else {
      setState(() {
        _error = (result['message'] ?? 'Failed to load jobs').toString();
        _loading = false;
      });
    }
  }

  Color get _primaryColor =>
      widget.userType == 'sub_contractor'
          ? const Color(0xFF7C3AED)
          : const Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: _primaryColor));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF374151))),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Post New',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      Text('Requirement',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _primaryColor)),
                      const SizedBox(height: 4),
                      Text(
                        '$_total published job${_total == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final created = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => CreateJobScreen(userType: widget.userType),
                      ),
                    );
                    if (created == true) _load();
                  },
                  icon: const Icon(Icons.upload_rounded, size: 16),
                  label: const Text('CREATE JOB',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Section label ─────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 4, height: 20,
                decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 10),
              Text(
                'PUBLISHED JOBS (${_jobs.length})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Empty state ───────────────────────────────────────────
          if (_jobs.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.post_add_rounded, size: 36, color: _primaryColor),
                    ),
                    const SizedBox(height: 14),
                    const Text('No Jobs Posted Yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                    const SizedBox(height: 6),
                    const Text('Tap CREATE JOB to post your first requirement.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else
            ..._jobs.map((job) => _MyJobCard(job: job, primaryColor: _primaryColor)),
        ],
      ),
    );
  }
}

class _MyJobCard extends StatelessWidget {
  final _MyJob job;
  final Color primaryColor;

  const _MyJobCard({required this.job, required this.primaryColor});

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _targetLabel(String t) {
    switch (t) {
      case 'sub_contractor': return 'Sub-Contractor';
      case 'labour': return 'Labour';
      default: return t;
    }
  }

  Widget _noPhoto() => Container(
        height: 140, width: double.infinity,
        color: const Color(0xFFF3F4F6),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 36, color: Color(0xFFD1D5DB)),
            SizedBox(height: 6),
            Text('NO PHOTOS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 1)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isLive = job.visibility;
    final location = [job.area, job.city].where((s) => s.isNotEmpty).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
          width: isLive ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ─────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Stack(
              children: [
                job.images.isNotEmpty
                    ? Image.network(
                        job.images.first,
                        height: 140, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _noPhoto(),
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : _noPhoto(),
                      )
                    : _noPhoto(),

                // LIVE / HIDDEN badge
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: isLive ? const Color(0xFF4ADE80) : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isLive ? 'LIVE' : 'HIDDEN',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 34, right: 8,
                  child: Text(
                    isLive ? 'Visible to everyone' : 'Only you can see this',
                    style: const TextStyle(fontSize: 10, color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.workTitle.isEmpty ? 'Untitled Job' : job.workTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF6B7280)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(location,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),

                // Target + Workers
                Row(
                  children: [
                    Wrap(
                      spacing: 6,
                      children: job.target.map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.business_center_outlined, size: 12, color: Color(0xFF374151)),
                                const SizedBox(width: 4),
                                Text(_targetLabel(t), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                              ],
                            ),
                          )).toList(),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('REQUIRED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF059669), letterSpacing: 0.4)),
                          Text('${job.workersNeeded} Worker${job.workersNeeded == 1 ? '' : 's'}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Skills
                if (job.requiredSkills.isNotEmpty)
                  Wrap(
                    spacing: 6, runSpacing: 4,
                    children: job.requiredSkills.take(5).map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                          ),
                          child: Text(s, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryColor)),
                        )).toList(),
                  ),

                // Description
                if (job.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('"${job.description}"',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],

                // Budget + date
                if (job.estimatedBudget != null || job.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (job.estimatedBudget != null) ...[
                        const Icon(Icons.currency_rupee_rounded, size: 13, color: Color(0xFF6B7280)),
                        Text(job.estimatedBudget!.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                      ],
                      if (job.createdAt != null) ...[
                        const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 3),
                        Text(_fmtDate(job.createdAt),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Action buttons ─────────────────────────────────────
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          '${job.totalApplications} application${job.totalApplications == 1 ? '' : 's'} — full view coming soon',
                        ),
                      ));
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                    ),
                    child: Text('APPLICATIONS${job.totalApplications > 0 ? ' (${job.totalApplications})' : ''}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit job — coming soon')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                    ),
                    child: const Text('EDIT JOB →'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

