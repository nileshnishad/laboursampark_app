import 'package:flutter/material.dart';

import '../create_job_screen.dart';
import '../widgets/stat_card.dart';

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  const _QuickAction({required this.icon, required this.title, required this.subtitle});
}

class DashboardHomeView extends StatelessWidget {
  final String fullName;
  final String userType;
  final bool subscriptionActive;
  final Map<String, dynamic>? subscriptionPlan;
  final void Function(String tabLabel) onTabSwitch;
  final void Function(Map<String, dynamic>? plan) onShowSubscription;

  const DashboardHomeView({
    super.key,
    required this.fullName,
    required this.userType,
    required this.subscriptionActive,
    required this.subscriptionPlan,
    required this.onTabSwitch,
    required this.onShowSubscription,
  });

  List<_QuickAction> _quickActions() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = _quickActions();
    final isContractor =
        userType.toLowerCase() == 'contractor' || userType.toLowerCase() == 'sub_contractor';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        // Subscription warning banner
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
                  onPressed: () => onShowSubscription(subscriptionPlan),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Pay Now',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

        // Section header
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

        // Stat cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: isContractor ? 'Jobs Posted' : 'Jobs Available',
                value: isContractor ? '0' : '4',
                color: const Color(0xFF2563EB),
                icon: isContractor ? Icons.post_add_rounded : Icons.work_outline_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: isContractor ? 'Applications' : 'Applied',
                value: '0',
                color: const Color(0xFF7C3AED),
                icon: isContractor ? Icons.inbox_rounded : Icons.send_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: isContractor ? 'Hired' : 'Accepted',
                value: '0',
                color: const Color(0xFF059669),
                icon: isContractor ? Icons.handshake_outlined : Icons.check_circle_outline_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Completed',
                value: '0',
                color: const Color(0xFFF59E0B),
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Quick Actions header
        Row(
          children: [
            Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(4))),
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
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
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
              title: Text(action.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF111827))),
              subtitle: Text(action.subtitle,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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
                child: const Icon(Icons.support_agent_rounded,
                    color: Color(0xFF059669), size: 20),
              ),
              const SizedBox(width: 12),
              Text('Support: +91 9172272305',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
