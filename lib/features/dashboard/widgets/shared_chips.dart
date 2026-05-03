import 'package:flutter/material.dart';

/// Small icon + text chip used in cards (location, workers, budget, skills)
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

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
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        Text(date,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
      ],
    );
  }
}
