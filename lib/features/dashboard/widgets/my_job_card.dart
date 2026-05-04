import 'package:flutter/material.dart';

import '../models/my_job.dart';

class MyJobCard extends StatelessWidget {
  final MyJob job;
  final Color primaryColor;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;

  const MyJobCard({
    super.key,
    required this.job,
    required this.primaryColor,
    this.onTap,
    this.onEditTap,
  });

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _targetLabel(String t) {
    switch (t) {
      case 'sub_contractor':
        return 'Sub-Contractor';
      case 'labour':
        return 'Labour';
      default:
        return t;
    }
  }

  Widget _noPhoto() => Container(
        height: 140,
        width: double.infinity,
        color: const Color(0xFFF3F4F6),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 36, color: Color(0xFFD1D5DB)),
            SizedBox(height: 6),
            Text('NO PHOTOS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isLive = job.visibility;
    final location = [job.area, job.city].where((s) => s.isNotEmpty).join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
          width: isLive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
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
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _noPhoto(),
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : _noPhoto(),
                      )
                    : _noPhoto(),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isLive
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isLive ? 'LIVE' : 'HIDDEN',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 34,
                  right: 8,
                  child: Text(
                    isLive ? 'Visible to everyone' : 'Only you can see this',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4)
                        ]),
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
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Color(0xFF6B7280)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(location,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280)),
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
                      children: job.target
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                        Icons.business_center_outlined,
                                        size: 12,
                                        color: Color(0xFF374151)),
                                    const SizedBox(width: 4),
                                    Text(_targetLabel(t),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF374151))),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('REQUIRED',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                  letterSpacing: 0.4)),
                          Text(
                              '${job.workersNeeded} Worker${job.workersNeeded == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Skills
                if (job.requiredSkills.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: job.requiredSkills
                        .take(5)
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        primaryColor.withValues(alpha: 0.25)),
                              ),
                              child: Text(s,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor)),
                            ))
                        .toList(),
                  ),

                // Description
                if (job.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('"${job.description}"',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],

                // Budget + date
                if (job.estimatedBudget != null || job.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (job.estimatedBudget != null) ...[
                        const Icon(Icons.currency_rupee_rounded,
                            size: 13, color: Color(0xFF6B7280)),
                        Text(job.estimatedBudget!.toStringAsFixed(0),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                      ],
                      if (job.createdAt != null) ...[
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 3),
                        Text(_fmtDate(job.createdAt),
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF))),
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
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.people_rounded, size: 16),
                    label: Text(
                        'APPLICATIONS${job.totalApplications > 0 ? ' (${job.totalApplications})' : ''}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      shadowColor: primaryColor.withValues(alpha: 0.4),
                      textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEditTap,
                    icon: Icon(Icons.edit_outlined,
                        size: 15, color: primaryColor),
                    label: const Text('EDIT JOB'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: primaryColor.withValues(alpha: 0.5)),
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ), // GestureDetector
    );
  }
}
