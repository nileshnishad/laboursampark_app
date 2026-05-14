import 'package:flutter/material.dart';

import '../models/my_job.dart';

class MyJobCard extends StatefulWidget {
  final MyJob job;
  final Color primaryColor;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final Future<Map<String, dynamic>> Function()? onToggleActivation;

  const MyJobCard({
    super.key,
    required this.job,
    required this.primaryColor,
    this.onTap,
    this.onEditTap,
    this.onToggleActivation,
  });

  @override
  State<MyJobCard> createState() => _MyJobCardState();
}

class _MyJobCardState extends State<MyJobCard> {
  late bool _isActive;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.job.isActive;
  }

  Future<void> _handleToggle() async {
    if (_toggling || widget.onToggleActivation == null) return;
    setState(() => _toggling = true);
    final result = await widget.onToggleActivation!();
    if (!mounted) return;
    setState(() => _toggling = false);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final newActive = data?['isActive'] as bool? ?? !_isActive;
      setState(() => _isActive = newActive);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(newActive ? 'Job is now LIVE \u2713' : 'Job hidden from applicants'),
        backgroundColor:
            newActive ? const Color(0xFF059669) : const Color(0xFF6B7280),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      final msg =
          result['message']?.toString() ?? 'Failed to toggle activation';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final job = widget.job;
    final primaryColor = widget.primaryColor;
    final isLive = _isActive;
    final location =
        [job.area, job.city].where((s) => s.isNotEmpty).join(', ');
    final hasImages = job.images.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _MyJobDetailScreen(
            job: widget.job,
            primaryColor: widget.primaryColor,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // \u2500\u2500 Header row \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
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
                    child: Icon(Icons.work_outline_rounded,
                        color: primaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.workTitle.isEmpty ? 'Untitled Job' : job.workTitle,
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
                              Icon(Icons.location_on_outlined,
                                  size: 12,
                                  color: cs.onSurface.withValues(alpha: 0.4)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface
                                          .withValues(alpha: 0.55)),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: isLive
                          ? const Color(0xFF059669).withValues(alpha: 0.12)
                          : cs.onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isLive
                            ? const Color(0xFF059669).withValues(alpha: 0.4)
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
                          isLive ? 'Live' : 'Hidden',
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

            // \u2500\u2500 Info chips \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...job.target.map((t) => _chip(
                        icon: Icons.person_search_rounded,
                        label: 'For: ${_targetLabel(t)}',
                        textColor: const Color(0xFF0369A1),
                      )),
                  _chip(
                    icon: Icons.groups_rounded,
                    label:
                        'Need: ${job.workersNeeded} Worker${job.workersNeeded == 1 ? '' : 's'}',
                    textColor: const Color(0xFF15803D),
                  ),
                  if (job.createdAt != null)
                    _chip(
                      icon: Icons.calendar_today_outlined,
                      label: 'Posted: ${_fmtDate(job.createdAt)}',
                      textColor: const Color(0xFF6D28D9),
                    ),
                ],
              ),
            ),

            // \u2500\u2500 Skills \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
            if (job.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.build_circle_outlined,
                            size: 13,
                            color: primaryColor.withValues(alpha: 0.7)),
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
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          primaryColor.withValues(alpha: 0.3)),
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
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],

            // \u2500\u2500 Description \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 13,
                            color: cs.onSurface.withValues(alpha: 0.4)),
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

            // \u2500\u2500 Images strip \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
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
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: cs.onSurface.withValues(alpha: 0.08),
                          child: Icon(Icons.broken_image_outlined,
                              color: cs.onSurface.withValues(alpha: 0.3),
                              size: 24),
                        ),
                        loadingBuilder: (_, child, progress) =>
                            progress == null
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
                                            color: primaryColor),
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

            // \u2500\u2500 Toggle visibility \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
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
                      isLive ? 'Deactivate (Hide Job)' : 'Activate (Make Live)'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isLive
                          ? const Color(0xFFDC2626).withValues(alpha: 0.5)
                          : const Color(0xFF059669).withValues(alpha: 0.5),
                    ),
                    foregroundColor: isLive
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2),
                  ),
                ),
              ),
            ),

            // \u2500\u2500 Action buttons \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
            Divider(height: 16, color: cs.outline.withValues(alpha: 0.12)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onTap,
                      icon: const Icon(Icons.people_rounded, size: 16),
                      label: Text(
                        'Applications${job.totalApplications > 0 ? ' (${job.totalApplications})' : ''}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onEditTap,
                      icon: Icon(Icons.edit_outlined,
                          size: 15, color: primaryColor),
                      label: const Text('Edit Job'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: primaryColor.withValues(alpha: 0.4)),
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
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
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// \u2500\u2500 Job Detail Screen \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

class _MyJobDetailScreen extends StatelessWidget {
  final MyJob job;
  final Color primaryColor;

  const _MyJobDetailScreen({required this.job, required this.primaryColor});

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final location =
        [job.area, job.city, job.state].where((s) => s.isNotEmpty).join(', ');

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
              color: cs.onSurface),
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
          // \u2500\u2500 Status + Applications \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
          Row(
            children: [
              _statusBadge(cs),
              const SizedBox(width: 8),
              _appsBadge(),
            ],
          ),

          // \u2500\u2500 Location \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
          if (location.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              cs: cs,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 18, color: Color(0xFFEF4444)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location',
                            style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.45),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(location,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface)),
                        if (job.address.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(job.address,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.55))),
                        ],
                        if (job.pincode.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('Pincode: ${job.pincode}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.55))),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // \u2500\u2500 Quick info tiles \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
          _card(
            cs: cs,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...job.target.map((t) => _infoTile(
                      icon: Icons.person_pin_outlined,
                      label: 'Target',
                      value: _targetLabel(t),
                      color: const Color(0xFF0369A1),
                    )),
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
                    value:
                        '\u20b9${job.estimatedBudget!.toStringAsFixed(0)}',
                    color: const Color(0xFF92400E),
                  ),
                _infoTile(
                  icon: Icons.assignment_outlined,
                  label: 'Status',
                  value: job.status.toUpperCase(),
                  color: primaryColor,
                ),
                if (job.createdAt != null)
                  _infoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Posted On',
                    value: _fmtDate(job.createdAt),
                    color: const Color(0xFF6D28D9),
                  ),
              ],
            ),
          ),

          // \u2500\u2500 Images \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
          if (job.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              cs: cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Photos',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface)),
                  const SizedBox(height: 10),
                  _JobImageGallery(images: job.images),
                ],
              ),
            ),
          ],

          // \u2500\u2500 Description \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
          if (job.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              cs: cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface)),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.8),
                        height: 1.55),
                  ),
                ],
              ),
            ),
          ],

          // \u2500\u2500 Skills \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
          if (job.requiredSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              cs: cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Required Skills',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: job.requiredSkills
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        primaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(s,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor)),
                            ))
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

  Widget _statusBadge(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: job.isActive
            ? const Color(0xFF059669).withValues(alpha: 0.12)
            : cs.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: job.isActive
              ? const Color(0xFF059669).withValues(alpha: 0.4)
              : cs.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: job.isActive
                  ? const Color(0xFF059669)
                  : cs.onSurface.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            job.isActive ? 'Live' : 'Hidden',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: job.isActive
                    ? const Color(0xFF059669)
                    : cs.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _appsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_rounded, size: 14, color: primaryColor),
          const SizedBox(width: 5),
          Text(
            '${job.totalApplications} Application${job.totalApplications == 1 ? '' : 's'}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryColor),
          ),
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
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: color.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// \u2500\u2500 Inline swipeable image gallery (detail screen) \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

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
                    builder: (_) => _ImageGalleryViewer(
                      images: images,
                      initialIndex: i,
                    ),
                  ),
                ),
                child: Image.network(
                  images[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: cs.onSurface.withValues(alpha: 0.08),
                    child: Center(
                      child: Icon(Icons.broken_image_outlined,
                          size: 40,
                          color: cs.onSurface.withValues(alpha: 0.3)),
                    ),
                  ),
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: cs.primary)),
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

// \u2500\u2500 Full-screen image viewer with dots \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

class _ImageGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageGalleryViewer(
      {required this.images, required this.initialIndex});

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
                          child: CircularProgressIndicator(
                              color: Colors.white)),
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
                      color:
                          _current == i ? Colors.white : Colors.white38,
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
