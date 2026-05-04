import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../create_job_screen.dart';
import '../job_applications_screen.dart';
import '../models/my_job.dart';
import '../widgets/my_job_card.dart';

// ── View ──────────────────────────────────────────────────────────────────────

class MyJobsView extends StatefulWidget {
  final String token;
  final String userType;

  const MyJobsView({super.key, required this.token, required this.userType});

  @override
  State<MyJobsView> createState() => _MyJobsViewState();
}

class _MyJobsViewState extends State<MyJobsView> {
  List<MyJob> _jobs = [];
  bool _loading = true;
  String? _error;
  int _total = 0;

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
    final result = await ApiService.fetchMyJobs(widget.token);
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final jobs = (data?['jobs'] as List? ?? []);
      final pagination = data?['pagination'] as Map<String, dynamic>?;
      setState(() {
        _jobs = jobs
            .map((j) => MyJob.fromJson(j as Map<String, dynamic>))
            .toList();
        _total = (pagination?['total'] as num?)?.toInt() ?? _jobs.length;
        _loading = false;
      });
    } else {
      setState(() {
        _error = (result['message'] ?? 'Failed to load jobs').toString();
        _loading = false;
      });
    }
  }

  Color get _primaryColor => widget.userType == 'sub_contractor'
      ? const Color(0xFF7C3AED)
      : const Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: _primaryColor));
    }

    if (_error != null) {
      return Center(
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
                  style: const TextStyle(color: Color(0xFF374151))),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Post New',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827))),
                      Text('Requirement',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _primaryColor)),
                      const SizedBox(height: 4),
                      Text(
                        '$_total published job${_total == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final created = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateJobScreen(userType: widget.userType),
                      ),
                    );
                    if (created == true) _load();
                  },
                  icon: const Icon(Icons.upload_rounded, size: 16),
                  label: const Text('CREATE JOB',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Section label
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 10),
              Text(
                'PUBLISHED JOBS (${_jobs.length})',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Empty state
          if (_jobs.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.post_add_rounded,
                          size: 36, color: _primaryColor),
                    ),
                    const SizedBox(height: 14),
                    const Text('No Jobs Posted Yet',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    const SizedBox(height: 6),
                    const Text('Tap CREATE JOB to post your first requirement.',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280)),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else
            ..._jobs.map((job) => MyJobCard(
                  job: job,
                  primaryColor: _primaryColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JobApplicationsScreen(
                          token: widget.token,
                          jobId: job.id,
                          jobTitle: job.workTitle,
                        ),
                      ),
                    );
                  },
                )),
        ],
      ),
    );
  }
}
