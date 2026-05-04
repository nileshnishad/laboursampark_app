import 'package:flutter/material.dart';

import '../../services/api_service.dart';

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
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _applications = [];

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
    final res = await ApiService.fetchJobApplications(
      token: widget.token,
      jobId: widget.jobId,
    );
    if (!mounted) return;
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>? ?? {};
      setState(() {
        _jobInfo = data['job'] as Map<String, dynamic>?;
        _summary = data['summary'] as Map<String, dynamic>?;
        _applications = (data['applications'] as List? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
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
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applications',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
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
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: Color(0xFFDC2626)),
                        const SizedBox(height: 12),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(color: Color(0xFF374151))),
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
                )
              : RefreshIndicator(
                  color: const Color(0xFF2563EB),
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                    children: [
                      // Job info card
                      if (_jobInfo != null) _JobInfoCard(job: _jobInfo!),
                      const SizedBox(height: 12),

                      // Summary chips
                      if (_summary != null) _SummaryRow(summary: _summary!),
                      const SizedBox(height: 14),

                      // Section label
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'APPLICANTS (${_applications.length})',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (_applications.isEmpty)
                        const _EmptyState()
                      else
                        ..._applications.map(
                          (app) => _ApplicationCard(
                            application: app,
                            token: widget.token,
                            statusColor: _statusColor(
                                (app['status'] ?? 'pending').toString()),
                            statusLabel: _statusLabel(
                                (app['status'] ?? 'pending').toString()),
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
  const _JobInfoCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final title = (job['workTitle'] ?? 'Untitled Job').toString();
    final status = (job['status'] ?? 'open').toString();
    final workersNeeded = (job['workersNeeded'] as num?)?.toInt() ?? 1;
    final budgetType = (job['budgetType'] ?? '').toString();
    final estimatedBudget = job['estimatedBudget'];
    final location = job['location'] as Map<String, dynamic>? ?? {};
    final area = (location['area'] ?? '').toString();
    final city = (location['city'] ?? '').toString();
    final state = (location['state'] ?? '').toString();
    final locationStr =
        [area, city, state].where((s) => s.isNotEmpty).join(', ');
    final skills = (job['requiredSkills'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
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
          color: isOpen
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE5E7EB),
          width: isOpen ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail if available
          if (images.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: Stack(
                children: [
                  Image.network(
                    images.first,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                              color: isOpen
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFF9CA3AF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isOpen ? 'OPEN' : 'CLOSED',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                            color: Color(0xFF111827)),
                      ),
                    ),
                    if (images.isEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                                  : const Color(0xFF6B7280)),
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
                          label: locationStr),
                    _InfoChip(
                        icon: Icons.people_outline_rounded,
                        label: '$workersNeeded worker${workersNeeded > 1 ? 's' : ''} needed'),
                    if (estimatedBudget != null)
                      _InfoChip(
                          icon: Icons.currency_rupee_rounded,
                          label:
                              '₹$estimatedBudget ${budgetType.isNotEmpty ? '($budgetType)' : ''}'),
                  ],
                ),

                // Skills
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skills
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: const Color(0xFFBFDBFE)),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1D4ED8)),
                              ),
                            ))
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
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: Color(0xFF374151))),
      ],
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final Map<String, dynamic> summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total', summary['total'] ?? 0, const Color(0xFF2563EB)),
      ('Pending', summary['pending'] ?? 0, const Color(0xFFF59E0B)),
      ('Accepted', summary['accepted'] ?? 0, const Color(0xFF059669)),
      ('Rejected', summary['rejected'] ?? 0, const Color(0xFFDC2626)),
    ];
    return Row(
      children: items
          .map(
            (e) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: (e.$3 as Color).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${e.$2}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: e.$3 as Color),
                    ),
                    Text(
                      e.$1 as String,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Application Card ──────────────────────────────────────────────────────────

class _ApplicationCard extends StatefulWidget {
  final Map<String, dynamic> application;
  final Color statusColor;
  final String statusLabel;
  final String token;
  final VoidCallback onRefresh;

  const _ApplicationCard({
    required this.application,
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

  Future<void> _connect(String enquiryId) async {
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
          content: Text(res['message'] ?? 'Connected successfully!'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Failed to connect'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _showCompleteDialog(String enquiryId, String applicantName) {
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
                  const Text(
                    'Mark as Completed',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rate $applicantName\'s work',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 20),

                  // Star rating
                  const Text('Rating',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151))),
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
                          onChanged: (v) =>
                              setSheetState(() => rating = v),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF92400E)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Feedback
                  const Text('Feedback',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'How was the work quality?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
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
                              ? 'Good work'
                              : feedbackController.text.trim(),
                        );
                        if (!mounted) return;
                        setState(() => _actionLoading = false);
                        if (res['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  res['message'] ?? 'Marked as completed!'),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                          widget.onRefresh();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  res['message'] ?? 'Failed to complete'),
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('CONFIRM COMPLETE',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
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

  @override
  Widget build(BuildContext context) {
    final application = widget.application;
    final statusColor = widget.statusColor;
    final statusLabel = widget.statusLabel;
    final enquiryId = (application['enquiryId'] ?? '').toString();
    final status = (application['status'] ?? 'pending').toString();
    final applicant =
        application['applicant'] as Map<String, dynamic>? ?? {};
    final name = (applicant['name'] ?? 'Unknown').toString();
    final email = (applicant['email'] ?? '').toString();
    final mobile = (applicant['mobile'] ?? '').toString();
    final userType = (applicant['userType'] ?? '').toString();
    final profilePhoto = (applicant['profilePhoto'] ?? '').toString();
    final rating = (applicant['rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (applicant['totalReviews'] as num?)?.toInt() ?? 0;
    final completedJobs =
        (applicant['completedJobs'] as num?)?.toInt() ?? 0;
    final availability = (applicant['availability'] as bool?) ?? false;
    final location =
        applicant['location'] as Map<String, dynamic>? ?? {};
    final city = (location['city'] ?? '').toString();
    final state = (location['state'] ?? '').toString();
    final locationStr =
        [city, state].where((s) => s.isNotEmpty).join(', ');
    final message = (application['message'] ?? '').toString();
    final appliedAt = application['appliedAt'] != null
        ? DateTime.tryParse(application['appliedAt'].toString())
        : null;

    String fmtDate(DateTime? dt) {
      if (dt == null) return '';
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }

    String typeLabel(String t) {
      switch (t) {
        case 'sub_contractor':
          return 'Sub-Contractor';
        case 'labour':
          return 'Labour';
        case 'contractor':
          return 'Contractor';
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          // Top row: photo + name + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: profilePhoto.isNotEmpty
                    ? NetworkImage(profilePhoto)
                    : null,
                child: profilePhoto.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151)),
                      )
                    : null,
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
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            typeLabel(userType),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151)),
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
                          const Text('Available',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF059669))),
                        ],
                      ],
                    ),
                    if (locationStr.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 2),
                          Text(locationStr,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor),
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
                      '${rating.toStringAsFixed(1)} ($totalReviews reviews)'),
              const SizedBox(width: 10),
              _StatChip(
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF059669),
                  label: '$completedJobs jobs done'),
            ],
          ),

          if (mobile.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.phone_outlined,
                  size: 13, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(mobile,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF374151))),
            ]),
          ],
          if (email.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.email_outlined,
                  size: 13, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(email,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF374151)),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
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
                  const Icon(Icons.format_quote_rounded,
                      size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(message,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF374151))),
                  ),
                ],
              ),
            ),
          ],

          if (appliedAt != null) ...[
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              const Icon(Icons.access_time_rounded,
                  size: 12, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 3),
              Text('Applied ${fmtDate(appliedAt)}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF))),
            ]),
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
                      strokeWidth: 2.5, color: Color(0xFF2563EB)),
                ),
              )
            else if (status == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _connect(enquiryId),
                  icon: const Icon(Icons.handshake_outlined, size: 18),
                  label: const Text('CONNECT & ACCEPT',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              )
            else if (status == 'accepted')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCompleteDialog(enquiryId, name),
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      size: 18),
                  label: const Text('MARK AS COMPLETED',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatChip(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: Color(0xFF374151))),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 56, color: Color(0xFFD1D5DB)),
            SizedBox(height: 14),
            Text('No Applications Yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151))),
            SizedBox(height: 6),
            Text('Applications will appear here once\nsomeone applies to this job.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
