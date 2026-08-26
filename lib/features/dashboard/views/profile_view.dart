import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../common/models/skill_model.dart';
import '../../../common/widgets/language_picker.dart';
import '../../../core/app_state.dart';
import '../../../services/skills_service.dart';
import '../widgets/profile_widgets.dart';

class ProfileView extends StatefulWidget {
  final String fullName;
  final String userType;
  final Map<String, dynamic>? profileData;
  final bool subscriptionActive;
  final bool profileLoading;
  final String? profileError;
  final Map<String, dynamic>? subscriptionPlan;
  final VoidCallback onRetry;
  final void Function(Map<String, dynamic>? plan) onShowSubscription;
  final Future<void> Function(String code) onAddReferralCode;
  final Future<void> Function() onShareReferral;
  final VoidCallback onSettings;
  final VoidCallback onLogout;
  final VoidCallback onUpdateProfile;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenSupport;

  const ProfileView({
    super.key,
    required this.fullName,
    required this.userType,
    required this.profileData,
    required this.subscriptionActive,
    required this.profileLoading,
    required this.profileError,
    required this.subscriptionPlan,
    required this.onRetry,
    required this.onShowSubscription,
    required this.onAddReferralCode,
    required this.onShareReferral,
    required this.onSettings,
    required this.onLogout,
    required this.onUpdateProfile,
    required this.onOpenHistory,
    required this.onOpenSupport,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _appVersion = '';
  List<SkillModel> _allSkills = [];

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadSkills();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${info.version} (${info.buildNumber})';
      });
    }
  }

  Future<void> _loadSkills() async {
    final cached = SkillsService.getCachedSkills();
    if (cached != null && cached.isNotEmpty) {
      if (mounted) setState(() => _allSkills = cached);
      return;
    }
    final result = await SkillsService.getAllSkills();
    if (mounted && result['success'] == true) {
      setState(
        () => _allSkills = (result['skills'] as List<SkillModel>? ?? []),
      );
    }
  }

  String _skillName(String idOrName, String langCode) {
    if (_allSkills.isEmpty) return idOrName;
    final match = _allSkills.where((s) => s.id == idOrName).firstOrNull;
    if (match == null) return idOrName;
    switch (langCode) {
      case 'hi':
        return match.hiName.isNotEmpty ? match.hiName : match.enName;
      case 'mr':
        return match.mrName.isNotEmpty ? match.mrName : match.enName;
      default:
        return match.enName.isNotEmpty ? match.enName : idOrName;
    }
  }

  Widget _subInfoTile(
    BuildContext ctx, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    final ics = Theme.of(ctx).colorScheme;
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: ics.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ics.onSurface,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String ut) {
    switch (ut.toLowerCase()) {
      case 'labour':
        return 'Labour Worker';
      case 'sub_contractor':
        return 'Sub Contractor';
      case 'contractor':
        return 'Contractor';
      default:
        return 'User';
    }
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String _formatDate(String isoDate) {
    if (isoDate.trim().isEmpty) return 'Not available';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return 'Not available';
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Future<void> _showReferralCodeDialog() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ReferralCodeDialog(),
    );
    if (code != null && code.isNotEmpty && mounted) {
      await widget.onAddReferralCode(code.toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final langCode = context.watch<AppState>().locale?.languageCode ?? 'en';

    final profilePhotoUrl = (widget.profileData?['profilePhotoUrl'] ?? '')
        .toString();
    final companyLogoUrl = (widget.profileData?['companyLogoUrl'] ?? '')
        .toString();
    final companyName = (widget.profileData?['companyName'] ?? '').toString();
    final about =
        (widget.profileData?['bio'] ?? widget.profileData?['about'] ?? '')
            .toString();
    final experience =
        (widget.profileData?['experience'] ??
                widget.profileData?['experienceRange'] ??
                '')
            .toString();
    final email = (widget.profileData?['email'] ?? '').toString();
    final mobile = (widget.profileData?['mobile'] ?? '').toString();
    final location = widget.profileData?['location'] as Map<String, dynamic>?;
    final city = (widget.profileData?['city'] ?? location?['city'] ?? '')
        .toString();
    final state = (widget.profileData?['state'] ?? location?['state'] ?? '')
        .toString();
    final address = (location?['address'] ?? '').toString();
    final createdAt = _formatDate(
      (widget.profileData?['createdAt'] ?? '').toString(),
    );
    final lastLogin = _formatDate(
      (widget.profileData?['lastLogin'] ?? '').toString(),
    );
    final skills = _asStringList(widget.profileData?['skills']);
    final languages = _asStringList(
      widget.profileData?['preferredLanguages'] ??
          widget.profileData?['languages'],
    );
    final dobFormatted = () {
      final raw = (widget.profileData?['dob'] ?? '').toString();
      if (raw.isEmpty) return '';
      final d = DateTime.tryParse(raw);
      if (d == null) return '';
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }();
    final userCode =
        (widget.profileData?['userCode'] ??
                widget.profileData?['user_code'] ??
                '')
            .toString()
            .trim();
    final rawId =
        (widget.profileData?['userId'] ?? widget.profileData?['_id'] ?? '')
            .toString();
    final shortId = userCode.isNotEmpty
        ? 'ID: $userCode'
        : (rawId.length > 6
              ? 'ID: #${rawId.substring(0, 6).toUpperCase()}'
              : (rawId.isNotEmpty ? 'ID: #$rawId' : ''));
    final copyableId = userCode.isNotEmpty ? userCode : rawId;

    final referralStatus = (widget.profileData?['referralStatus'] ?? '')
        .toString()
        .toUpperCase();
    final referredBy = widget.profileData?['referredBy'];
    final referredByMap = referredBy is Map<String, dynamic>
        ? referredBy
        : null;
    final referralUserCode =
        (widget.profileData?['referralUserCode'] ??
                widget.profileData?['referredByCode'] ??
                widget.profileData?['referredByUserCode'] ??
                referredByMap?['userCode'] ??
                referredByMap?['user_code'] ??
                referredByMap?['referralCode'] ??
                (referredBy is String ? referredBy : null) ??
                '')
            .toString()
            .trim()
            .toUpperCase();
    final referredByName =
        (referredByMap?['fullName'] ??
                referredByMap?['name'] ??
                widget.profileData?['referredByFullName'] ??
                '')
            .toString()
            .trim();
    final referredByUserId =
        (widget.profileData?['referredByUserId'] ??
                referredByMap?['userId'] ??
                referredByMap?['_id'] ??
                '')
            .toString()
            .trim();
    final isReferralApplied =
        referralStatus == 'REFERRED' ||
        referralUserCode.isNotEmpty ||
        referredByUserId.isNotEmpty ||
        referredBy != null;

    final displayVerified = (widget.profileData?['display'] as bool?) ?? false;
    final emailVerified =
        (widget.profileData?['emailVerified'] as bool?) ?? false;
    final mobileVerified =
        (widget.profileData?['mobileVerified'] as bool?) ?? false;
    final aadharVerified =
        (widget.profileData?['aadharVerified'] as bool?) ?? false;
    final availability =
        (widget.profileData?['availability'] as bool?) ?? false;

    final isContractor = widget.userType.toLowerCase() == 'contractor';
    final isSubContractor = widget.userType.toLowerCase() == 'sub_contractor';
    final avatarColor = isContractor
        ? const Color(0xFF059669)
        : isSubContractor
        ? const Color(0xFF7C3AED)
        : const Color(0xFF2563EB);

    final nameParts = widget.fullName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (widget.fullName.isNotEmpty
              ? widget.fullName
                    .substring(0, widget.fullName.length > 1 ? 2 : 1)
                    .toUpperCase()
              : 'LS');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (widget.profileLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(color: Color(0xFF2563EB)),
          ),
        if (widget.profileError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFDC2626).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.profileError!,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onRetry,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

        // Subscription banner
        if (!widget.subscriptionActive)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attention Required',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.75),
                            fontSize: 13,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'Your profile is currently '),
                            const TextSpan(
                              text: 'hidden',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                            TextSpan(
                              text:
                                  '. To make your account visible and access all features, please pay the subscription amount.',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () =>
                      widget.onShowSubscription(widget.subscriptionPlan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text(
                    'Pay\nSubscription',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

        // Profile hero card
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: avatarColor,
                          backgroundImage:
                              (isContractor || isSubContractor) &&
                                  companyLogoUrl.isNotEmpty
                              ? NetworkImage(companyLogoUrl)
                              : profilePhotoUrl.isNotEmpty
                              ? NetworkImage(profilePhotoUrl)
                              : null,
                          child: (isContractor || isSubContractor)
                              ? (companyLogoUrl.isEmpty
                                    ? const Icon(
                                        Icons.business_center_rounded,
                                        size: 28,
                                        color: Colors.white,
                                      )
                                    : null)
                              : (profilePhotoUrl.isEmpty
                                    ? Text(
                                        initials,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null),
                        ),
                        if ((isContractor || isSubContractor) &&
                            profilePhotoUrl.isNotEmpty &&
                            companyLogoUrl.isNotEmpty)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage(profilePhotoUrl),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: displayVerified
                                    ? const Color(0xFF059669)
                                    : cs.onSurface.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fullName.isEmpty ? 'User' : widget.fullName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                          if ((isContractor || isSubContractor) &&
                              companyName.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.business_rounded,
                                  size: 13,
                                  color: avatarColor,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    companyName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: avatarColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ProfileBadge(
                                label: _roleLabel(
                                  widget.userType,
                                ).toUpperCase(),
                                color: avatarColor,
                              ),
                              if (shortId.isNotEmpty)
                                GestureDetector(
                                  onLongPress: () {
                                    if (copyableId.isEmpty) return;
                                    Clipboard.setData(
                                      ClipboardData(text: copyableId),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('User code copied'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: ProfileBadge(label: shortId),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onUpdateProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: avatarColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'UPDATE\nPROFILE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.4,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Status row
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ProfileStatusItem(
                        label: 'STATUS',
                        value: '● ONLINE',
                        valueColor: const Color(0xFF059669),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: cs.outline.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: ProfileStatusItem(
                        label: 'VISIBLE',
                        value: displayVerified ? 'VISIBLE' : 'HIDDEN',
                        valueColor: displayVerified
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: cs.outline.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: ProfileStatusItem(
                        label: isContractor ? 'HIRING' : 'AVAILABILITY',
                        value: availability
                            ? (isContractor
                                  ? 'OPEN\nTO HIRE'
                                  : 'READY TO\nWORK')
                            : (isContractor ? 'NOT HIRING' : 'BUSY'),
                        valueColor: availability
                            ? const Color(0xFF059669)
                            : cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Contact Information
        ProfileSectionCard(
          title: 'CONTACT INFORMATION',
          icon: Icons.contact_page_outlined,
          color: const Color(0xFF2563EB),
          child: ProfileInfoGrid(
            items: [
              if ((isContractor || isSubContractor) && companyName.isNotEmpty)
                ProfileInfoItem(label: 'COMPANY NAME', value: companyName),
              ProfileInfoItem(
                label: 'EMAIL',
                value: email.isEmpty ? 'Not specified' : email,
              ),
              ProfileInfoItem(
                label: 'PHONE',
                value: mobile.isEmpty ? 'Not specified' : mobile,
              ),
              if (!isContractor && !isSubContractor && dobFormatted.isNotEmpty)
                ProfileInfoItem(label: 'DATE OF BIRTH', value: dobFormatted),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Work / Business
        ProfileSectionCard(
          title: (isContractor || isSubContractor)
              ? 'BUSINESS DETAILS'
              : 'WORK EXPERIENCE & SKILLS',
          icon: (isContractor || isSubContractor)
              ? Icons.business_center_rounded
              : Icons.work_outline_rounded,
          color: const Color(0xFF7C3AED),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoGrid(
                items: [
                  ProfileInfoItem(
                    label: (isContractor || isSubContractor)
                        ? 'SPECIALIZATION'
                        : 'SKILLS',
                    value: skills.isEmpty
                        ? 'Not specified'
                        : skills
                              .map((id) => _skillName(id, langCode))
                              .join(', '),
                  ),
                  ProfileInfoItem(
                    label: 'LANGUAGES',
                    value: languages.isEmpty
                        ? 'Not specified'
                        : languages
                              .map((en) {
                                final match = kAllLanguages
                                    .where((l) => l.englishName == en)
                                    .firstOrNull;
                                return match != null
                                    ? '${match.nativeName} (${match.englishName})'
                                    : en;
                              })
                              .join(', '),
                  ),

                  ProfileInfoItem(
                    label: (isContractor || isSubContractor)
                        ? 'YEARS IN BUSINESS'
                        : 'EXPERIENCE',
                    value: experience.isEmpty ? 'Not specified' : experience,
                  ),
                ],
              ),
              if (about.isNotEmpty) ...[
                const SizedBox(height: 10),
                Builder(
                  builder: (ctx) {
                    final ics = Theme.of(ctx).colorScheme;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ics.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ics.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (isContractor || isSubContractor)
                                ? 'ABOUT COMPANY'
                                : 'ABOUT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ics.onSurface.withValues(alpha: 0.45),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            about,
                            style: TextStyle(
                              fontSize: 13,
                              color: ics.onSurface.withValues(alpha: 0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Location
        ProfileSectionCard(
          title: 'ADDRESS & LOCATION',
          icon: Icons.location_on_outlined,
          color: const Color(0xFF059669),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoGrid(
                items: [
                  ProfileInfoItem(
                    label: 'CITY',
                    value: city.isEmpty ? 'Not specified' : city,
                  ),
                  ProfileInfoItem(
                    label: 'STATE',
                    value: state.isEmpty ? 'Not specified' : state,
                  ),
                ],
              ),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 8),
                Builder(
                  builder: (ctx) {
                    final ics = Theme.of(ctx).colorScheme;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: ics.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ics.outline.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADDRESS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: ics.onSurface.withValues(alpha: 0.4),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ics.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                const SizedBox(height: 8),
                Builder(
                  builder: (ctx) {
                    final ics = Theme.of(ctx).colorScheme;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: ics.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ics.outline.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADDRESS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: ics.onSurface.withValues(alpha: 0.4),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Not specified',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ics.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Verification
        ProfileSectionCard(
          title: 'ACCOUNT TRUST & VERIFICATION',
          icon: Icons.verified_outlined,
          color: const Color(0xFF2563EB),
          child: ProfileInfoGrid(
            items: [
              ProfileInfoItem(
                label: 'EMAIL',
                value: emailVerified
                    ? '\u2713 Verified'
                    : '\u2717 Not Verified',
                valueColor: emailVerified
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
              ),
              ProfileInfoItem(
                label: 'MOBILE',
                value: mobileVerified
                    ? '\u2713 Verified'
                    : '\u2717 Not Verified',
                valueColor: mobileVerified
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
              ),
              ProfileInfoItem(
                label: 'AADHAR',
                value: aadharVerified
                    ? '\u2713 Verified'
                    : '\u2717 Not Verified',
                valueColor: aadharVerified
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
              ),
              ProfileInfoItem(label: 'ACCOUNT CREATED', value: createdAt),
              ProfileInfoItem(label: 'LAST LOGIN', value: lastLogin),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Subscription
        Builder(
          builder: (ctx) {
            final ics = Theme.of(ctx).colorScheme;

            // Subscription date fields (read from profileData with fallbacks)
            final subscribedAtRaw =
                (widget.profileData?['subscribedAt'] ??
                        widget.profileData?['subscriptionStartDate'] ??
                        widget.profileData?['displayActivatedAt'] ??
                        '')
                    .toString();
            final subscriptionEndRaw =
                (widget.profileData?['subscriptionEndDate'] ??
                        widget.profileData?['subscriptionExpiry'] ??
                        widget.profileData?['subscriptionExpiresAt'] ??
                        '')
                    .toString();

            final subscribedOn = subscribedAtRaw.isNotEmpty
                ? _formatDate(subscribedAtRaw)
                : null;

            // Calculate end date: prefer API field, fallback to activatedAt + durationDays
            final durationDaysVal =
                (widget.subscriptionPlan?['durationDays'] as num?)?.toInt();
            final startDateTime = subscribedAtRaw.isNotEmpty
                ? DateTime.tryParse(subscribedAtRaw)
                : null;

            DateTime? endDate = subscriptionEndRaw.isNotEmpty
                ? DateTime.tryParse(subscriptionEndRaw)
                : (startDateTime != null && durationDaysVal != null
                      ? startDateTime.add(Duration(days: durationDaysVal))
                      : null);

            final expiresOn = endDate != null
                ? _formatDate(endDate.toIso8601String())
                : null;

            final daysRemaining = endDate != null
                ? endDate.difference(DateTime.now()).inDays
                : null;

            if (widget.subscriptionActive) {
              // ── ACTIVE STATE ─────────────────────────────────────────
              return Container(
                decoration: BoxDecoration(
                  color: ics.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF059669).withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(13),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(
                              0xFF059669,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: Color(0xFF059669),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SUBSCRIPTION ACTIVE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: ics.onSurface,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '● ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info rows
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          // Days remaining — prominent
                          if (daysRemaining != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: daysRemaining <= 7
                                    ? const Color(
                                        0xFFDC2626,
                                      ).withValues(alpha: 0.07)
                                    : const Color(
                                        0xFF059669,
                                      ).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: daysRemaining <= 7
                                      ? const Color(
                                          0xFFDC2626,
                                        ).withValues(alpha: 0.25)
                                      : const Color(
                                          0xFF059669,
                                        ).withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    daysRemaining <= 7
                                        ? Icons.timer_outlined
                                        : Icons.hourglass_bottom_rounded,
                                    size: 28,
                                    color: daysRemaining <= 7
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF059669),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DAYS REMAINING',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: ics.onSurface.withValues(
                                            alpha: 0.45,
                                          ),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        daysRemaining <= 0
                                            ? 'Expires today'
                                            : '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} left',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: daysRemaining <= 7
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Activated on + Valid till grid
                          Row(
                            children: [
                              if (subscribedOn != null)
                                Expanded(
                                  child: _subInfoTile(
                                    ctx,
                                    label: 'ACTIVATED ON',
                                    value: subscribedOn,
                                    icon: Icons.play_circle_outline_rounded,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              if (subscribedOn != null && expiresOn != null)
                                const SizedBox(width: 8),
                              if (expiresOn != null)
                                Expanded(
                                  child: _subInfoTile(
                                    ctx,
                                    label: 'VALID TILL',
                                    value: expiresOn,
                                    icon: Icons.event_rounded,
                                    color:
                                        daysRemaining != null &&
                                            daysRemaining <= 7
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF059669),
                                  ),
                                ),
                              // Fallback when no dates available
                              if (subscribedOn == null && expiresOn == null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ics.onSurface.withValues(
                                        alpha: 0.04,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: ics.outline.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Your profile is visible to contractors and you can apply for jobs freely.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ics.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── INACTIVE STATE ────────────────────────────────────────
            final price = widget.subscriptionPlan?['price'];
            final durationDays = widget.subscriptionPlan?['durationDays'];
            final pricePerDay = widget.subscriptionPlan?['pricePerDay'] as num?;

            return Container(
              decoration: BoxDecoration(
                color: ics.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(13),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SUBSCRIPTION REQUIRED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: ics.onSurface,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price + Duration
                        if (price != null || durationDays != null) ...[
                          Row(
                            children: [
                              if (price != null)
                                Expanded(
                                  child: _subInfoTile(
                                    ctx,
                                    label: 'PLAN AMOUNT',
                                    value: '₹$price',
                                    icon: Icons.currency_rupee_rounded,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              if (price != null && durationDays != null)
                                const SizedBox(width: 8),
                              if (durationDays != null)
                                Expanded(
                                  child: _subInfoTile(
                                    ctx,
                                    label: 'VALIDITY',
                                    value: '$durationDays days',
                                    icon: Icons.date_range_rounded,
                                    color: const Color(0xFF7C3AED),
                                  ),
                                ),
                            ],
                          ),
                          if (pricePerDay != null) ...[
                            const SizedBox(height: 8),
                            _subInfoTile(
                              ctx,
                              label: 'COST PER DAY',
                              value: '₹${pricePerDay.toStringAsFixed(2)}',
                              icon: Icons.today_rounded,
                              color: const Color(0xFF059669),
                              fullWidth: true,
                            ),
                          ],
                          const SizedBox(height: 12),
                        ],

                        // Benefits
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WHAT YOU GET',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2563EB),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...[
                                'Your profile becomes visible to contractors',
                                'Apply for jobs without restrictions',
                                'Get discovered by top contractors',
                                'Access full contact details of employers',
                              ].map(
                                (benefit) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 15,
                                        color: Color(0xFF2563EB),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          benefit,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: ics.onSurface.withValues(
                                              alpha: 0.75,
                                            ),
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Pay button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onShowSubscription(
                              widget.subscriptionPlan,
                            ),
                            icon: const Icon(Icons.payment_rounded, size: 18),
                            label: const Text('Pay Now \u2014 Get Visible'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
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
            );
          },
        ),
        const SizedBox(height: 10),

        // Actions
        Builder(
          builder: (ctx) {
            final ics = Theme.of(ctx).colorScheme;
            return Container(
              decoration: BoxDecoration(
                color: ics.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ics.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  if (userCode.isNotEmpty) ...[
                    ProfileActionTile(
                      icon: Icons.card_giftcard_outlined,
                      label: 'Your Referral Code: $userCode',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: userCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Referral code copied')),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Share referral code',
                            onPressed: widget.onShareReferral,
                            icon: const Icon(Icons.share_outlined, size: 20),
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy_outlined),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: ics.outline.withValues(alpha: 0.2),
                    ),
                  ],
                  if (isReferralApplied)
                    ProfileActionTile(
                      icon: Icons.card_giftcard_outlined,
                      label: referralUserCode.isNotEmpty
                          ? (referredByName.isNotEmpty
                                ? 'Applied Referral Code: $referralUserCode ($referredByName)'
                                : 'Applied Referral Code: $referralUserCode')
                          : 'Referral Code Applied',
                      onTap: () {},
                      trailing: const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF059669),
                      ),
                    )
                  else
                    ProfileActionTile(
                      icon: Icons.card_giftcard_outlined,
                      label: 'Add Referral Code',
                      onTap: _showReferralCodeDialog,
                      trailing: const Icon(Icons.add_rounded),
                    ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: ics.outline.withValues(alpha: 0.2),
                  ),
                  ProfileActionTile(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: widget.onSettings,
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: ics.outline.withValues(alpha: 0.2),
                  ),
                  ProfileActionTile(
                    icon: Icons.refresh_rounded,
                    label: 'Refresh Profile',
                    onTap: widget.onRetry,
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: ics.outline.withValues(alpha: 0.2),
                  ),
                  ProfileActionTile(
                    icon: Icons.history_rounded,
                    label: 'History',
                    onTap: widget.onOpenHistory,
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: ics.outline.withValues(alpha: 0.2),
                  ),
                  ProfileActionTile(
                    icon: Icons.support_agent_rounded,
                    label: 'Support Tickets',
                    onTap: widget.onOpenSupport,
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: ics.outline.withValues(alpha: 0.2),
                  ),
                  ProfileActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    color: const Color(0xFFDC2626),
                    onTap: widget.onLogout,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // App Version
        if (_appVersion.isNotEmpty)
          Center(
            child: Text(
              'App Version $_appVersion',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _ReferralCodeDialog extends StatefulWidget {
  const _ReferralCodeDialog();

  @override
  State<_ReferralCodeDialog> createState() => _ReferralCodeDialogState();
}

class _ReferralCodeDialogState extends State<_ReferralCodeDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Referral Code'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            LengthLimitingTextInputFormatter(12),
            _UpperCaseTextFormatter(),
          ],
          decoration: const InputDecoration(
            labelText: 'Referral code',
            hintText: 'Enter 10 to 12 characters',
            prefixIcon: Icon(Icons.card_giftcard_outlined),
          ),
          validator: (value) {
            final length = value?.trim().length ?? 0;
            if (length < 10 || length > 12) {
              return 'Referral code must be 10 to 12 characters';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final canAdd = value.text.trim().length >= 10;
            return FilledButton(
              onPressed: canAdd
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop(_controller.text.trim());
                      }
                    }
                  : null,
              child: const Text('Add'),
            );
          },
        ),
      ],
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upperCaseText = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upperCaseText,
      selection: TextSelection.collapsed(offset: upperCaseText.length),
      composing: TextRange.empty,
    );
  }
}
