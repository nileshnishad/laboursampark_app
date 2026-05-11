import 'package:flutter/material.dart';

/// Small icon + text chip used in cards (location, workers, budget, skills)
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.onSurface.withValues(alpha: 0.45)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Label + date row (e.g. "Applied: 01/05/2025")
class DateLabel extends StatelessWidget {
  final String label;
  final String date;

  const DateLabel({super.key, required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 10, color: cs.onSurface.withValues(alpha: 0.4))),
        Text(date,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.75))),
      ],
    );
  }
}
