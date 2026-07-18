import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/widgets/loading_skeleton.dart';
import '../../common/models/skill_model.dart';
import '../../l10n/app_localizations.dart';
import '../../common/utils/skill_display_utils.dart';
import '../../services/api_service.dart';
import '../../services/skills_service.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String token;
  final String jobId;
  final String jobTitle;

  const JobApplicationsScreen({
    super.key,
    required this.token,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _jobInfo;
  List<Map<String, dynamic>> _applications = [];
  List<SkillModel> _allSkills = [];
  String _statusFilter = 'all';

  void _debugPrintChunked(String tag, String text) {
    const chunkSize = 900;
    for (var i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      debugPrint('$tag ${text.substring(i, end)}');
    }
  }

  void _logApplicantsPayload(Map<String, dynamic> res) {
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final apps = (data['applications'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final pending = apps
        .where((e) => (e['status'] ?? 'pending').toString() == 'pending')
        .length;
    final accepted = apps
        .where((e) => (e['status'] ?? '').toString() == 'accepted')
        .length;
    final completed = apps
        .where((e) => (e['status'] ?? '').toString() == 'completed')
        .toList();

    debugPrint(
      '[Applicants API][Status Count] total=${apps.length} pending=$pending accepted=$accepted completed=${completed.length}',
    );

    num? readContractorRating(Map<String, dynamic> app) {
      final review = app['review'] as Map<String, dynamic>? ?? {};
      final contractorReviewToApplicant =
          app['contractorReviewToApplicant'] as Map<String, dynamic>? ?? {};
      return (app['rating'] as num?) ??
          (app['reviewRating'] as num?) ??
          (app['contractorRating'] as num?) ??
          (contractorReviewToApplicant['rating'] as num?) ??
          (review['rating'] as num?);
    }

    num? readLabourRating(Map<String, dynamic> app) {
      final applicantReviewToContractor =
          app['applicantReviewToContractor'] as Map<String, dynamic>? ?? {};
      final myFeedback =
          app['myFeedback'] as Map<String, dynamic>? ??
          app['applicantFeedback'] as Map<String, dynamic>? ??
          app['feedbackFromApplicant'] as Map<String, dynamic>? ??
          app['labourFeedback'] as Map<String, dynamic>? ??
          <String, dynamic>{};
      if (applicantReviewToContractor.isNotEmpty) {
        return applicantReviewToContractor['rating'] as num?;
      }
      return (myFeedback['rating'] as num?) ??
          (app['myFeedbackRating'] as num?) ??
          (app['applicantRatingToContractor'] as num?);
    }

    if (completed.isNotEmpty) {
      for (final app in completed) {
        final enquiryId = (app['enquiryId'] ?? '').toString();
        final contractorRating = readContractorRating(app);
        final labourRating = readLabourRating(app);
        debugPrint(
          '[Applicants API][Rating Check] enquiryId=$enquiryId contractorRating=${contractorRating ?? 'null'} labourRating=${labourRating ?? 'null'}',
        );
      }
    }

    if (completed.isNotEmpty) {
      final prettyCompleted = const JsonEncoder.withIndent(
        '  ',
      ).convert(completed);
      _debugPrintChunked(
        '[Applicants API][Completed Applications]',
        prettyCompleted,
      );
      return;
    }

    if (apps.isNotEmpty) {
      final prettyFirst = const JsonEncoder.withIndent(
        '  ',
      ).convert(apps.first);
      _debugPrintChunked(
        '[Applicants API][First Application Full]',
        prettyFirst,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final result = await SkillsService.getAllSkills();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _allSkills = (result['skills'] as List<SkillModel>? ?? []);
      });
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    debugPrint(
      '[Applicants API][Request] jobId=${widget.jobId} tokenLen=${widget.token.length}',
    );

    final res = await ApiService.fetchJobApplications(
      token: widget.token,
      jobId: widget.jobId,
    );

    final success = res['success'] == true;
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final apps = (data['applications'] as List? ?? []);
    debugPrint(
      '[Applicants API][Response] success=$success message=${res['message']} totalApplications=${apps.length}',
    );
    if (apps.isNotEmpty) {
      final first = apps.first;
      if (first is Map<String, dynamic>) {
        debugPrint(
          '[Applicants API][First Application] keys=${first.keys.toList()}',
        );
        debugPrint(
          '[Applicants API][First Application] status=${first['status']} enquiryId=${first['enquiryId']}',
        );
      }
    }
    _logApplicantsPayload(res);

    if (!mounted) return;
    if (success) {
      setState(() {
        _jobInfo = data['job'] as Map<String, dynamic>?;
        _applications = apps.map((e) => e as Map<String, dynamic>).toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = (res['message'] ?? 'Failed to load applications').toString();
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'all':
        return const Color(0xFF4B5563);
      case 'accepted':
        return const Color(0xFF059669);
      case 'completed':
        return const Color(0xFF2563EB);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'withdrawn':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFF59E0B); // pending
    }
  }

  String _statusLabel(String status) {
    final loc = AppLocalizations.of(context);
    switch (status) {
      case 'accepted':
        return loc.summaryAccepted;
      case 'completed':
        return loc.completed;
      case 'rejected':
        return loc.summaryRejected;
      case 'withdrawn':
        return loc.withdrawn;
      default:
        return loc.summaryPending;
    }
  }

  int _statusCount(String status) {
    if (status == 'all') return _applications.length;
    return _applications
        .where((app) => (app['status'] ?? 'pending').toString() == status)
        .length;
  }

  List<Map<String, dynamic>> _filteredApplications() {
    if (_statusFilter == 'all') return _applications;
    return _applications
        .where(
          (app) => (app['status'] ?? 'pending').toString() == _statusFilter,
        )
        .toList();
  }

  String _filterLabel(AppLocalizations loc, String status) {
    switch (status) {
      case 'pending':
        return loc.summaryPending;
      case 'accepted':
        return loc.summaryAccepted;
      case 'completed':
        return loc.completed;
      case 'rejected':
        return loc.summaryRejected;
      case 'withdrawn':
        return loc.withdrawn;
      default:
        return loc.allLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final filteredApplications = _filteredApplications();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.applicationsTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              widget.jobTitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const LoadingSkeleton(
              type: LoadingSkeletonType.applicationPage,
              itemCount: 1,
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(loc.retry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF2563EB),
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                children: [
                  // Job info card
                  if (_jobInfo != null)
                    _JobInfoCard(job: _jobInfo!, allSkills: _allSkills),
                  const SizedBox(height: 14),

                  // Status filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [
                            'all',
                            'pending',
                            'accepted',
                            'completed',
                            'rejected',
                            'withdrawn',
                          ].map((status) {
                            final isActive = _statusFilter == status;
                            final color = _statusColor(status);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: isActive,
                                showCheckmark: false,
                                label: Text(
                                  '${_filterLabel(loc, status)} (${_statusCount(status)})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? color
                                        : const Color(0xFF4B5563),
                                  ),
                                ),
                                onSelected: (_) {
                                  setState(() => _statusFilter = status);
                                },
                                selectedColor: color.withValues(alpha: 0.14),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: isActive
                                      ? color.withValues(alpha: 0.6)
                                      : const Color(0xFFE5E7EB),
                                  width: isActive ? 1.3 : 1,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Section label
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
                        _statusFilter == 'all'
                            ? '${loc.applicantsCount} (${filteredApplications.length})'
                            : '${_filterLabel(loc, _statusFilter)} ${loc.applicantsCount} (${filteredApplications.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_applications.isEmpty)
                    const _EmptyState()
                  else if (filteredApplications.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 26),
                        child: Text(
                          'No ${_filterLabel(loc, _statusFilter).toLowerCase()} applications',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredApplications.map(
                      (app) => _ApplicationCard(
                        application: app,
                        token: widget.token,
                        allSkills: _allSkills,
                        localeCode: Localizations.localeOf(
                          context,
                        ).languageCode,
                        statusColor: _statusColor(
                          (app['status'] ?? 'pending').toString(),
                        ),
                        statusLabel: _statusLabel(
                          (app['status'] ?? 'pending').toString(),
                        ),
                        onRefresh: _load,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

// ── Job Info Card ─────────────────────────────────────────────────────────────

class _JobInfoCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final List<SkillModel> allSkills;
  const _JobInfoCard({required this.job, required this.allSkills});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final title = (job['workTitle'] ?? loc.untitledJob).toString();
    final status = (job['status'] ?? 'open').toString();
    final workersNeeded = (job['workersNeeded'] as num?)?.toInt() ?? 1;
    final budgetType = (job['budgetType'] ?? '').toString();
    final estimatedBudget = job['estimatedBudget'];
    final location = job['location'] as Map<String, dynamic>? ?? {};
    final area = (location['area'] ?? '').toString();
    final city = (location['city'] ?? '').toString();
    final state = (location['state'] ?? '').toString();
    final locationStr = [
      area,
      city,
      state,
    ].where((s) => s.isNotEmpty).join(', ');
    final skills = resolveSkillDisplayNames(
      skillIds: (job['requiredSkills'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      skills: allSkills,
      localeCode: Localizations.localeOf(context).languageCode,
    );
    final images = (job['images'] as List? ?? [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    final isOpen = status == 'open';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOpen ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
          width: isOpen ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status (if no image)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (images.isEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOpen ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOpen
                                ? const Color(0xFF059669)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Info chips row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (locationStr.isNotEmpty)
                      _InfoChip(
                        icon: Icons.location_on_outlined,
                        label: locationStr,
                      ),
                    _InfoChip(
                      icon: Icons.people_outline_rounded,
                      label:
                          '$workersNeeded ${workersNeeded > 1 ? loc.workersLabel : loc.workerLabel} ${loc.workersNeededLabel}',
                    ),
                    if (estimatedBudget != null)
                      _InfoChip(
                        icon: Icons.currency_rupee_rounded,
                        label:
                            '₹$estimatedBudget ${budgetType.isNotEmpty ? '($budgetType)' : ''}',
                      ),
                  ],
                ),

                // Skills
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skills
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF6B7280)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
        ),
      ],
    );
  }
}

// ── Application Card ──────────────────────────────────────────────────────────

class _ApplicationCard extends StatefulWidget {
  final Map<String, dynamic> application;
  final List<SkillModel> allSkills;
  final String localeCode;
  final Color statusColor;
  final String statusLabel;
  final String token;
  final VoidCallback onRefresh;

  const _ApplicationCard({
    required this.application,
    required this.allSkills,
    required this.localeCode,
    required this.statusColor,
    required this.statusLabel,
    required this.token,
    required this.onRefresh,
  });

  @override
  State<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<_ApplicationCard> {
  bool _actionLoading = false;
  final ScrollController _cardScrollController = ScrollController();

  @override
  void dispose() {
    _cardScrollController.dispose();
    super.dispose();
  }

  Future<void> _connect(String enquiryId) async {
    final loc = AppLocalizations.of(context);
    setState(() => _actionLoading = true);
    final res = await ApiService.connectEnquiry(
      token: widget.token,
      enquiryId: enquiryId,
    );
    if (!mounted) return;
    setState(() => _actionLoading = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? loc.connectedSuccessfully),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? loc.failedToConnect),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _showCompleteDialog(String enquiryId, String applicantName) {
    final loc = AppLocalizations.of(context);
    double rating = 3.5;
    final feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final mq = MediaQuery.of(ctx);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: mq.viewInsets.bottom + mq.padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.markCompletedTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.rateWorkLabel(applicantName),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Star rating
                  Text(
                    loc.ratingLabelSmall,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: rating,
                          min: 1,
                          max: 5,
                          divisions: 8,
                          activeColor: const Color(0xFFF59E0B),
                          onChanged: (v) => setSheetState(() => rating = v),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Feedback
                  Text(
                    loc.feedbackLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: loc.feedbackHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        setState(() => _actionLoading = true);
                        final res = await ApiService.completeEnquiry(
                          token: widget.token,
                          enquiryId: enquiryId,
                          rating: rating,
                          feedback: feedbackController.text.trim().isEmpty
                              ? loc.goodWorkDefault
                              : feedbackController.text.trim(),
                        );
                        if (!mounted) return;
                        setState(() => _actionLoading = false);
                        if (res['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                res['message'] ??
                                    loc.markedCompletedSuccessfully,
                              ),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                          widget.onRefresh();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                res['message'] ?? loc.failedToComplete,
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        loc.confirmComplete,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static IconData _statusIcon(String s) {
    switch (s) {
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'completed':
        return Icons.verified_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'withdrawn':
        return Icons.undo_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  static Color _userTypeColor(String t) {
    switch (t.toLowerCase()) {
      case 'contractor':
        return const Color(0xFF059669);
      case 'sub_contractor':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final application = widget.application;
    final statusColor = widget.statusColor;
    final statusLabel = widget.statusLabel;
    final enquiryId = (application['enquiryId'] ?? '').toString();
    final status = (application['status'] ?? 'pending').toString();
    final applicant = application['applicant'] as Map<String, dynamic>? ?? {};
    final name = (applicant['name'] ?? loc.unknownApplicant).toString();
    final email = (applicant['email'] ?? '').toString();
    final mobile = (applicant['mobile'] ?? '').toString();
    final userType = (applicant['userType'] ?? '').toString();
    final profilePhoto = (applicant['profilePhoto'] ?? '').toString();
    final applicantRating = (applicant['rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (applicant['totalReviews'] as num?)?.toInt() ?? 0;
    final completedJobs = (applicant['completedJobs'] as num?)?.toInt() ?? 0;
    final availability = (applicant['availability'] as bool?) ?? false;
    final location = applicant['location'] as Map<String, dynamic>? ?? {};
    final city = (location['city'] ?? '').toString();
    final state = (location['state'] ?? '').toString();
    final locationStr = [city, state].where((s) => s.isNotEmpty).join(', ');
    final rawSkills =
        (application['skills'] as List?) ??
        (application['applicantSkills'] as List?) ??
        (applicant['skills'] as List?) ??
        const [];
    final applicantSkillIds = rawSkills
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    final localizedApplicantSkills = resolveSkillDisplayNames(
      skillIds: applicantSkillIds,
      skills: widget.allSkills,
      localeCode: widget.localeCode,
    );
    final message = (application['message'] ?? '').toString();
    final appliedAt = application['appliedAt'] != null
        ? DateTime.tryParse(application['appliedAt'].toString())
        : null;
    final review = application['review'] as Map<String, dynamic>? ?? {};
    final contractorReviewToApplicant =
        application['contractorReviewToApplicant'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final applicantReviewToContractor =
        application['applicantReviewToContractor'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final myFeedback = application['myFeedback'] is Map<String, dynamic>
        ? application['myFeedback'] as Map<String, dynamic>
        : application['applicantFeedback'] is Map<String, dynamic>
        ? application['applicantFeedback'] as Map<String, dynamic>
        : application['feedbackFromApplicant'] is Map<String, dynamic>
        ? application['feedbackFromApplicant'] as Map<String, dynamic>
        : application['labourFeedback'] is Map<String, dynamic>
        ? application['labourFeedback'] as Map<String, dynamic>
        : <String, dynamic>{};
    final contractorRating =
        (application['rating'] as num?)?.toDouble() ??
        (application['reviewRating'] as num?)?.toDouble() ??
        (application['contractorRating'] as num?)?.toDouble() ??
        (contractorReviewToApplicant['rating'] as num?)?.toDouble() ??
        (review['rating'] as num?)?.toDouble();
    final contractorFeedback =
        (application['feedback'] ??
                application['reviewFeedback'] ??
                application['contractorFeedback'] ??
                contractorReviewToApplicant['feedback'] ??
                review['feedback'] ??
                '')
            .toString()
            .trim();
    final labourRating =
        (applicantReviewToContractor['rating'] as num?)?.toDouble() ??
        (myFeedback['rating'] as num?)?.toDouble() ??
        (application['myFeedbackRating'] as num?)?.toDouble() ??
        (application['applicantRatingToContractor'] as num?)?.toDouble();
    final labourFeedback =
        (applicantReviewToContractor['feedback'] ??
                myFeedback['feedback'] ??
                application['myFeedbackText'] ??
                application['applicantFeedbackText'] ??
                application['feedbackByApplicant'] ??
                application['labourFeedbackText'] ??
                '')
            .toString()
            .trim();

    String fmtDate(DateTime? dt) {
      if (dt == null) return '';
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }

    String typeLabel(String t) {
      switch (t) {
        case 'sub_contractor':
          return loc.subcontractorRoleTitle;
        case 'labour':
          return loc.labourRoleTitle;
        case 'contractor':
          return loc.contractorRoleTitle;
        default:
          return t;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Scrollbar(
          controller: _cardScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _cardScrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: photo + name + status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _userTypeColor(userType),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFF0F0F0),
                        backgroundImage: profilePhoto.isNotEmpty
                            ? NetworkImage(profilePhoto)
                            : null,
                        child: profilePhoto.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  typeLabel(userType),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                              if (availability) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  loc.availableLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (locationStr.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  locationStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon(status),
                            size: 13,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),

                // Stats
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.star_rounded,
                      color: const Color(0xFFF59E0B),
                      label:
                          '${applicantRating.toStringAsFixed(1)} ($totalReviews ${loc.reviewsCount})',
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF059669),
                      label: '$completedJobs ${loc.jobsDone}',
                    ),
                  ],
                ),

                if (localizedApplicantSkills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: localizedApplicantSkills
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                if (mobile.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mobile,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 13,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF374151),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                if (message.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (contractorRating != null ||
                    contractorFeedback.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.grade_rounded,
                              size: 14,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              loc.myFeedbackLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF065F46),
                              ),
                            ),
                            if (contractorRating != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                contractorRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (contractorFeedback.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            contractorFeedback,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (status == 'completed' &&
                    (labourRating != null || labourFeedback.isNotEmpty)) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.rate_review_rounded,
                              size: 14,
                              color: Color(0xFF1D4ED8),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              loc.feedbackFromLabourLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            if (labourRating != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                labourRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (labourFeedback.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            labourFeedback,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (appliedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${loc.appliedOn} ${fmtDate(appliedAt)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Action buttons ────────────────────────────────────
                if (status == 'pending' || status == 'accepted') ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 12),
                  if (_actionLoading)
                    const Center(
                      child: SizedBox(
                        height: 36,
                        width: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    )
                  else if (status == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _connect(enquiryId),
                        icon: const Icon(Icons.handshake_outlined, size: 20),
                        label: Text(
                          loc.connectAccept,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  else if (status == 'accepted')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showCompleteDialog(enquiryId, name),
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                        ),
                        label: Text(
                          loc.markCompleted,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: const Color(
                            0xFF059669,
                          ).withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline_rounded,
              size: 56,
              color: Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 14),
            Text(
              loc.noApplicationsYet,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              loc.noApplicationsHint,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
