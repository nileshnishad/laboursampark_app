import 'package:flutter/material.dart';

import '../models/job_history_entry.dart';
import 'shared_chips.dart';

class HistoryCard extends StatelessWidget {
  final JobHistoryEntry entry;
  final bool isContractorView;
  final Color statusColor;
  final IconData statusIcon;
  final String statusLabel;
  final String Function(DateTime?) formatDate;

  const HistoryCard({
    super.key,
    required this.entry,
    required this.isContractorView,
    required this.statusColor,
    required this.statusIcon,
    required this.statusLabel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final location =
        [entry.area, entry.city, entry.state].where((s) => s.isNotEmpty).join(', ');
    final isRejected = entry.status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isRejected ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Job Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.workTitle.isEmpty ? 'Untitled Job' : entry.workTitle,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (entry.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 5, 14, 0),
              child: Text(
                entry.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (location.isNotEmpty)
                  InfoChip(icon: Icons.location_on_outlined, label: location),
                if (entry.workersNeeded > 0)
                  InfoChip(
                      icon: Icons.groups_outlined,
                      label: '${entry.workersNeeded} workers'),
                if (entry.estimatedBudget != null && entry.estimatedBudget! > 0)
                  InfoChip(
                    icon: Icons.currency_rupee_rounded,
                    label: entry.estimatedBudget! >= 1000
                        ? '₹${(entry.estimatedBudget! / 1000).toStringAsFixed(1)}k'
                        : '₹${entry.estimatedBudget!.toStringAsFixed(0)}',
                  ),
                ...entry.requiredSkills
                    .take(2)
                    .map((s) => InfoChip(icon: Icons.build_outlined, label: s)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Applicant section (contractor view) ──────────────
          if (isContractorView && entry.applicantName.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 7),
                  const Text('APPLICANT',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C3AED),
                          letterSpacing: 0.5)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    backgroundImage: entry.applicantPhoto.isNotEmpty
                        ? NetworkImage(entry.applicantPhoto)
                        : null,
                    child: entry.applicantPhoto.isEmpty
                        ? Text(
                            entry.applicantName.isNotEmpty
                                ? entry.applicantName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7C3AED)),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.applicantName,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entry.applicantUserType
                                    .replaceAll('_', ' ')
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF7C3AED),
                                    letterSpacing: 0.3),
                              ),
                            ),
                          ],
                        ),
                        if (entry.applicantRating > 0) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              ...List.generate(
                                  5,
                                  (i) => Icon(
                                        i < entry.applicantRating.floor()
                                            ? Icons.star_rounded
                                            : (i < entry.applicantRating
                                                ? Icons.star_half_rounded
                                                : Icons.star_outline_rounded),
                                        size: 13,
                                        color: const Color(0xFFF59E0B),
                                      )),
                              const SizedBox(width: 4),
                              Text(
                                entry.applicantRating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151)),
                              ),
                            ],
                          ),
                        ],
                        if (entry.applicantExperience.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.work_outline_rounded,
                                  size: 11, color: Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              Text(entry.applicantExperience,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        if (entry.applicantMobile.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 11, color: Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              Text(entry.applicantMobile,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF374151),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        if (entry.applicantEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined,
                                  size: 11, color: Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(entry.applicantEmail,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF374151))),
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
            if (entry.applicantSkills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: entry.applicantSkills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED)
                                  .withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: const Color(0xFF7C3AED)
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Text(s,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF7C3AED),
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
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
                    backgroundColor:
                        const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    backgroundImage: entry.postedByPhoto.isNotEmpty
                        ? NetworkImage(entry.postedByPhoto)
                        : null,
                    child: entry.postedByPhoto.isEmpty
                        ? const Icon(Icons.person_outline_rounded,
                            size: 14, color: Color(0xFF7C3AED))
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.postedByName.isEmpty
                              ? 'Contractor'
                              : entry.postedByName,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827)),
                        ),
                        if (entry.postedByUserType.isNotEmpty)
                          Text(
                            entry.postedByUserType
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (entry.appliedAt != null)
                        DateLabel(label: 'Applied', date: formatDate(entry.appliedAt)),
                      if (entry.acceptedAt != null)
                        DateLabel(label: 'Accepted', date: formatDate(entry.acceptedAt)),
                      if (entry.completedAt != null)
                        DateLabel(label: 'Done', date: formatDate(entry.completedAt)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Application message ──────────────────────────────
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
                  const Icon(Icons.format_quote_rounded,
                      size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.applicationMessage,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontStyle: FontStyle.italic,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

          // ── Rejection reason ─────────────────────────────────
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
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: Color(0xFFDC2626)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rejection Reason',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626))),
                        const SizedBox(height: 2),
                        Text(
                          entry.rejectionReason,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF991B1B),
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Timeline (contractor view) ───────────────────────
          if (isContractorView)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (entry.appliedAt != null)
                    DateLabel(label: 'Applied', date: formatDate(entry.appliedAt)),
                  if (entry.acceptedAt != null)
                    DateLabel(label: 'Accepted', date: formatDate(entry.acceptedAt)),
                  if (entry.completedAt != null)
                    DateLabel(
                        label: 'Completed', date: formatDate(entry.completedAt)),
                  if (entry.rejectedAt != null)
                    DateLabel(label: 'Rejected', date: formatDate(entry.rejectedAt)),
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
