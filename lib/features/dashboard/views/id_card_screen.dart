import 'dart:io';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ── Public entry-point ────────────────────────────────────────────────────────

class IdCardScreen extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final String userType;

  const IdCardScreen({
    super.key,
    required this.profileData,
    required this.userType,
  });

  static void show(
      BuildContext context, Map<String, dynamic>? profile, String userType) {
    if (profile == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            IdCardScreen(profileData: profile, userType: userType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _IdCardPage(profileData: profileData, userType: userType);
  }
}

// ── Internal page ─────────────────────────────────────────────────────────────

class _IdCardPage extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final String userType;

  const _IdCardPage(
      {required this.profileData, required this.userType});

  @override
  State<_IdCardPage> createState() => _IdCardPageState();
}

class _IdCardPageState extends State<_IdCardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _sharing = false;

  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String get _fullName {
    final d = widget.profileData;
    return (d['fullName'] ?? d['name'] ?? '').toString().trim();
  }

  String get _userTypeLabel {
    switch (widget.userType.toLowerCase()) {
      case 'contractor':
        return 'Contractor';
      case 'sub_contractor':
        return 'Sub-Contractor';
      default:
        return 'Labour';
    }
  }

  bool get _isContractor =>
      widget.userType.toLowerCase() == 'contractor' ||
      widget.userType.toLowerCase() == 'sub_contractor';

  Color get _accentColor {
    switch (widget.userType.toLowerCase()) {
      case 'contractor':
        return const Color(0xFF7C3AED);
      case 'sub_contractor':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF2563EB);
    }
  }

  List<String> _asList(dynamic v) {
    if (v is List) {
      return v
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }
    return [];
  }

  String _locationStr() {
    final d = widget.profileData;
    final loc = d['location'] as Map<String, dynamic>?;
    final city =
        (d['city'] ?? loc?['city'] ?? '').toString().trim();
    final state =
        (d['state'] ?? loc?['state'] ?? '').toString().trim();
    if (city.isNotEmpty && state.isNotEmpty) return '$city, $state';
    if (city.isNotEmpty) return city;
    if (state.isNotEmpty) return state;
    return '';
  }

  // ── Share as image ────────────────────────────────────────────────────────

  Future<void> _shareCard(BuildContext ctx) async {
    setState(() => _sharing = true);
    try {
      // Capture the full card as PNG at 3× resolution
      final boundary =
          _cardKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Save to temp file
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/laboursampark_id_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      if (!ctx.mounted) return;

      // Open native share sheet with the full card image
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'LabourSampark ID — $_fullName',
        text: 'LabourSampark ID Card\n$_fullName | $_userTypeLabel\nLabourSampark — Connecting Workers. Building Futures.',
      );
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Could not share card: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = _accentColor;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My ID Card',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: cs.onSurface),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _sharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF2563EB)))
                : IconButton(
                    icon: Icon(Icons.ios_share_rounded,
                        color: accent),
                    tooltip: 'Share',
                    onPressed: () => _shareCard(context),
                  ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              height: 1,
              color: cs.outline.withValues(alpha: 0.15)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, MediaQuery.of(context).padding.bottom + 32),
        child: Column(
          children: [
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: _buildCard(cs, accent),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildShareButton(context, accent),
          ],
        ),
      ),
    );
  }

  // ── Card widget ───────────────────────────────────────────────────────────

  Widget _buildCard(ColorScheme cs, Color accent) {
    final d = widget.profileData;
    final photoUrl = (d['profilePhotoUrl'] ?? '').toString().trim();
    final rating =
        (d['rating'] ?? d['averageRating'] ?? 0.0) as num;
    final jobsDone = (d['totalJobsDone'] ??
            d['jobsCompleted'] ??
            d['completedJobs'] ??
            0) as num;
    final bio = (d['bio'] ?? d['about'] ?? '').toString().trim();
    final experience =
        (d['experience'] ?? '').toString().trim();
    final skills = _asList(d['skills']);
    final workTypes = _asList(d['workTypes']);
    final services = _asList(
        d['servicesOffered'] ?? d['serviceCategories']);
    final languages = _asList(d['languages']);
    final companyName =
        (d['companyName'] ?? '').toString().trim();
    final location = _locationStr();
    final mobile = (d['mobile'] ?? '').toString().trim();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cs.surface,
        border:
            Border.all(color: accent.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header band ─────────────────────────────────────────────
          _buildHeader(cs, accent, photoUrl),

          // ── Body ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                _buildStatsRow(accent, rating, jobsDone),
                const SizedBox(height: 20),

                // Bio
                if (bio.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.notes_rounded,
                    label: 'About',
                    value: bio,
                    color: accent,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                ],

                // Experience
                if (experience.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.timeline_outlined,
                    label: 'Experience',
                    value: experience,
                    color: accent,
                  ),
                  const SizedBox(height: 14),
                ],

                // Business name (contractor)
                if (_isContractor && companyName.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.business_outlined,
                    label: 'Company',
                    value: companyName,
                    color: accent,
                  ),
                  const SizedBox(height: 14),
                ],

                // Location
                if (location.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: location,
                    color: accent,
                  ),
                  const SizedBox(height: 14),
                ],

                // Mobile
                if (mobile.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Mobile',
                    value: mobile,
                    color: accent,
                  ),
                  const SizedBox(height: 14),
                ],

                // Divider
                Divider(
                    color: accent.withValues(alpha: 0.12),
                    height: 24),

                // Skills / Work types / Services
                if (!_isContractor && skills.isNotEmpty) ...[
                  _buildChipSection(
                      'Skills', skills, accent,
                      Icons.build_outlined),
                  const SizedBox(height: 12),
                ],
                if (!_isContractor && workTypes.isNotEmpty) ...[
                  _buildChipSection(
                      'Work Types', workTypes,
                      const Color(0xFF059669),
                      Icons.assignment_outlined),
                  const SizedBox(height: 12),
                ],
                if (_isContractor && services.isNotEmpty) ...[
                  _buildChipSection(
                      'Services Offered', services, accent,
                      Icons.handyman_outlined),
                  const SizedBox(height: 12),
                ],
                if (languages.isNotEmpty)
                  _buildChipSection(
                      'Languages', languages,
                      const Color(0xFFF59E0B),
                      Icons.translate_rounded),

                // Footer branding
                const SizedBox(height: 20),
                _buildFooter(accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
      ColorScheme cs, Color accent, String photoUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(19)),
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          // Profile photo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: ClipOval(
              child: photoUrl.isNotEmpty
                  ? Image.network(photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholderAvatar())
                  : _placeholderAvatar(),
            ),
          ),
          const SizedBox(width: 16),
          // Name + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullName.isEmpty ? 'User' : _fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            Colors.white.withValues(alpha: 0.45),
                        width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isContractor
                            ? Icons.business_center_rounded
                            : Icons.engineering_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _userTypeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // LabourSampark app logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderAvatar() => Container(
        color: Colors.white.withValues(alpha: 0.2),
        child: const Icon(Icons.person_rounded,
            size: 38, color: Colors.white),
      );

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(
      Color accent, num rating, num jobsDone) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            value: rating == 0
                ? '—'
                : rating.toStringAsFixed(1),
            label: 'Rating',
            accent: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF059669),
            value: jobsDone == 0 ? '0' : jobsDone.toString(),
            label: 'Jobs Done',
            accent: const Color(0xFF059669),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.verified_rounded,
            iconColor: accent,
            value: 'Active',
            label: 'Status',
            accent: accent,
          ),
        ),
      ],
    );
  }

  // ── Info row ──────────────────────────────────────────────────────────────

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Chip section ──────────────────────────────────────────────────────────

  Widget _buildChipSection(
      String label, List<String> items, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .take(8)
              .map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: color.withValues(alpha: 0.22)),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // App logo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                  color: accent.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Labour',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE53E3E),
                        ),
                      ),
                      TextSpan(
                        text: 'Sampark',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connecting Workers. Building Futures.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_rounded, size: 18, color: accent),
        ],
      ),
    );
  }

  // ── Share button ──────────────────────────────────────────────────────────

  Widget _buildShareButton(BuildContext context, Color accent) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: _sharing ? null : () => _shareCard(context),
        icon: _sharing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : const Icon(Icons.ios_share_rounded, size: 18),
        label: Text(_sharing ? 'Preparing…' : 'Share My ID Card'),
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          disabledBackgroundColor:
              accent.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color accent;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
