import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../../core/app_state.dart';
import '../auth/login_screen.dart';
import 'package:get/get.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;

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
    await AuthService.setLoggedIn(false);
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
                  SnackBar(content: Text('${action.title} coming soon')),
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
  }) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.14),
                  child: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'User' : fullName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text('Role: ${_roleLabel(userType)}'),
                    ],
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
  }) {
    final selectedLabel = (navItems[_selectedIndex].label ?? '').toLowerCase();

    switch (selectedLabel) {
      case 'jobs':
        return _buildJobsView(context: context, fullName: fullName, userType: userType);
      case 'labours':
        return _buildSectionView(
          context: context,
          icon: Icons.groups_outlined,
          title: 'Labours',
          subtitle: 'Browse and manage labour profiles.',
        );
      case 'contractors':
        return _buildSectionView(
          context: context,
          icon: Icons.engineering_outlined,
          title: 'Contractors',
          subtitle: 'Connect with trusted contractors.',
        );
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
        );
      default:
        return _buildJobsView(context: context, fullName: fullName, userType: userType);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          titleSpacing: 10,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  initials,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty ? 'Welcome' : fullName,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _roleLabel(userType),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => _showSettingsSheet(context),
            ),
          ],
        ),
        body: _buildCurrentTabBody(
          context: context,
          navItems: navItems,
          fullName: fullName,
          userType: userType,
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
  

