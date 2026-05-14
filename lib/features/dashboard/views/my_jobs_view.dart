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
  String _filter = 'all'; // 'all' | 'live' | 'hidden'

  // Cache filtered list so it is computed once per build, not multiple times.
  late List<MyJob> _filtered;

  List<MyJob> _applyFilter() {
    if (_filter == 'live') return _jobs.where((j) => j.isActive).toList();
    if (_filter == 'hidden') return _jobs.where((j) => !j.isActive).toList();
    return List.of(_jobs);
  }

  @override
  void initState() {
    super.initState();
    _filtered = [];
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
      _jobs = jobs
          .map((j) => MyJob.fromJson(j as Map<String, dynamic>))
          .toList();
      _total = (pagination?['total'] as num?)?.toInt() ?? _jobs.length;
      _filtered = _applyFilter();
      setState(() => _loading = false);
    } else {
      setState(() {
        _error = (result['message'] ?? 'Failed to load jobs').toString();
        _loading = false;
      });
    }
  }

  void _setFilter(String f) {
    setState(() {
      _filter = f;
      _filtered = _applyFilter();
    });
  }

  Color get _primaryColor {
    if (widget.userType == 'sub_contractor') {
      return const Color(0xFF7C3AED); // Purple for sub-contractor
    } else if (widget.userType == 'labour') {
      return const Color(0xFF2563EB); // Blue for labour
    } else {
      return const Color(0xFF059669); // Green for contractor
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

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
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8))),
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
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        // slots: 0=header, 1=gap, 2=section row, 3=gap, 4..N=cards (or 1 empty state)
        itemCount: 4 + (_filtered.isEmpty ? 1 : _filtered.length),
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader();
          if (index == 1) return const SizedBox(height: 12);
          if (index == 2) return _buildSectionRow();
          if (index == 3) return const SizedBox(height: 10);
          if (_filtered.isEmpty) return _buildEmptyState();
          return _buildJobCard(_filtered[index - 4]);
        },
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
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
                Text('Post New',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text('Requirement',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor)),
                const SizedBox(height: 4),
                Text(
                  '$_total published job${_total == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => CreateJobScreen(userType: widget.userType),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section row with filter chips ───────────────────────────────────────────

  static const _filterHints = {
    'all':    '● All your posted jobs are listed here.',
    'live':   '✓ Live jobs are visible to applicants & accepting applications.',
    'hidden': '⊘ Hidden jobs are only visible to you — applicants cannot see or apply.',
  };

  Widget _buildSectionRow() {
    final hint = _filterHints[_filter]!;
    final hintColor = _filter == 'live'
        ? const Color(0xFF059669)
        : _filter == 'hidden'
            ? const Color(0xFF6B7280)
            : _primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                  color: _primaryColor, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 10),
            Text(
              'PUBLISHED JOBS (${_filtered.length})',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.5),
            ),
            const Spacer(),
            _FilterChip(
              label: 'All',
              active: _filter == 'all',
              color: _primaryColor,
              onTap: () => _setFilter('all'),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'Live',
              active: _filter == 'live',
              color: const Color(0xFF059669),
              onTap: () => _setFilter('live'),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'Hidden',
              active: _filter == 'hidden',
              color: const Color(0xFF6B7280),
              onTap: () => _setFilter('hidden'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            hint,
            key: ValueKey(_filter),
            style: TextStyle(
              fontSize: 11,
              color: hintColor.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final isAll = _filter == 'all';
    final isLive = _filter == 'live';
    return Container(
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
              child: Icon(
                isAll
                    ? Icons.post_add_rounded
                    : isLive
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                size: 36,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isAll
                  ? 'No Jobs Posted Yet'
                  : isLive
                      ? 'No Live Jobs'
                      : 'No Hidden Jobs',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              isAll
                  ? 'Tap CREATE JOB to post your first requirement.'
                  : 'No jobs match this filter.',
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Job card ─────────────────────────────────────────────────────────────────

  Widget _buildJobCard(MyJob job) {
    return MyJobCard(
      key: ValueKey(job.id),
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
      onEditTap: () async {
        final updated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => CreateJobScreen(
              userType: widget.userType,
              existingJob: job,
            ),
          ),
        );
        if (updated == true) _load();
      },
      onToggleActivation: () => ApiService.toggleJobActivation(
        token: widget.token,
        jobId: job.id,
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : color,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
