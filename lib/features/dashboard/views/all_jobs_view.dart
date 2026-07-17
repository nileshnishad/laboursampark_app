import 'package:flutter/material.dart';

import '../../../common/widgets/loading_skeleton.dart';
import '../../../services/api_service.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class _JobListing {
  final String jobId;
  final String workTitle;
  final String description;
  final List<String> requiredSkills;
  final int workersNeeded;
  final num? estimatedBudget;
  final List<String> images;
  final String city;
  final String area;
  final String state;
  final int totalApplications;
  final DateTime? postedAt;
  final String postedByName;
  final String postedByUserType;
  final String? postedByPhoto;
  final int postedByRating;

  const _JobListing({
    required this.jobId,
    required this.workTitle,
    required this.description,
    required this.requiredSkills,
    required this.workersNeeded,
    required this.estimatedBudget,
    required this.images,
    required this.city,
    required this.area,
    required this.state,
    required this.totalApplications,
    required this.postedAt,
    required this.postedByName,
    required this.postedByUserType,
    required this.postedByPhoto,
    required this.postedByRating,
  });

  factory _JobListing.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : <String, dynamic>{};
    final by = json['postedBy'] is Map<String, dynamic>
        ? json['postedBy'] as Map<String, dynamic>
        : <String, dynamic>{};
    return _JobListing(
      jobId: (json['jobId'] ?? '').toString(),
      workTitle: (json['workTitle'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      requiredSkills: (json['requiredSkills'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      workersNeeded: (json['workersNeeded'] as num?)?.toInt() ?? 1,
      estimatedBudget: json['estimatedBudget'] as num?,
      images: (json['images'] as List? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      city: (loc['city'] ?? '').toString(),
      area: (loc['area'] ?? '').toString(),
      state: (loc['state'] ?? '').toString(),
      totalApplications: (json['totalApplications'] as num?)?.toInt() ?? 0,
      postedAt: DateTime.tryParse((json['postedAt'] ?? '').toString()),
      postedByName: (by['name'] ?? '').toString(),
      postedByUserType: (by['userType'] ?? '').toString(),
      postedByPhoto: by['profilePhoto']?.toString(),
      postedByRating: (by['rating'] as num?)?.toInt() ?? 0,
    );
  }
}

class _AppliedJobEntry {
  final String enquiryId;
  final String applicationStatus;
  final String message;
  final DateTime? appliedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? completedAt;
  final String? rejectionReason;

  final String jobId;
  final String workTitle;
  final String description;
  final List<String> requiredSkills;
  final int workersNeeded;
  final num? estimatedBudget;
  final List<String> images;
  final String city;
  final String area;
  final String state;
  final String address;
  final String jobStatus;
  final DateTime? postedAt;

  final num? reviewRating;
  final String? reviewFeedback;
  final num? myFeedbackRating;
  final String? myFeedbackText;
  final bool feedbackSubmitted;

  final String postedByName;
  final String postedByUserType;
  final String? postedByPhoto;
  final num postedByRating;
  final String postedByCity;
  final String postedByState;

  const _AppliedJobEntry({
    required this.enquiryId,
    required this.applicationStatus,
    required this.message,
    required this.appliedAt,
    required this.acceptedAt,
    required this.rejectedAt,
    required this.completedAt,
    required this.rejectionReason,
    required this.jobId,
    required this.workTitle,
    required this.description,
    required this.requiredSkills,
    required this.workersNeeded,
    required this.estimatedBudget,
    required this.images,
    required this.city,
    required this.area,
    required this.state,
    required this.address,
    required this.jobStatus,
    required this.postedAt,
    required this.reviewRating,
    required this.reviewFeedback,
    required this.myFeedbackRating,
    required this.myFeedbackText,
    required this.feedbackSubmitted,
    required this.postedByName,
    required this.postedByUserType,
    required this.postedByPhoto,
    required this.postedByRating,
    required this.postedByCity,
    required this.postedByState,
  });

  factory _AppliedJobEntry.fromJson(Map<String, dynamic> json) {
    final job = json['job'] is Map<String, dynamic>
        ? json['job'] as Map<String, dynamic>
        : <String, dynamic>{};
    final loc = job['location'] is Map<String, dynamic>
        ? job['location'] as Map<String, dynamic>
        : <String, dynamic>{};
    final by = json['postedBy'] is Map<String, dynamic>
        ? json['postedBy'] as Map<String, dynamic>
        : <String, dynamic>{};
    final byLoc = by['location'] is Map<String, dynamic>
        ? by['location'] as Map<String, dynamic>
        : <String, dynamic>{};
    return _AppliedJobEntry(
      enquiryId: (json['enquiryId'] ?? '').toString(),
      applicationStatus: (json['applicationStatus'] ?? 'pending').toString(),
      message: (json['message'] ?? '').toString(),
      appliedAt: DateTime.tryParse((json['appliedAt'] ?? '').toString()),
      acceptedAt: DateTime.tryParse((json['acceptedAt'] ?? '').toString()),
      rejectedAt: DateTime.tryParse((json['rejectedAt'] ?? '').toString()),
      completedAt: DateTime.tryParse((json['completedAt'] ?? '').toString()),
      rejectionReason: json['rejectionReason']?.toString(),
      jobId: (job['jobId'] ?? '').toString(),
      workTitle: (job['workTitle'] ?? '').toString(),
      description: (job['description'] ?? '').toString(),
      requiredSkills: (job['requiredSkills'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      workersNeeded: (job['workersNeeded'] as num?)?.toInt() ?? 1,
      estimatedBudget: job['estimatedBudget'] as num?,
      images: (job['images'] as List? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      city: (loc['city'] ?? '').toString(),
      area: (loc['area'] ?? '').toString(),
      state: (loc['state'] ?? '').toString(),
      address: (loc['address'] ?? '').toString(),
      jobStatus: (job['jobStatus'] ?? '').toString(),
      postedAt: DateTime.tryParse((job['postedAt'] ?? '').toString()),
      reviewRating: (json['review'] is Map
          ? (json['review'] as Map<String, dynamic>)['rating'] as num?
          : null),
      reviewFeedback: (json['review'] is Map
          ? (json['review'] as Map<String, dynamic>)['feedback']?.toString()
          : null),
      myFeedbackRating: (json['myFeedback'] is Map
          ? (json['myFeedback'] as Map<String, dynamic>)['rating'] as num?
          : null),
      myFeedbackText: (json['myFeedback'] is Map
          ? (json['myFeedback'] as Map<String, dynamic>)['feedback']?.toString()
          : null),
      feedbackSubmitted: (json['feedbackSubmitted'] as bool?) ?? false,
      postedByName: (by['name'] ?? '').toString(),
      postedByUserType: (by['userType'] ?? '').toString(),
      postedByPhoto: by['profilePhoto']?.toString(),
      postedByRating: (by['rating'] as num?) ?? 0,
      postedByCity: (byLoc['city'] ?? '').toString(),
      postedByState: (byLoc['state'] ?? '').toString(),
    );
  }
}

// ── AllJobsView ───────────────────────────────────────────────────────────────

class AllJobsView extends StatefulWidget {
  final String token;
  final String userType;
  final bool subscriptionActive;

  const AllJobsView({
    super.key,
    required this.token,
    required this.userType,
    this.subscriptionActive = false,
  });

  @override
  State<AllJobsView> createState() => _AllJobsViewState();
}

class _AllJobsViewState extends State<AllJobsView> {
  // Available jobs
  List<_JobListing> _jobs = [];
  bool _loading = true;
  String? _error;
  int _total = 0;

  // Applied sub-tab data
  List<_AppliedJobEntry> _pendingJobs = [];
  bool _pendingLoading = false;
  String? _pendingError;
  bool _pendingLoaded = false;

  List<_AppliedJobEntry> _acceptedJobs = [];
  bool _acceptedLoading = false;
  String? _acceptedError;
  bool _acceptedLoaded = false;

  List<_AppliedJobEntry> _completedJobs = [];
  bool _completedLoading = false;
  String? _completedError;
  bool _completedLoaded = false;

  int _appliedTotal = 0;

  // 'available' | 'applied'
  String _mainTab = 'available';
  // 'pending' | 'accepted' | 'completed'
  String _appliedSubTab = 'pending';

  @override
  void initState() {
    super.initState();
    _loadAvailable();
    _loadPending();
  }

  // ── Loaders ──────────────────────────────────────────────────────────────────
  Future<void> _loadAvailable() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.fetchAllJobs(widget.token);
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final jobsList = (data?['jobs'] as List? ?? []);
      final pagination = data?['pagination'] as Map<String, dynamic>?;
      setState(() {
        _jobs = jobsList
            .map((j) => _JobListing.fromJson(j as Map<String, dynamic>))
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

  Future<void> _loadPending() async {
    setState(() {
      _pendingLoading = true;
      _pendingError = null;
    });
    final result = await ApiService.fetchAllAppliedJobs(widget.token);
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final list = (data?['appliedJobs'] as List? ?? []);
      final summary = data?['summary'] as Map<String, dynamic>? ?? {};
      setState(() {
        _pendingJobs = list
            .map((j) => _AppliedJobEntry.fromJson(j as Map<String, dynamic>))
            .toList();
        _appliedTotal =
            (summary['total'] as num?)?.toInt() ?? _pendingJobs.length;
        _pendingLoading = false;
        _pendingLoaded = true;
      });
    } else {
      setState(() {
        _pendingError = (result['message'] ?? 'Failed to load pending jobs')
            .toString();
        _pendingLoading = false;
        _pendingLoaded = true;
      });
    }
  }

  Future<void> _loadAccepted() async {
    setState(() {
      _acceptedLoading = true;
      _acceptedError = null;
    });
    final result = await ApiService.fetchAllAcceptedJobs(widget.token);
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final list = (data?['acceptedJobs'] as List? ?? []);
      setState(() {
        _acceptedJobs = list
            .map((j) => _AppliedJobEntry.fromJson(j as Map<String, dynamic>))
            .toList();
        _acceptedLoading = false;
        _acceptedLoaded = true;
      });
    } else {
      setState(() {
        _acceptedError = (result['message'] ?? 'Failed to load accepted jobs')
            .toString();
        _acceptedLoading = false;
        _acceptedLoaded = true;
      });
    }
  }

  Future<void> _loadCompleted() async {
    setState(() {
      _completedLoading = true;
      _completedError = null;
    });
    final result = await ApiService.fetchAllCompletedJobs(widget.token);
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final list = (data?['completedJobs'] as List? ?? []);
      setState(() {
        _completedJobs = list
            .map((j) => _AppliedJobEntry.fromJson(j as Map<String, dynamic>))
            .toList();
        _completedLoading = false;
        _completedLoaded = true;
      });
    } else {
      setState(() {
        _completedError = (result['message'] ?? 'Failed to load completed jobs')
            .toString();
        _completedLoading = false;
        _completedLoaded = true;
      });
    }
  }

  // ── Tab switching ─────────────────────────────────────────────────────────────
  void _setMainTab(String tab) {
    if (_mainTab == tab) return;
    setState(() => _mainTab = tab);
    if (tab == 'applied' && !_pendingLoaded && !_pendingLoading) {
      _loadPending();
    }
  }

  void _setAppliedSubTab(String sub) {
    if (_appliedSubTab == sub) return;
    setState(() => _appliedSubTab = sub);
    if (sub == 'pending' && !_pendingLoaded && !_pendingLoading) {
      _loadPending();
    } else if (sub == 'accepted' && !_acceptedLoaded && !_acceptedLoading) {
      _loadAccepted();
    } else if (sub == 'completed' && !_completedLoaded && !_completedLoading) {
      _loadCompleted();
    }
  }

  Future<void> _onRefresh() async {
    if (_mainTab == 'available') {
      await _loadAvailable();
    } else {
      if (_appliedSubTab == 'pending') {
        _pendingLoaded = false;
        await _loadPending();
      } else if (_appliedSubTab == 'accepted') {
        _acceptedLoaded = false;
        await _loadAccepted();
      } else {
        _completedLoaded = false;
        await _loadCompleted();
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isAvailable = _mainTab == 'available';

    if (isAvailable && _loading && _jobs.isEmpty) {
      return const LoadingSkeleton(
        type: LoadingSkeletonType.availableJobCard,
        itemCount: 3,
      );
    }

    if (isAvailable && _error != null && _jobs.isEmpty) {
      return Center(
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
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _onRefresh,
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
      );
    }

    return Column(
      children: [
        // ── Sticky header ─────────────────────────────────────────
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainTabBar(),
              if (!isAvailable) ...[
                const SizedBox(height: 10),
                _buildAppliedSubTabs(),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? const Color(0xFF2563EB)
                          : _appliedSubTabColor(_appliedSubTab),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isAvailable
                        ? 'AVAILABLE JOBS (${_jobs.length})'
                        : '${_appliedSubTab.toUpperCase()} (${_appliedSubTabCount()})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Scrollable cards only ─────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF2563EB),
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
              children: [
                if (isAvailable)
                  ..._buildAvailableContent()
                else
                  ..._buildAppliedSubTabContent(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Color _appliedSubTabColor(String sub) {
    if (sub == 'accepted') return const Color(0xFF059669);
    if (sub == 'completed') return const Color(0xFF2563EB);
    return const Color(0xFFF59E0B);
  }

  int _appliedSubTabCount() {
    if (_appliedSubTab == 'pending') return _pendingJobs.length;
    if (_appliedSubTab == 'accepted') return _acceptedJobs.length;
    return _completedJobs.length;
  }

  // ── Main tab bar: Available | Applied ──────────────────────────────────────
  Widget _buildMainTabBar() {
    final isAvailable = _mainTab == 'available';
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _setMainTab('available'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFF2563EB).withValues(alpha: 0.07)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(11),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: isAvailable
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: Color(0xFF2563EB),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loading ? '—' : _total.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isAvailable
                                ? const Color(0xFF2563EB)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 52,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _setMainTab('applied'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: !isAvailable
                      ? const Color(0xFF059669).withValues(alpha: 0.07)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(11),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: !isAvailable
                          ? const Color(0xFF059669)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF059669),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_appliedTotal > 0
                                  ? _appliedTotal
                                  : _pendingJobs.length +
                                        _acceptedJobs.length +
                                        _completedJobs.length)
                              .toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: !isAvailable
                                ? const Color(0xFF059669)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Applied',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Applied sub-tabs: Pending | Accepted | Completed ──────────────────────
  Widget _buildAppliedSubTabs() {
    final tabs = [
      (
        'pending',
        'Pending',
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
        Icons.hourglass_top_rounded,
      ),
      (
        'accepted',
        'Accepted',
        const Color(0xFF059669),
        const Color(0xFFD1FAE5),
        Icons.check_circle_rounded,
      ),
      (
        'completed',
        'Completed',
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        Icons.verified_rounded,
      ),
    ];

    int countFor(String key) {
      switch (key) {
        case 'accepted':
          return _acceptedJobs.length;
        case 'completed':
          return _completedJobs.length;
        default:
          return _pendingJobs.length;
      }
    }

    bool isLoadingFor(String key) {
      switch (key) {
        case 'accepted':
          return _acceptedLoading;
        case 'completed':
          return _completedLoading;
        default:
          return _pendingLoading;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((mapEntry) {
          final i = mapEntry.key;
          final tab = mapEntry.value;
          final key = tab.$1;
          final label = tab.$2;
          final fg = tab.$3;
          final bg = tab.$4;
          final icon = tab.$5;
          final isActive = _appliedSubTab == key;
          final count = countFor(key);
          final isLoading = isLoadingFor(key);

          return GestureDetector(
            onTap: () => _setAppliedSubTab(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? bg : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? fg
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: fg.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isActive
                        ? fg
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.40),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive
                          ? fg
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.40),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? fg.withValues(alpha: 0.15)
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: isActive
                                  ? fg
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.40),
                            ),
                          )
                        : Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isActive
                                  ? fg
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.40),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Available jobs list ───────────────────────────────────────────────────
  List<Widget> _buildAvailableContent() {
    if (_jobs.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.work_off_outlined,
                    size: 36,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'No Jobs Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'New jobs will appear here. Pull down to refresh.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ];
    }
    return _jobs
        .map(
          (job) =>
              _JobCard(job: job, subscriptionActive: widget.subscriptionActive),
        )
        .toList();
  }

  // ── Applied sub-tab content ───────────────────────────────────────────────
  List<Widget> _buildAppliedSubTabContent() {
    final bool isLoading;
    final String? error;
    final List<_AppliedJobEntry> list;
    final Color accentColor;
    final String emptyLabel;
    final String emptySubLabel;
    final IconData emptyIcon;

    switch (_appliedSubTab) {
      case 'accepted':
        isLoading = _acceptedLoading;
        error = _acceptedError;
        list = _acceptedJobs;
        accentColor = const Color(0xFF059669);
        emptyLabel = 'No Accepted Jobs';
        emptySubLabel = 'Jobs accepted by employers will appear here.';
        emptyIcon = Icons.check_circle_outline_rounded;
      case 'completed':
        isLoading = _completedLoading;
        error = _completedError;
        list = _completedJobs;
        accentColor = const Color(0xFF2563EB);
        emptyLabel = 'No Completed Jobs';
        emptySubLabel = 'Jobs you have completed will appear here.';
        emptyIcon = Icons.verified_outlined;
      default: // pending
        isLoading = _pendingLoading;
        error = _pendingError;
        list = _pendingJobs;
        accentColor = const Color(0xFFF59E0B);
        emptyLabel = 'No Pending Applications';
        emptySubLabel = 'Apply to jobs and they will appear here.';
        emptyIcon = Icons.hourglass_empty_rounded;
    }

    if (isLoading) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: LoadingSkeleton(
            type: LoadingSkeletonType.appliedJobCard,
            itemCount: 3,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          ),
        ),
      ];
    }

    if (error != null) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 40, color: accentColor),
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (list.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(emptyIcon, size: 36, color: accentColor),
                ),
                const SizedBox(height: 14),
                Text(
                  emptyLabel,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  emptySubLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return list
        .map(
          (entry) =>
              _AppliedJobCard(entry: entry, statusOverride: _appliedSubTab),
        )
        .toList();
  }
}

// ── Applied Job Card ──────────────────────────────────────────────────────────

class _AppliedJobCard extends StatelessWidget {
  final _AppliedJobEntry entry;
  final String? statusOverride;

  const _AppliedJobCard({required this.entry, this.statusOverride});

  static ({Color bg, Color fg, IconData icon, String label}) _statusInfo(
    String status,
  ) {
    switch (status) {
      case 'accepted':
        return (
          bg: const Color(0xFFD1FAE5),
          fg: const Color(0xFF059669),
          icon: Icons.check_circle_rounded,
          label: 'Accepted',
        );
      case 'rejected':
        return (
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
          label: 'Rejected',
        );
      case 'withdrawn':
        return (
          bg: const Color(0xFFF3F4F6),
          fg: const Color(0xFF9CA3AF),
          icon: Icons.undo_rounded,
          label: 'Withdrawn',
        );
      case 'completed':
        return (
          bg: const Color(0xFFEFF6FF),
          fg: const Color(0xFF2563EB),
          icon: Icons.verified_rounded,
          label: 'Completed',
        );
      default:
        return (
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFFD97706),
          icon: Icons.hourglass_top_rounded,
          label: 'Pending',
        );
    }
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Color _postedByColor(String ut) =>
      ut == 'contractor' ? const Color(0xFF059669) : const Color(0xFF7C3AED);

  String _postedByLabel(String ut) {
    switch (ut) {
      case 'contractor':
        return 'Contractor';
      case 'sub_contractor':
        return 'Sub-Contractor';
      default:
        return ut;
    }
  }

  // ignore: unused_element
  Widget _noPhoto({double height = 110}) => Container(
    height: height,
    width: double.infinity,
    color: const Color(0xFFF3F4F6),
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 28, color: Color(0xFFD1D5DB)),
        SizedBox(height: 4),
        Text(
          'NO PHOTO',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9CA3AF),
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final info = _statusInfo(statusOverride ?? entry.applicationStatus);
    final postedByColor = _postedByColor(entry.postedByUserType);
    final location = [
      entry.area,
      entry.city,
      entry.state,
    ].where((s) => s.isNotEmpty).join(', ');
    final initials = entry.postedByName.trim().isNotEmpty
        ? entry.postedByName
              .trim()
              .split(' ')
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join()
        : '?';
    final primaryColor = const Color(0xFF2563EB);
    final hasImages = entry.images.isNotEmpty;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job details for "${entry.workTitle}" - coming soon'),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: info.fg.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: info.fg.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.work_outline_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.workTitle.isEmpty
                              ? 'Untitled Job'
                              : entry.workTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: cs.onSurface.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.55),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: info.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: info.fg.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(info.icon, size: 13, color: info.fg),
                        const SizedBox(width: 5),
                        Text(
                          info.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: info.fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Posted by info ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: postedByColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: postedByColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: postedByColor,
                      backgroundImage:
                          (entry.postedByPhoto != null &&
                              entry.postedByPhoto!.isNotEmpty)
                          ? NetworkImage(entry.postedByPhoto!)
                          : null,
                      child:
                          (entry.postedByPhoto == null ||
                              entry.postedByPhoto!.isEmpty)
                          ? Text(
                              initials,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.surface,
                              ),
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
                              Text(
                                'Posted by: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.postedByName.isEmpty
                                      ? 'Unknown'
                                      : entry.postedByName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: postedByColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _postedByLabel(entry.postedByUserType),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (entry.postedByRating > 0) ...[
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < entry.postedByRating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 12,
                                      color: i < entry.postedByRating
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Info chips ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip(
                    icon: Icons.groups_rounded,
                    label:
                        'Need: ${entry.workersNeeded} Worker${entry.workersNeeded == 1 ? '' : 's'}',
                    textColor: const Color(0xFF15803D),
                  ),
                  if (entry.estimatedBudget != null)
                    _chip(
                      icon: Icons.currency_rupee_rounded,
                      label: '₹${entry.estimatedBudget!.toStringAsFixed(0)}',
                      textColor: const Color(0xFFD97706),
                    ),
                  if (entry.appliedAt != null)
                    _chip(
                      icon: Icons.calendar_today_outlined,
                      label: 'Applied: ${_fmtDate(entry.appliedAt)}',
                      textColor: const Color(0xFF6D28D9),
                    ),
                ],
              ),
            ),

            // ── Skills ──────────────────────────────────────────────────────
            if (entry.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 13,
                          color: primaryColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Skills Required',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor.withValues(alpha: 0.8),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: entry.requiredSkills
                          .take(5)
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],

            // ── Description ─────────────────────────────────────────────────
            if (entry.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 13,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'About this job',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface.withValues(alpha: 0.4),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: cs.onSurface.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],

            // ── Images strip ────────────────────────────────────────────────
            if (hasImages) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: entry.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      entry.images[i],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: cs.onSurface.withValues(alpha: 0.08),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: cs.onSurface.withValues(alpha: 0.3),
                          size: 24,
                        ),
                      ),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              width: 80,
                              height: 80,
                              color: cs.onSurface.withValues(alpha: 0.08),
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Available Job Card ────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final _JobListing job;
  final bool subscriptionActive;

  const _JobCard({required this.job, this.subscriptionActive = false});

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _postedByLabel(String ut) {
    switch (ut) {
      case 'contractor':
        return 'Contractor';
      case 'sub_contractor':
        return 'Sub-Contractor';
      default:
        return ut;
    }
  }

  Color _postedByColor(String ut) =>
      ut == 'contractor' ? const Color(0xFF059669) : const Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final location = [
      job.area,
      job.city,
      job.state,
    ].where((s) => s.isNotEmpty).join(', ');
    final postedByColor = _postedByColor(job.postedByUserType);
    final initials = job.postedByName.trim().isNotEmpty
        ? job.postedByName
              .trim()
              .split(' ')
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join()
        : '?';
    final primaryColor = const Color(0xFF2563EB);
    final hasImages = job.images.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _AvailableJobDetailScreen(job: job),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.work_outline_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.workTitle.isEmpty
                              ? 'Untitled Job'
                              : job.workTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: cs.onSurface.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.55),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Posted date badge
                  if (job.postedAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _fmtDate(job.postedAt),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Posted by info ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: postedByColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: postedByColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: postedByColor,
                      backgroundImage:
                          (job.postedByPhoto != null &&
                              job.postedByPhoto!.isNotEmpty)
                          ? NetworkImage(job.postedByPhoto!)
                          : null,
                      child:
                          (job.postedByPhoto == null ||
                              job.postedByPhoto!.isEmpty)
                          ? Text(
                              initials,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.surface,
                              ),
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
                              Text(
                                'Posted by: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  job.postedByName.isEmpty
                                      ? 'Unknown'
                                      : job.postedByName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: postedByColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _postedByLabel(job.postedByUserType),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (job.postedByRating > 0) ...[
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < job.postedByRating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 12,
                                      color: i < job.postedByRating
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Info chips ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip(
                    icon: Icons.groups_rounded,
                    label:
                        'Need: ${job.workersNeeded} Worker${job.workersNeeded == 1 ? '' : 's'}',
                    textColor: const Color(0xFF15803D),
                  ),
                  if (job.estimatedBudget != null)
                    _chip(
                      icon: Icons.currency_rupee_rounded,
                      label: '₹${job.estimatedBudget!.toStringAsFixed(0)}',
                      textColor: const Color(0xFFD97706),
                    ),
                  _chip(
                    icon: Icons.inbox_outlined,
                    label: '${job.totalApplications} Applied',
                    textColor: const Color(0xFF6D28D9),
                  ),
                ],
              ),
            ),

            // ── Skills ──────────────────────────────────────────────────────
            if (job.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 13,
                          color: primaryColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Skills Required',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor.withValues(alpha: 0.8),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: job.requiredSkills
                          .take(5)
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],

            // ── Description ─────────────────────────────────────────────────
            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 13,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'About this job',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface.withValues(alpha: 0.4),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: cs.onSurface.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],

            // ── Images strip ────────────────────────────────────────────────
            if (hasImages) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: job.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      job.images[i],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: cs.onSurface.withValues(alpha: 0.08),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: cs.onSurface.withValues(alpha: 0.3),
                          size: 24,
                        ),
                      ),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              width: 80,
                              height: 80,
                              color: cs.onSurface.withValues(alpha: 0.08),
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(height: 1, color: cs.outline.withValues(alpha: 0.12)),

            // ── Apply button ────────────────────────────────────────────────
            if (subscriptionActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Apply for "${job.workTitle}" — coming soon',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('APPLY NOW'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFED7AA),
                      width: 1.2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Active subscription required to apply for jobs. Go to Profile → Subscription to activate.',
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 11,
                          horizontal: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 15,
                              color: Color(0xFFEA580C),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'SUBSCRIPTION REQUIRED TO APPLY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFEA580C),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Available Job Detail Screen
// ══════════════════════════════════════════════════════════════════════════════

class _AvailableJobDetailScreen extends StatelessWidget {
  final _JobListing job;

  const _AvailableJobDetailScreen({required this.job});

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _postedByLabel(String userType) {
    switch (userType) {
      case 'contractor':
        return 'Contractor';
      case 'sub_contractor':
        return 'Sub-Contractor';
      case 'labour':
        return 'Labour';
      default:
        return userType;
    }
  }

  Color _postedByColor(BuildContext context, String userType) {
    switch (userType) {
      case 'contractor':
        return const Color(0xFF059669);
      case 'sub_contractor':
        return const Color(0xFF7C3AED);
      case 'labour':
        return const Color(0xFF2563EB);
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primaryColor = const Color(0xFF2563EB);
    final location = [
      job.area,
      job.city,
      job.state,
    ].where((s) => s.isNotEmpty).join(', ');
    final postedByColor = _postedByColor(context, job.postedByUserType);
    final initials = job.postedByName.trim().isNotEmpty
        ? job.postedByName
              .trim()
              .split(' ')
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join()
        : '?';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: cs.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          job.workTitle.isEmpty ? 'Job Details' : job.workTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Posted By ──────────────────────────────────────────────────────
          _card(
            cs: cs,
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: postedByColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: postedByColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child:
                      job.postedByPhoto != null && job.postedByPhoto!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.network(
                            job.postedByPhoto!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: postedByColor,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: postedByColor,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Name and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posted By',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.postedByName.isEmpty ? 'Unknown' : job.postedByName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: postedByColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _postedByLabel(job.postedByUserType),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: postedByColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                if (job.postedByRating > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          job.postedByRating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Location ───────────────────────────────────────────────────────
          if (location.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              cs: cs,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Quick info tiles ───────────────────────────────────────────────
          _card(
            cs: cs,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoTile(
                  icon: Icons.group_outlined,
                  label: 'Workers Needed',
                  value: '${job.workersNeeded}',
                  color: const Color(0xFF15803D),
                ),
                if (job.estimatedBudget != null)
                  _infoTile(
                    icon: Icons.currency_rupee_rounded,
                    label: 'Budget',
                    value: '₹${job.estimatedBudget!.toStringAsFixed(0)}',
                    color: const Color(0xFF92400E),
                  ),
                if (job.postedAt != null)
                  _infoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Posted On',
                    value: _fmtDate(job.postedAt),
                    color: const Color(0xFF6D28D9),
                  ),
                if (job.totalApplications > 0)
                  _infoTile(
                    icon: Icons.people_rounded,
                    label: 'Applications',
                    value: '${job.totalApplications}',
                    color: primaryColor,
                  ),
              ],
            ),
          ),

          // ── Images ─────────────────────────────────────────────────────────
          if (job.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              cs: cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AvailableJobImageGallery(images: job.images),
                ],
              ),
            ),
          ],

          // ── Description ────────────────────────────────────────────────────
          if (job.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              cs: cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.8),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Skills ─────────────────────────────────────────────────────────
          if (job.requiredSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              cs: cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required Skills',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: job.requiredSkills
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _card({required ColorScheme cs, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Available Job Image Gallery
// ══════════════════════════════════════════════════════════════════════════════

class _AvailableJobImageGallery extends StatefulWidget {
  final List<String> images;
  const _AvailableJobImageGallery({required this.images});

  @override
  State<_AvailableJobImageGallery> createState() =>
      _AvailableJobImageGalleryState();
}

class _AvailableJobImageGalleryState extends State<_AvailableJobImageGallery> {
  int _current = 0;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: widget.images.length,
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _AvailableJobImageViewer(
                        images: widget.images,
                        initialIndex: i,
                      ),
                    ),
                  ),
                  child: Image.network(
                    widget.images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: cs.onSurface.withValues(alpha: 0.08),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _current ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == _current
                      ? cs.onSurface
                      : cs.onSurface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Available Job Full-Screen Image Viewer
// ══════════════════════════════════════════════════════════════════════════════

class _AvailableJobImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _AvailableJobImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_AvailableJobImageViewer> createState() =>
      _AvailableJobImageViewerState();
}

class _AvailableJobImageViewerState extends State<_AvailableJobImageViewer> {
  late int _current;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.surface),
        title: widget.images.length > 1
            ? Text(
                '${_current + 1} / ${widget.images.length}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 14,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              child: Center(
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 64,
                  ),
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _current == i ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _current == i ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
