import 'package:flutter/material.dart';
import '../models/my_job.dart';
import '../../../common/models/skill_model.dart';
import '../../../common/models/business_type_model.dart';
import '../../../l10n/app_localizations.dart';
import 'my_Job_Detail_Screen.dart';

class MyJobCard extends StatefulWidget {
  final MyJob job;
  final Color primaryColor;
  final List<SkillModel> skills;
  final List<BusinessTypeModel> businessTypes;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final Future<Map<String, dynamic>> Function()? onToggleActivation;

  const MyJobCard({
    super.key,
    required this.job,
    required this.primaryColor,
    required this.skills,
    required this.businessTypes,
    this.onTap,
    this.onEditTap,
    this.onToggleActivation,
  });

  @override
  State<MyJobCard> createState() => _MyJobCardState();
}

class _MyJobCardState extends State<MyJobCard> {
  String _targetLabel(String t) {
    switch (t) {
      case 'sub_contractor':
        return AppLocalizations.of(context).subcontractorRoleTitle;
      case 'labour':
        return AppLocalizations.of(context).labourRoleTitle;
      default:
        return t;
    }
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  late bool _isActive;
  @override
  void initState() {
    super.initState();
    _isActive = widget.job.isActive;
  }

  bool _toggling = false;

  Future<void> _handleToggle() async {
    final loc = AppLocalizations.of(context);
    if (_toggling || widget.onToggleActivation == null) return;
    setState(() => _toggling = true);
    final result = await widget.onToggleActivation!();
    if (!mounted) return;
    setState(() => _toggling = false);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final newActive = data?['isActive'] as bool? ?? !_isActive;
      setState(() => _isActive = newActive);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newActive ? loc.jobIsNowLive : loc.jobHiddenFromApplicants,
          ),
          backgroundColor: newActive
              ? const Color(0xFF059669)
              : const Color(0xFF6B7280),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final msg =
          result['message']?.toString() ?? 'Failed to toggle activation';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final job = widget.job;
    final primaryColor = widget.primaryColor;
    final skillsList = widget.skills;
    final isLive = _isActive;
    final location = [job.area, job.city].where((s) => s.isNotEmpty).join(', ');
    final hasImages = job.images.isNotEmpty;
    final businessTypeList = widget.businessTypes;
    final skillLookup = {for (final skill in skillsList) skill.id: skill};
    final businessTypeLookup = {
      for (final businessType in businessTypeList)
        businessType.id: businessType,
    };
    final visibleBusinessTypes = job.businessTypes
        .map(
          (id) =>
              businessTypeLookup[id] ??
              BusinessTypeModel(
                id: id,
                enName: id,
                hiName: '',
                mrName: '',
                category: '',
              ),
        )
        .toList();
    final visibleSkills = job.requiredSkills
        .take(5)
        .map(
          (id) =>
              skillLookup[id] ??
              SkillModel(id: id, enName: id, hiName: '', mrName: ''),
        )
        .toList();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (sheetContext) => FractionallySizedBox(
            heightFactor: 0.92,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: MyJobDetailScreen(
                job: widget.job,
                primaryColor: widget.primaryColor,
                skills: widget.skills,
                businessTypes: widget.businessTypes,
                skillsList: widget.skills,
              ),
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLive
                  ? const Color(0xFF059669).withValues(alpha: 0.4)
                  : cs.outline.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isLive
                    ? const Color(0xFF059669).withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: 0.05,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      cacheWidth: 360,
                      cacheHeight: 360,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ──
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
                                    ? loc.untitledJob
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
                                      color: cs.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cs.onSurface.withValues(
                                            alpha: 0.55,
                                          ),
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
                        // Live/Hidden badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isLive
                                ? const Color(
                                    0xFF059669,
                                  ).withValues(alpha: 0.12)
                                : cs.onSurface.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isLive
                                  ? const Color(
                                      0xFF059669,
                                    ).withValues(alpha: 0.4)
                                  : cs.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isLive
                                      ? const Color(0xFF059669)
                                      : cs.onSurface.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isLive ? loc.liveLabel : loc.hiddenLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isLive
                                      ? const Color(0xFF059669)
                                      : cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Info chips ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...job.target.map(
                          (t) => _chip(
                            icon: Icons.person_search_rounded,
                            label: '${loc.forLabel} ${_targetLabel(t)}',
                            textColor: const Color(0xFF0369A1),
                          ),
                        ),
                        if (job.workersNeeded > 0)
                          _chip(
                            icon: Icons.groups_rounded,
                            label:
                                '${loc.needLabel} ${job.workersNeeded} ${job.workersNeeded == 1 ? loc.workerLabel : loc.workersLabel}',
                            textColor: const Color(0xFF15803D),
                          ),
                        if (job.createdAt != null)
                          _chip(
                            icon: Icons.calendar_today_outlined,
                            label:
                                '${loc.postedLabel} ${_fmtDate(job.createdAt)}',
                            textColor: const Color(0xFF6D28D9),
                          ),
                      ],
                    ),
                  ),

                  // ── Business Types chips ──
                  if (job.businessTypes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business_center_outlined,
                                size: 13,
                                color: primaryColor.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                loc.businessTypesLabel,
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
                            children: visibleBusinessTypes.map((bt) {
                              return Container(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      bt.enName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (bt.hiName.isNotEmpty)
                                      Text(
                                        bt.hiName,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

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
                            children: visibleSkills.map((skill) {
                              return Container(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      skill.enName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (skill.hiName.isNotEmpty)
                                      Text(
                                        skill.hiName,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

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

                  if (hasImages) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: job.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ImageGalleryViewer(
                                images: job.images,
                                initialIndex: i,
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              job.images[i],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              cacheWidth: 160,
                              cacheHeight: 160,
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
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                  ? child
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.08,
                                      ),
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
                    ),
                  ],

                  const SizedBox(height: 12),
                  Divider(height: 1, color: cs.outline.withValues(alpha: 0.12)),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _toggling ? null : _handleToggle,
                        icon: _toggling
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isLive
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF059669),
                                ),
                              )
                            : Icon(
                                isLive
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 16,
                                color: isLive
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF059669),
                              ),
                        label: Text(
                          isLive ? loc.deactivateHideJob : loc.activateMakeLive,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isLive
                                ? const Color(0xFFDC2626).withValues(alpha: 0.5)
                                : const Color(
                                    0xFF059669,
                                  ).withValues(alpha: 0.5),
                          ),
                          foregroundColor: isLive
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Divider(
                    height: 16,
                    color: cs.outline.withValues(alpha: 0.12),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onTap,
                            icon: const Icon(Icons.people_rounded, size: 16),
                            label: Text(
                              "${loc.applicationsLabel}${job.totalApplications > 0 ? ' (${job.totalApplications})' : ''}",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onEditTap,
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: primaryColor,
                            ),
                            label: Text(loc.editJob),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: primaryColor.withValues(alpha: 0.4),
                              ),
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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

class _JobImageGallery extends StatefulWidget {
  final List<String> images;
  const _JobImageGallery({required this.images});

  @override
  State<_JobImageGallery> createState() => _JobImageGalleryState();
}

class _JobImageGalleryState extends State<_JobImageGallery> {
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
    final cs = Theme.of(context).colorScheme;
    final images = widget.images;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        _ImageGalleryViewer(images: images, initialIndex: i),
                  ),
                ),
                child: Image.network(
                  images[i],
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
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _current == i
                      ? cs.onSurface
                      : cs.onSurface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ImageGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageGalleryViewer({required this.images, required this.initialIndex});

  @override
  State<_ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<_ImageGalleryViewer> {
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.images.length > 1
            ? Text(
                '${_current + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
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
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.white),
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
