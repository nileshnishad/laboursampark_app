import 'package:flutter/material.dart';

import '../../../common/models/skill_model.dart';
import '../../../common/utils/skill_display_utils.dart';
import '../../../common/widgets/loading_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/api_service.dart';
import '../../../services/skills_service.dart';
import '../../../theme/app_card_metrics.dart';
import '../../../core/auth_service.dart';

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

class _LabourTextScale {
  static const double display = 18;
  static const double title = 15;
  static const double section = 13;
  static const double body = 12;
  static const double caption = 11;
  static const double micro = 10;
  static const double button = 12;
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
  List<SkillModel> _allSkills = [];

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
    _loadSkills();
    _loadAvailable();
    _loadPending();
    _loadAccepted();
    _loadCompleted();
  }

  // ── Loaders ──────────────────────────────────────────────────────────────────
  Future<void> _loadSkills() async {
    final cached = SkillsService.getCachedSkills();
    if (cached != null && cached.isNotEmpty) {
      if (mounted) {
        setState(() => _allSkills = cached);
      }
      return;
    }

    final result = await SkillsService.getAllSkills();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _allSkills = (result['skills'] as List<SkillModel>? ?? []);
      });
    }
  }

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
        _error =
            (result['message'] ?? AppLocalizations.of(context).failedToLoadJobs)
                .toString();
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
        _pendingError =
            (result['message'] ??
                    AppLocalizations.of(context).failedToLoadPendingJobs)
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
        _acceptedError =
            (result['message'] ??
                    AppLocalizations.of(context).failedToLoadAcceptedJobs)
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
        _completedError =
            (result['message'] ??
                    AppLocalizations.of(context).failedToLoadCompletedJobs)
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
    final loc = AppLocalizations.of(context);
    final isAvailable = _mainTab == 'available';

    if (AuthService.isInUserInitiatedLogoutGrace) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(height: 10),
            Text('Logging out...'),
          ],
        ),
      );
    }

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
                label: Text(loc.retry),
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
              if (!isAvailable) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _appliedSubTabColor(_appliedSubTab),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_appliedTabTitle(loc, _appliedSubTab)} (${_appliedSubTabCount()})',
                      style: TextStyle(
                        fontSize: _LabourTextScale.section,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // ── Scrollable cards only ─────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF2563EB),
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppCardMetrics.pageHorizontal,
                4,
                AppCardMetrics.pageHorizontal,
                AppCardMetrics.pageBottom,
              ),
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
  Color _mainTabBackground({required bool available, required bool selected}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = available ? const Color(0xFFF59E0B) : const Color(0xFF059669);
    return base.withValues(
      alpha: isDark ? (selected ? 0.72 : 0.28) : (selected ? 0.22 : 0.1),
    );
  }

  Color _mainTabForeground({required bool available, required bool selected}) {
    if (Theme.of(context).brightness == Brightness.dark) return Colors.white;
    final base = available ? const Color(0xFFB45309) : const Color(0xFF047857);
    return selected ? base : Theme.of(context).colorScheme.onSurface;
  }

  Widget _buildMainTabBar() {
    final loc = AppLocalizations.of(context);
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
                  color: _mainTabBackground(
                    available: true,
                    selected: isAvailable,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(11),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFF59E0B),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _mainTabBackground(
                          available: true,
                          selected: isAvailable,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: Color(0xFFF59E0B),
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
                            fontSize: _LabourTextScale.display,
                            fontWeight: FontWeight.w800,
                            color: _mainTabForeground(
                              available: true,
                              selected: isAvailable,
                            ),
                          ),
                        ),
                        Text(
                          loc.available,
                          style: TextStyle(
                            fontSize: _LabourTextScale.caption,
                            color: _mainTabForeground(
                              available: true,
                              selected: isAvailable,
                            ).withValues(alpha: 0.82),
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
                  color: _mainTabBackground(
                    available: false,
                    selected: !isAvailable,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(11),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF059669),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _mainTabBackground(
                          available: false,
                          selected: !isAvailable,
                        ),
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
                            fontSize: _LabourTextScale.display,
                            fontWeight: FontWeight.w800,
                            color: _mainTabForeground(
                              available: false,
                              selected: !isAvailable,
                            ),
                          ),
                        ),
                        Text(
                          loc.applied,
                          style: TextStyle(
                            fontSize: _LabourTextScale.caption,
                            color: _mainTabForeground(
                              available: false,
                              selected: !isAvailable,
                            ).withValues(alpha: 0.82),
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
    final loc = AppLocalizations.of(context);
    final tabs = [
      (
        'pending',
        loc.pending,
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
        Icons.hourglass_top_rounded,
      ),
      (
        'accepted',
        loc.accepted,
        const Color(0xFF059669),
        const Color(0xFFD1FAE5),
        Icons.check_circle_rounded,
      ),
      (
        'completed',
        loc.completed,
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
                      fontSize: _LabourTextScale.body,
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
                              fontSize: _LabourTextScale.caption,
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
    final loc = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
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
                  loc.noJobsAvailable,
                  style: TextStyle(
                    fontSize: _LabourTextScale.display,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.newJobsWillAppearHint,
                  style: TextStyle(
                    fontSize: _LabourTextScale.section,
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
          (job) => _JobCard(
            job: job,
            subscriptionActive: widget.subscriptionActive,
            availableSkills: _allSkills,
            localeCode: localeCode,
            token: widget.token,
            onApplied: _refreshAfterApply,
          ),
        )
        .toList();
  }

  Future<void> _refreshAfterApply() async {
    await _loadAvailable();
    await _loadPending();
  }

  // ── Applied sub-tab content ───────────────────────────────────────────────
  List<Widget> _buildAppliedSubTabContent() {
    final loc = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
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
        emptyLabel = loc.noAcceptedJobs;
        emptySubLabel = loc.acceptedJobsAppearHere;
        emptyIcon = Icons.check_circle_outline_rounded;
      case 'completed':
        isLoading = _completedLoading;
        error = _completedError;
        list = _completedJobs;
        accentColor = const Color(0xFF2563EB);
        emptyLabel = loc.noCompletedJobs;
        emptySubLabel = loc.completedJobsAppearHere;
        emptyIcon = Icons.verified_outlined;
      default: // pending
        isLoading = _pendingLoading;
        error = _pendingError;
        list = _pendingJobs;
        accentColor = const Color(0xFFF59E0B);
        emptyLabel = loc.noPendingApplications;
        emptySubLabel = loc.applyJobsAppearHere;
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
                    fontSize: _LabourTextScale.section,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: Text(loc.retry),
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
                    fontSize: _LabourTextScale.display,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  emptySubLabel,
                  style: TextStyle(
                    fontSize: _LabourTextScale.section,
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
          (entry) => _AppliedJobCard(
            entry: entry,
            statusOverride: _appliedSubTab,
            availableSkills: _allSkills,
            localeCode: localeCode,
            token: widget.token,
            onFeedbackSubmitted: _onRefresh,
          ),
        )
        .toList();
  }

  String _appliedTabTitle(AppLocalizations loc, String key) {
    switch (key) {
      case 'pending':
        return loc.pendingUppercase;
      case 'accepted':
        return loc.acceptedUppercase;
      case 'completed':
        return loc.completedUppercase;
      default:
        return key.toUpperCase();
    }
  }
}

// ── Applied Job Card ──────────────────────────────────────────────────────────

class _AppliedJobCard extends StatelessWidget {
  final _AppliedJobEntry entry;
  final String? statusOverride;
  final List<SkillModel> availableSkills;
  final String localeCode;
  final String token;
  final Future<void> Function()? onFeedbackSubmitted;

  const _AppliedJobCard({
    required this.entry,
    this.statusOverride,
    required this.availableSkills,
    required this.localeCode,
    required this.token,
    this.onFeedbackSubmitted,
  });

  Future<void> _showRateContractorSheet(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final feedbackController = TextEditingController(
      text: entry.myFeedbackText ?? '',
    );
    double rating = (entry.myFeedbackRating ?? 4).toDouble().clamp(1, 5);
    String? responseMessage;
    bool submitted = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final mq = MediaQuery.of(ctx);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: mq.viewInsets.bottom + mq.padding.bottom + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: mq.size.height * 0.86),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.rateContractorTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.rateWorkLabel(
                            entry.postedByName.isEmpty
                                ? loc.contractorRoleTitle
                                : entry.postedByName,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          loc.ratingLabelSmall,
                          style: const TextStyle(
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
                                onChanged: saving
                                    ? null
                                    : (v) => setSheetState(() => rating = v),
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
                        Text(
                          loc.feedbackLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: feedbackController,
                          maxLines: 3,
                          enabled: !saving,
                          decoration: InputDecoration(
                            hintText: loc.feedbackHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    setSheetState(() => saving = true);
                                    final res =
                                        await ApiService.submitJobFeedback(
                                          token: token,
                                          jobId: entry.jobId,
                                          rating: rating,
                                          feedback:
                                              feedbackController.text
                                                  .trim()
                                                  .isEmpty
                                              ? loc.goodWorkDefault
                                              : feedbackController.text.trim(),
                                        );
                                    if (res['success'] == true) {
                                      submitted = true;
                                      responseMessage = res['message']
                                          ?.toString();
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      return;
                                    }

                                    setSheetState(() => saving = false);
                                    if (!ctx.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          (res['message'] ??
                                                  loc.failedToSubmitFeedback)
                                              .toString(),
                                        ),
                                        backgroundColor: const Color(
                                          0xFFDC2626,
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    loc.rateContractor,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    feedbackController.dispose();
    if (!submitted || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(responseMessage ?? loc.feedbackSubmittedSuccessfully),
        backgroundColor: const Color(0xFF059669),
      ),
    );
    await onFeedbackSubmitted?.call();
  }

  ({Color bg, Color fg, IconData icon, String label}) _statusInfo(
    AppLocalizations loc,
    String status,
  ) {
    switch (status) {
      case 'accepted':
        return (
          bg: const Color(0xFFD1FAE5),
          fg: const Color(0xFF059669),
          icon: Icons.check_circle_rounded,
          label: loc.accepted,
        );
      case 'rejected':
        return (
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
          label: loc.rejected,
        );
      case 'withdrawn':
        return (
          bg: const Color(0xFFF3F4F6),
          fg: const Color(0xFF9CA3AF),
          icon: Icons.undo_rounded,
          label: loc.withdrawn,
        );
      case 'completed':
        return (
          bg: const Color(0xFFEFF6FF),
          fg: const Color(0xFF2563EB),
          icon: Icons.verified_rounded,
          label: loc.completed,
        );
      default:
        return (
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFFD97706),
          icon: Icons.hourglass_top_rounded,
          label: loc.pending,
        );
    }
  }

  String _fmtDate(AppLocalizations loc, DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return loc.today;
    if (diff.inDays == 1) return loc.yesterday;
    if (diff.inDays < 7) return loc.daysAgo(diff.inDays);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Color _postedByColor(String ut) =>
      ut == 'contractor' ? const Color(0xFF059669) : const Color(0xFF7C3AED);

  String _postedByLabel(AppLocalizations loc, String ut) {
    switch (ut) {
      case 'contractor':
        return loc.contractorRoleTitle;
      case 'sub_contractor':
        return loc.subcontractorRoleTitle;
      case 'labour':
        return loc.labourRoleTitle;
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
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final info = _statusInfo(loc, statusOverride ?? entry.applicationStatus);
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
    final localizedSkills = resolveSkillDisplayNames(
      skillIds: entry.requiredSkills,
      skills: availableSkills,
      localeCode: localeCode,
    );
    final resolvedStatus = statusOverride ?? entry.applicationStatus;
    final contractorFeedbackText = (entry.reviewFeedback ?? '').trim();
    final myFeedbackText = (entry.myFeedbackText ?? '').trim();
    final hasContractorFeedback =
        entry.reviewRating != null || contractorFeedbackText.isNotEmpty;
    final hasMyFeedback =
        entry.feedbackSubmitted ||
        entry.myFeedbackRating != null ||
        myFeedbackText.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppCardMetrics.cardGap),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppCardMetrics.cardRadius),
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
                  width: AppCardMetrics.iconBox,
                  height: AppCardMetrics.iconBox,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
                    color: primaryColor,
                    size: AppCardMetrics.iconSize,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.workTitle.isEmpty
                            ? loc.untitledJob
                            : entry.workTitle,
                        style: TextStyle(
                          fontSize: _LabourTextScale.title,
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
                                  fontSize: _LabourTextScale.body,
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
                          fontSize: _LabourTextScale.caption,
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
                              '${loc.postedBy}: ',
                              style: TextStyle(
                                fontSize: _LabourTextScale.caption,
                                color: cs.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.postedByName.isEmpty
                                    ? loc.unknown
                                    : entry.postedByName,
                                style: TextStyle(
                                  fontSize: _LabourTextScale.body,
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
                                _postedByLabel(loc, entry.postedByUserType),
                                style: TextStyle(
                                  fontSize: _LabourTextScale.micro,
                                  color: Theme.of(context).colorScheme.surface,
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
                  label: loc.needWorkers(
                    entry.workersNeeded,
                    entry.workersNeeded == 1,
                  ),
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
                    label: '${loc.applied}: ${_fmtDate(loc, entry.appliedAt)}',
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
                        loc.skillsRequiredLabel,
                        style: TextStyle(
                          fontSize: _LabourTextScale.caption,
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
                    children: localizedSkills
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
                                fontSize: _LabourTextScale.caption,
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
                        loc.aboutThisJob,
                        style: TextStyle(
                          fontSize: _LabourTextScale.caption,
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
                      fontSize: _LabourTextScale.body,
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
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    entry.images[i],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
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

          if (resolvedStatus == 'completed' && hasContractorFeedback) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
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
                    Text(
                      loc.receivedFeedbackLabel,
                      style: const TextStyle(
                        fontSize: _LabourTextScale.body,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    if (entry.reviewRating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < entry.reviewRating!.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: i < entry.reviewRating!.round()
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                      ),
                    ],
                    if (contractorFeedbackText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        contractorFeedbackText,
                        style: const TextStyle(
                          fontSize: _LabourTextScale.body,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          if (resolvedStatus == 'completed') ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: hasMyFeedback
                  ? Container(
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
                          Text(
                            loc.myFeedbackLabel,
                            style: const TextStyle(
                              fontSize: _LabourTextScale.body,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                          if (entry.myFeedbackRating != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < entry.myFeedbackRating!.round()
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: i < entry.myFeedbackRating!.round()
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFD1D5DB),
                                ),
                              ),
                            ),
                          ],
                          if (myFeedbackText.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              myFeedbackText,
                              style: const TextStyle(
                                fontSize: _LabourTextScale.body,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRateContractorSheet(context),
                        icon: const Icon(Icons.star_rate_rounded, size: 18),
                        label: Text(
                          loc.rateContractor,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF93C5FD)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
            ),
          ],

          const SizedBox(height: 12),
        ],
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
              fontSize: _LabourTextScale.caption,
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
  final List<SkillModel> availableSkills;
  final String localeCode;
  final String token;
  final Future<void> Function()? onApplied;

  const _JobCard({
    required this.job,
    this.subscriptionActive = false,
    required this.availableSkills,
    required this.localeCode,
    required this.token,
    this.onApplied,
  });

  Future<void> _showApplyDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final messageController = TextEditingController();
    bool submitting = false;

    final applied = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return PopScope(
              canPop: !submitting,
              child: AlertDialog(
                title: Text(loc.applyNowUppercase),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Write a message to send with your application.',
                      style: Theme.of(dialogContext).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: submitting
                        ? null
                        : () => Navigator.of(dialogContext).pop(false),
                    child: Text(loc.cancel),
                  ),
                  ElevatedButton(
                    onPressed: submitting
                        ? null
                        : () async {
                            final message = messageController.text.trim();
                            if (message.isEmpty) {
                              if (!dialogContext.mounted) return;
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a message.'),
                                ),
                              );
                              return;
                            }

                            setDialogState(() => submitting = true);
                            final res = await ApiService.applyForJob(
                              token: token,
                              jobId: job.jobId,
                              message: message,
                            );

                            if (!dialogContext.mounted) return;

                            if (res['success'] == true) {
                              Navigator.of(dialogContext).pop(true);
                              final successMessage =
                                  (res['message'] ?? 'Applied successfully')
                                      .toString();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(successMessage)),
                              );
                            } else {
                              final errorMessage =
                                  (res['message'] ??
                                          'Could not apply for this job')
                                      .toString();
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
                              if (dialogContext.mounted) {
                                setDialogState(() => submitting = false);
                              }
                            }
                          },
                    child: submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(loc.applyNowUppercase),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    messageController.dispose();

    if (context.mounted && applied == true && onApplied != null) {
      await onApplied!();
    }
  }

  String _fmtDate(AppLocalizations loc, DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return loc.today;
    if (diff.inDays == 1) return loc.yesterday;
    if (diff.inDays < 7) return loc.daysAgo(diff.inDays);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _postedByLabel(AppLocalizations loc, String ut) {
    switch (ut) {
      case 'contractor':
        return loc.contractorRoleTitle;
      case 'sub_contractor':
        return loc.subcontractorRoleTitle;
      case 'labour':
        return loc.labourRoleTitle;
      default:
        return ut;
    }
  }

  Color _postedByColor(String ut) =>
      ut == 'contractor' ? const Color(0xFF059669) : const Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
    final localizedSkills = resolveSkillDisplayNames(
      skillIds: job.requiredSkills,
      skills: availableSkills,
      localeCode: localeCode,
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _AvailableJobDetailScreen(
              job: job,
              availableSkills: availableSkills,
              localeCode: localeCode,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppCardMetrics.cardGap),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppCardMetrics.cardRadius),
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
                    width: AppCardMetrics.iconBox,
                    height: AppCardMetrics.iconBox,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.work_outline_rounded,
                      color: primaryColor,
                      size: AppCardMetrics.iconSize,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.workTitle.isEmpty
                              ? loc.untitledJob
                              : job.workTitle,
                          style: TextStyle(
                            fontSize: _LabourTextScale.title,
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
                                    fontSize: _LabourTextScale.body,
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
                        _fmtDate(loc, job.postedAt),
                        style: TextStyle(
                          fontSize: _LabourTextScale.caption,
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
                                '${loc.postedBy}: ',
                                style: TextStyle(
                                  fontSize: _LabourTextScale.caption,
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  job.postedByName.isEmpty
                                      ? loc.unknown
                                      : job.postedByName,
                                  style: TextStyle(
                                    fontSize: _LabourTextScale.body,
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
                                  _postedByLabel(loc, job.postedByUserType),
                                  style: TextStyle(
                                    fontSize: _LabourTextScale.micro,
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
                    label: loc.needWorkers(
                      job.workersNeeded,
                      job.workersNeeded == 1,
                    ),
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
                    label: loc.applicationsApplied(job.totalApplications),
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
                          loc.skillsRequiredLabel,
                          style: TextStyle(
                            fontSize: _LabourTextScale.caption,
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
                      children: localizedSkills
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
                                  fontSize: _LabourTextScale.caption,
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
                          loc.aboutThisJob,
                          style: TextStyle(
                            fontSize: _LabourTextScale.caption,
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
                        fontSize: _LabourTextScale.body,
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
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      job.images[i],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
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
                    onPressed: () => _showApplyDialog(context),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text(loc.applyNowUppercase),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: _LabourTextScale.button,
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
                          SnackBar(
                            content: Text(loc.activeSubscriptionRequiredApply),
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
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 15,
                              color: Color(0xFFEA580C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              loc.subscriptionRequiredApplyUppercase,
                              style: const TextStyle(
                                fontSize: _LabourTextScale.button,
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
                fontSize: _LabourTextScale.caption,
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
  final List<SkillModel> availableSkills;
  final String localeCode;

  const _AvailableJobDetailScreen({
    required this.job,
    required this.availableSkills,
    required this.localeCode,
  });

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _postedByLabel(AppLocalizations loc, String userType) {
    switch (userType) {
      case 'contractor':
        return loc.contractorRoleTitle;
      case 'sub_contractor':
        return loc.subcontractorRoleTitle;
      case 'labour':
        return loc.labourRoleTitle;
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
    final loc = AppLocalizations.of(context);
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
    final localizedSkills = resolveSkillDisplayNames(
      skillIds: job.requiredSkills,
      skills: availableSkills,
      localeCode: localeCode,
    );

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
          job.workTitle.isEmpty ? loc.jobDetails : job.workTitle,
          style: TextStyle(
            fontSize: _LabourTextScale.title,
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
                            errorBuilder: (_, _, _) => Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: _LabourTextScale.display,
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
                              fontSize: _LabourTextScale.display,
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
                        loc.postedBy,
                        style: TextStyle(
                          fontSize: _LabourTextScale.caption,
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.postedByName.isEmpty
                            ? loc.unknown
                            : job.postedByName,
                        style: TextStyle(
                          fontSize: _LabourTextScale.section,
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
                          _postedByLabel(loc, job.postedByUserType),
                          style: TextStyle(
                            fontSize: _LabourTextScale.micro,
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
                            fontSize: _LabourTextScale.body,
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
                          loc.locationSection,
                          style: TextStyle(
                            fontSize: _LabourTextScale.caption,
                            color: cs.onSurface.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: _LabourTextScale.section,
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
                  label: loc.workersNeededLabel,
                  value: '${job.workersNeeded}',
                  color: const Color(0xFF15803D),
                ),
                if (job.estimatedBudget != null)
                  _infoTile(
                    icon: Icons.currency_rupee_rounded,
                    label: loc.budgetLabel,
                    value: '₹${job.estimatedBudget!.toStringAsFixed(0)}',
                    color: const Color(0xFF92400E),
                  ),
                if (job.postedAt != null)
                  _infoTile(
                    icon: Icons.calendar_today_outlined,
                    label: loc.postedOn,
                    value: _fmtDate(job.postedAt),
                    color: const Color(0xFF6D28D9),
                  ),
                if (job.totalApplications > 0)
                  _infoTile(
                    icon: Icons.people_rounded,
                    label: loc.applicationsLabel,
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
                    loc.photos,
                    style: TextStyle(
                      fontSize: _LabourTextScale.section,
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
                    loc.descriptionLabel,
                    style: TextStyle(
                      fontSize: _LabourTextScale.section,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: TextStyle(
                      fontSize: _LabourTextScale.body,
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
                    loc.requiredSkillsLabel,
                    style: TextStyle(
                      fontSize: _LabourTextScale.section,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: localizedSkills
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
                                fontSize: _LabourTextScale.body,
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
                  fontSize: _LabourTextScale.micro,
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
              fontSize: _LabourTextScale.section,
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
                    errorBuilder: (_, _, _) => ColoredBox(
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
                  errorBuilder: (_, _, _) => const Icon(
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
