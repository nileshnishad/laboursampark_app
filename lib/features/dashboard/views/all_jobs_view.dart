import 'package:flutter/material.dart';

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
      totalApplications:
          (json['totalApplications'] as num?)?.toInt() ?? 0,
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
      applicationStatus:
          (json['applicationStatus'] ?? 'pending').toString(),
      message: (json['message'] ?? '').toString(),
      appliedAt:
          DateTime.tryParse((json['appliedAt'] ?? '').toString()),
      acceptedAt:
          DateTime.tryParse((json['acceptedAt'] ?? '').toString()),
      rejectedAt:
          DateTime.tryParse((json['rejectedAt'] ?? '').toString()),
      completedAt:
          DateTime.tryParse((json['completedAt'] ?? '').toString()),
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
          ? (json['review'] as Map<String, dynamic>)['feedback']
              ?.toString()
          : null),
      myFeedbackRating: (json['myFeedback'] is Map
          ? (json['myFeedback'] as Map<String, dynamic>)['rating'] as num?
          : null),
      myFeedbackText: (json['myFeedback'] is Map
          ? (json['myFeedback'] as Map<String, dynamic>)['feedback']
              ?.toString()
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

  const AllJobsView({super.key, required this.token, required this.userType});

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
        _total =
            (pagination?['total'] as num?)?.toInt() ?? _jobs.length;
        _loading = false;
      });
    } else {
      setState(() {
        _error =
            (result['message'] ?? 'Failed to load jobs').toString();
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
      final summary =
          data?['summary'] as Map<String, dynamic>? ?? {};
      setState(() {
        _pendingJobs = list
            .map((j) =>
                _AppliedJobEntry.fromJson(j as Map<String, dynamic>))
            .toList();
        _appliedTotal =
            (summary['total'] as num?)?.toInt() ?? _pendingJobs.length;
        _pendingLoading = false;
        _pendingLoaded = true;
      });
    } else {
      setState(() {
        _pendingError =
            (result['message'] ?? 'Failed to load pending jobs').toString();
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
            .map((j) =>
                _AppliedJobEntry.fromJson(j as Map<String, dynamic>))
            .toList();
        _acceptedLoading = false;
        _acceptedLoaded = true;
      });
    } else {
      setState(() {
        _acceptedError =
            (result['message'] ?? 'Failed to load accepted jobs').toString();
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
            .map((j) =>
                _AppliedJobEntry.fromJson(j as Map<String, dynamic>))
            .toList();
        _completedLoading = false;
        _completedLoaded = true;
      });
    } else {
      setState(() {
        _completedError =
            (result['message'] ?? 'Failed to load completed jobs').toString();
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
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    }

    if (isAvailable && _error != null && _jobs.isEmpty) {
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
          color: const Color(0xFFF9FAFB),
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
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: 0.5),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            child: GestureDetector(
              onTap: () => _setMainTab('available'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFF2563EB).withValues(alpha: 0.07)
                      : Colors.transparent,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(11)),
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
                      child: const Icon(Icons.work_outline_rounded,
                          color: Color(0xFF2563EB), size: 17),
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
                                    : const Color(0xFF111827))),
                        const Text('Available',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 52, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: GestureDetector(
              onTap: () => _setMainTab('applied'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: !isAvailable
                      ? const Color(0xFF059669).withValues(alpha: 0.07)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(11)),
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
                      child: const Icon(Icons.send_rounded,
                          color: Color(0xFF059669), size: 17),
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
                                  : const Color(0xFF111827)),
                        ),
                        const Text('Applied',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF6B7280))),
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
        Icons.hourglass_top_rounded
      ),
      (
        'accepted',
        'Accepted',
        const Color(0xFF059669),
        const Color(0xFFD1FAE5),
        Icons.check_circle_rounded
      ),
      (
        'completed',
        'Completed',
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        Icons.verified_rounded
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
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? bg : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? fg : const Color(0xFFE5E7EB),
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: fg.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 14,
                      color: isActive ? fg : const Color(0xFF9CA3AF)),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isActive ? fg : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? fg.withValues(alpha: 0.15)
                          : const Color(0xFFF3F4F6),
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
                                  : const Color(0xFF9CA3AF),
                            ),
                          )
                        : Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isActive
                                  ? fg
                                  : const Color(0xFF9CA3AF),
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
                  child: const Icon(Icons.work_off_outlined,
                      size: 36, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 14),
                const Text('No Jobs Available',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827))),
                const SizedBox(height: 6),
                const Text(
                    'New jobs will appear here. Pull down to refresh.',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280)),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ];
    }
    return _jobs.map((job) => _JobCard(job: job)).toList();
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
          padding: const EdgeInsets.only(top: 40),
          child: Center(
              child: CircularProgressIndicator(color: accentColor)),
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
                Icon(Icons.error_outline_rounded,
                    size: 40, color: accentColor),
                const SizedBox(height: 10),
                Text(error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF374151), fontSize: 13)),
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
                Text(emptyLabel,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827))),
                const SizedBox(height: 6),
                Text(emptySubLabel,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280)),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ];
    }

    return list
        .map((entry) => _AppliedJobCard(
            entry: entry, statusOverride: _appliedSubTab))
        .toList();
  }
}

// ── Applied Job Card ──────────────────────────────────────────────────────────

class _AppliedJobCard extends StatelessWidget {
  final _AppliedJobEntry entry;
  final String? statusOverride;

  const _AppliedJobCard({required this.entry, this.statusOverride});

  static ({Color bg, Color fg, IconData icon, String label}) _statusInfo(
      String status) {
    switch (status) {
      case 'accepted':
        return (
          bg: const Color(0xFFD1FAE5),
          fg: const Color(0xFF059669),
          icon: Icons.check_circle_rounded,
          label: 'Accepted'
        );
      case 'rejected':
        return (
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
          label: 'Rejected'
        );
      case 'withdrawn':
        return (
          bg: const Color(0xFFF3F4F6),
          fg: const Color(0xFF9CA3AF),
          icon: Icons.undo_rounded,
          label: 'Withdrawn'
        );
      case 'completed':
        return (
          bg: const Color(0xFFEFF6FF),
          fg: const Color(0xFF2563EB),
          icon: Icons.verified_rounded,
          label: 'Completed'
        );
      default:
        return (
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFFD97706),
          icon: Icons.hourglass_top_rounded,
          label: 'Pending'
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

  Widget _noPhoto({double height = 110}) => Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFF3F4F6),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 28, color: Color(0xFFD1D5DB)),
            SizedBox(height: 4),
            Text('NO PHOTO',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(statusOverride ?? entry.applicationStatus);
    final postedByColor = _postedByColor(entry.postedByUserType);
    final location = [entry.area, entry.city, entry.state]
        .where((s) => s.isNotEmpty)
        .join(', ');
    final initials = entry.postedByName.trim().isNotEmpty
        ? entry.postedByName
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          // ── Image + status badge ────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: entry.images.isNotEmpty
                    ? Image.network(
                        entry.images.first,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _noPhoto(),
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : _noPhoto(),
                      )
                    : _noPhoto(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: info.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: info.fg.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(info.icon, size: 13, color: info.fg),
                      const SizedBox(width: 5),
                      Text(info.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: info.fg)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + applied date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.workTitle.isEmpty
                            ? 'Untitled Job'
                            : entry.workTitle,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.appliedAt != null) ...[
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Applied',
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xFF9CA3AF))),
                          Text(_fmtDate(entry.appliedAt),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280))),
                        ],
                      ),
                    ],
                  ],
                ),

                // Location
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
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
                const SizedBox(height: 10),

                // Posted by
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: postedByColor,
                      backgroundImage: (entry.postedByPhoto != null &&
                              entry.postedByPhoto!.isNotEmpty)
                          ? NetworkImage(entry.postedByPhoto!)
                          : null,
                      child: (entry.postedByPhoto == null ||
                              entry.postedByPhoto!.isEmpty)
                          ? Text(initials,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              entry.postedByName.isEmpty
                                  ? 'Unknown'
                                  : entry.postedByName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827))),
                          Text(_postedByLabel(entry.postedByUserType),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: postedByColor,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (entry.postedByRating > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            5,
                            (i) => Icon(
                                  i < entry.postedByRating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 13,
                                  color: i < entry.postedByRating
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFD1D5DB),
                                )),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Workers + Budget
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline_rounded,
                              size: 13, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.workersNeeded} Worker${entry.workersNeeded == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8)),
                          ),
                        ],
                      ),
                    ),
                    if (entry.estimatedBudget != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.currency_rupee_rounded,
                                size: 13, color: Color(0xFFD97706)),
                            Text(
                                entry.estimatedBudget!.toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF92400E))),
                          ],
                        ),
                      ),
                  ],
                ),

                // Skills
                if (entry.requiredSkills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.requiredSkills
                        .take(5)
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.2)),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB))),
                            ))
                        .toList(),
                  ),
                ],

                // My message
                if (entry.message.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your message',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(entry.message,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF374151))),
                      ],
                    ),
                  ),
                ],

                // Rejection reason
                if ((statusOverride == 'rejected' ||
                        entry.applicationStatus == 'rejected') &&
                    entry.rejectionReason != null &&
                    entry.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rejection Reason',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626),
                                letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(entry.rejectionReason!,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF7F1D1D))),
                      ],
                    ),
                  ),
                ],

                // Employer review
                if (entry.reviewRating != null ||
                    (entry.reviewFeedback != null &&
                        entry.reviewFeedback!.isNotEmpty)) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            const Text('Employer Review',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFD97706),
                                    letterSpacing: 0.5)),
                            const Spacer(),
                            if (entry.reviewRating != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                    5,
                                    (i) => Icon(
                                          i < entry.reviewRating!
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 13,
                                          color: i < entry.reviewRating!
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFFD1D5DB),
                                        )),
                              ),
                          ],
                        ),
                        if (entry.reviewFeedback != null &&
                            entry.reviewFeedback!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(entry.reviewFeedback!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF92400E))),
                        ],
                      ],
                    ),
                  ),
                ],

                // My feedback
                if (entry.myFeedbackRating != null ||
                    (entry.myFeedbackText != null &&
                        entry.myFeedbackText!.isNotEmpty)) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
                            const Icon(Icons.rate_review_rounded,
                                size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            const Text('My Feedback',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2563EB),
                                    letterSpacing: 0.5)),
                            const Spacer(),
                            if (entry.myFeedbackRating != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                    5,
                                    (i) => Icon(
                                          i < entry.myFeedbackRating!
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 13,
                                          color: i < entry.myFeedbackRating!
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFFD1D5DB),
                                        )),
                              ),
                          ],
                        ),
                        if (entry.myFeedbackText != null &&
                            entry.myFeedbackText!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(entry.myFeedbackText!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1D4ED8))),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
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

  const _JobCard({required this.job});

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

  Widget _noPhoto() => Container(
        height: 130,
        width: double.infinity,
        color: const Color(0xFFF3F4F6),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 32, color: Color(0xFFD1D5DB)),
            SizedBox(height: 4),
            Text('NO PHOTOS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final location = [job.area, job.city, job.state]
        .where((s) => s.isNotEmpty)
        .join(', ');
    final postedByColor = _postedByColor(job.postedByUserType);
    final initials = job.postedByName.trim().isNotEmpty
        ? job.postedByName
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: job.images.isNotEmpty
                ? Image.network(
                    job.images.first,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _noPhoto(),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _noPhoto(),
                  )
                : _noPhoto(),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.workTitle.isEmpty ? 'Untitled Job' : job.workTitle,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (job.postedAt != null) ...[
                      const SizedBox(width: 8),
                      Text(_fmtDate(job.postedAt),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ],
                ),

                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
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
                const SizedBox(height: 10),

                // Posted by
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: postedByColor,
                      backgroundImage: (job.postedByPhoto != null &&
                              job.postedByPhoto!.isNotEmpty)
                          ? NetworkImage(job.postedByPhoto!)
                          : null,
                      child: (job.postedByPhoto == null ||
                              job.postedByPhoto!.isEmpty)
                          ? Text(initials,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              job.postedByName.isEmpty
                                  ? 'Unknown'
                                  : job.postedByName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827))),
                          Text(_postedByLabel(job.postedByUserType),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: postedByColor,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (job.postedByRating > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            5,
                            (i) => Icon(
                                  i < job.postedByRating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: i < job.postedByRating
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFD1D5DB),
                                )),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Workers + Budget + applications
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline_rounded,
                              size: 13, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            '${job.workersNeeded} Worker${job.workersNeeded == 1 ? '' : 's'} Needed',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8)),
                          ),
                        ],
                      ),
                    ),
                    if (job.estimatedBudget != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.currency_rupee_rounded,
                                size: 13, color: Color(0xFFD97706)),
                            Text(job.estimatedBudget!.toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF92400E))),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined,
                              size: 13, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text('${job.totalApplications} applied',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  ],
                ),

                // Skills
                if (job.requiredSkills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: job.requiredSkills
                        .take(5)
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.2)),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB))),
                            ))
                        .toList(),
                  ),
                ],

                if (job.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(job.description,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 4),
              ],
            ),
          ),

          // Apply button
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Apply for "${job.workTitle}" — coming soon')),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('APPLY NOW',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
