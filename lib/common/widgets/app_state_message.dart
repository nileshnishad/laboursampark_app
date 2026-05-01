import 'package:flutter/material.dart';

class AppStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AppStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
    );
  }
}
