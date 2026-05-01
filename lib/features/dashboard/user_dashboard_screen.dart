import 'package:flutter/material.dart';

import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../auth/login_screen.dart';
import 'package:get/get.dart';

class UserDashboardScreen extends StatefulWidget {
  UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;

  List<BottomNavigationBarItem> _getNavItems(String userType) {
    switch (userType.toLowerCase()) {
      case 'labour':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Contractor'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      case 'sub_contractor':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          const BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create Job'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Contractor'),
          const BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Labours'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      case 'contractor':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create Job'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Contractors'),
          const BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Labours'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      default:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
    }
  }

  List<Widget> _getPages(String userType) {
    switch (userType.toLowerCase()) {
      case 'labour':
        return [
          const Center(child: Text('Jobs')), // Jobs
          const Center(child: Text('Contractor')), // Contractor
          const Center(child: Text('History')), // History
          const Center(child: Text('Profile')), // Profile
        ];
      case 'sub_contractor':
        return [
          const Center(child: Text('Jobs')), // Jobs
          const Center(child: Text('Create Job')), // Create Job
          const Center(child: Text('Contractor')), // Contractor
          const Center(child: Text('Labours')), // Labours
          const Center(child: Text('History')), // History
          const Center(child: Text('Profile')), // Profile
        ];
      case 'contractor':
        return [
          const Center(child: Text('Create Job')), // Create Job
          const Center(child: Text('Contractors')), // Contractors
          const Center(child: Text('Labours')), // Labours
          const Center(child: Text('History')), // History
          const Center(child: Text('Profile')), // Profile
        ];
      default:
        return [
          const Center(child: Text('Home')), // Home
          const Center(child: Text('Profile')), // Profile
        ];
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
    return Obx(() {
      final user = userController.user.value;
      final fullName = user?['fullName'] ?? '';
      final userType = (user?['userType'] ?? '').toString();
      final navItems = _getNavItems(userType);
      final pages = _getPages(userType);
      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(userType, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                userController.clearUser();
                await AuthService.setLoggedIn(false);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: navItems,
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      );
    });
  }
}
  

