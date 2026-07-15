import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../common/models/skill_model.dart';
import '../../../common/widgets/language_picker.dart';
import '../../../core/app_state.dart';
import '../../../core/user_controller.dart';
import '../../../core/auth_service.dart';
import '../../../core/services/app_logger.dart';
import '../../../services/api_service.dart';
import '../../../services/s3_upload_service.dart';
import '../../../services/skills_service.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/toast_utils.dart';
import 'profile_frame_editor_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  final String userType;
  final void Function(Map<String, dynamic> updated) onSaved;

  const EditProfileScreen({
    super.key,
    required this.profileData,
    required this.userType,
    required this.onSaved,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  late TextEditingController _fullNameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _experienceRangeCtrl;
  late TextEditingController _companyNameCtrl;
  late TextEditingController _workingHoursCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _areaCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _addressCtrl;

  String _email = '';
  String _mobile = '';

  // Profile photo
  String _profilePhotoUrl = '';
  Uint8List? _pendingPhotoBytes;
  String? _pendingPhotoName;
  bool _uploadingPhoto = false;

  // Company logo (contractor / sub_contractor only)
  String _companyLogoUrl = '';
  Uint8List? _pendingLogoBytes;
  String? _pendingLogoName;
  bool _uploadingLogo = false;

  List<String> _skills = [];
  List<String> _workTypes = [];
  List<String> _servicesOffered = [];
  List<String> _languages = [];

  // Skills from global API
  List<SkillModel> _availableSkills = [];
  bool _skillsLoading = true;

  String _selectedExperience = AppConstants.experienceOptions[3];
  DateTime? _selectedDob;

  bool _saving = false;
  String? _error;

  // Chip add controllers (persistent per list)
  final _workTypeAddCtrl = TextEditingController();
  final _servicesAddCtrl = TextEditingController();

  bool get _isContractor =>
      widget.userType.toLowerCase() == 'contractor' ||
      widget.userType.toLowerCase() == 'sub_contractor';

  @override
  void initState() {
    super.initState();
    final d = widget.profileData ?? {};
    final loc = d['location'] as Map<String, dynamic>?;
    _fullNameCtrl = TextEditingController(
      text: (d['fullName'] ?? d['name'] ?? '').toString(),
    );
    final dobRaw = (d['dob'] ?? '').toString();
    _selectedDob = dobRaw.isNotEmpty ? DateTime.tryParse(dobRaw) : null;
    _bioCtrl = TextEditingController(
      text: (d['bio'] ?? d['about'] ?? '').toString(),
    );
    final expRaw = (d['experience'] ?? '').toString();
    _selectedExperience = AppConstants.experienceOptions.contains(expRaw)
        ? expRaw
        : AppConstants.experienceOptions[3];
    _experienceRangeCtrl = TextEditingController(
      text: (d['experienceRange'] ?? '').toString(),
    );
    _companyNameCtrl = TextEditingController(
      text: (d['companyName'] ?? '').toString(),
    );
    _workingHoursCtrl = TextEditingController(
      text: (d['workingHours'] ?? '').toString(),
    );
    _cityCtrl = TextEditingController(
      text: (d['city'] ?? loc?['city'] ?? '').toString(),
    );
    _stateCtrl = TextEditingController(
      text: (d['state'] ?? loc?['state'] ?? '').toString(),
    );
    _areaCtrl = TextEditingController(text: (loc?['area'] ?? '').toString());
    _pincodeCtrl = TextEditingController(
      text: (loc?['pincode'] ?? '').toString(),
    );
    _addressCtrl = TextEditingController(
      text: (loc?['address'] ?? '').toString(),
    );
    _email = (d['email'] ?? '').toString();
    _mobile = (d['mobile'] ?? '').toString();
    _profilePhotoUrl = (d['profilePhotoUrl'] ?? '').toString();
    _companyLogoUrl = (d['companyLogoUrl'] ?? '').toString();
    _skills = _asList(d['skills']);
    _workTypes = _asList(d['workTypes']);
    _servicesOffered = _asList(d['servicesOffered'] ?? d['serviceCategories']);
    _languages = _asList(d['preferredLanguages'] ?? d['languages']);
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final cached = SkillsService.getCachedSkills();
    if (cached != null && cached.isNotEmpty) {
      if (mounted)
        setState(() {
          _availableSkills = cached;
          _skillsLoading = false;
        });
      return;
    }
    final result = await SkillsService.getAllSkills();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _availableSkills = result['skills'] as List<SkillModel>;
        _skillsLoading = false;
      });
    } else {
      setState(() => _skillsLoading = false);
      ToastUtils.showError(
        result['message']?.toString() ?? 'Failed to load skills',
      );
    }
  }

  void _toggleSkill(String skillId) {
    setState(() {
      if (_skills.contains(skillId)) {
        _skills.remove(skillId);
      } else {
        _skills.add(skillId);
      }
    });
  }

  void _showSkillsBottomSheet() {
    final langCode = context.read<AppState>().locale?.languageCode ?? 'en';
    String _skillName(SkillModel s) {
      switch (langCode) {
        case 'hi':
          return s.hiName.isNotEmpty ? s.hiName : s.enName;
        case 'mr':
          return s.mrName.isNotEmpty ? s.mrName : s.enName;
        default:
          return s.enName;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.build_outlined,
                        color: Color(0xFF7C3AED),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Skills',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose skills that match your expertise',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  ctx,
                                ).colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                // Skills list
                Expanded(
                  child: _skillsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _availableSkills.isEmpty
                      ? Center(
                          child: Text(
                            'No skills available',
                            style: TextStyle(
                              color: Theme.of(
                                ctx,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _availableSkills.length,
                          itemBuilder: (_, index) {
                            final skill = _availableSkills[index];
                            final isSelected = _skills.contains(skill.id);
                            return InkWell(
                              onTap: () {
                                setState(() => _toggleSkill(skill.id));
                                setModal(() {});
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFF7C3AED,
                                        ).withValues(alpha: 0.08)
                                      : Theme.of(
                                          ctx,
                                        ).colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF7C3AED)
                                        : Theme.of(ctx).colorScheme.outline,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isSelected
                                          ? const Color(0xFF7C3AED)
                                          : const Color(0xFF9CA3AF),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _skillName(skill),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? const Color(0xFF7C3AED)
                                                  : Theme.of(
                                                      ctx,
                                                    ).colorScheme.onSurface,
                                            ),
                                          ),
                                          if (langCode != 'en' &&
                                              skill.enName.isNotEmpty)
                                            Text(
                                              skill.enName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(ctx)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Footer
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 12 + MediaQuery.of(ctx).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_skills.length} skill${_skills.length == 1 ? '' : 's'} selected',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              ctx,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
    );
  }

  List<String> _asList(dynamic v) {
    if (v is List)
      return v.whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    return [];
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _fullNameCtrl.dispose();
    _bioCtrl.dispose();
    _experienceRangeCtrl.dispose();
    _companyNameCtrl.dispose();
    _workingHoursCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _areaCtrl.dispose();
    _pincodeCtrl.dispose();
    _addressCtrl.dispose();
    _workTypeAddCtrl.dispose();
    _servicesAddCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1200,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    // Open the LabourSampark frame editor — user positions their face
    final composited = await ProfileFrameEditorScreen.show(context, bytes);
    if (composited == null) return; // user cancelled
    setState(() {
      _pendingPhotoBytes = composited;
      _pendingPhotoName = 'profile_frame.png';
    });
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 600,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pendingLogoBytes = bytes;
      _pendingLogoName = picked.name;
    });
  }

  Future<String?> _uploadPendingPhoto() async {
    if (_pendingPhotoBytes == null) return _profilePhotoUrl;
    setState(() => _uploadingPhoto = true);
    final ext = (_pendingPhotoName ?? 'photo.jpg')
        .split('.')
        .last
        .toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    final url = await S3UploadService.upload(
      bytes: _pendingPhotoBytes!,
      filename: _pendingPhotoName ?? 'profile.jpg',
      contentType: mime,
      folder: 'uploads/profiles',
    );
    setState(() => _uploadingPhoto = false);
    return url;
  }

  Future<String?> _uploadPendingLogo() async {
    if (_pendingLogoBytes == null) return _companyLogoUrl;
    setState(() => _uploadingLogo = true);
    final ext = (_pendingLogoName ?? 'logo.jpg').split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    final url = await S3UploadService.upload(
      bytes: _pendingLogoBytes!,
      filename: _pendingLogoName ?? 'company-logo.jpg',
      contentType: mime,
      folder: 'uploads/contractor',
    );
    setState(() => _uploadingLogo = false);
    return url;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final photoUrl = await _uploadPendingPhoto();
    if (_pendingPhotoBytes != null && photoUrl == null) {
      setState(() {
        _saving = false;
        _error = 'Profile photo upload failed. Please try again.';
      });
      return;
    }

    String? logoUrl;
    if (_isContractor) {
      logoUrl = await _uploadPendingLogo();
      if (_pendingLogoBytes != null && logoUrl == null) {
        setState(() {
          _saving = false;
          _error = 'Company logo upload failed. Please try again.';
        });
        return;
      }
    }

    final token =
        Get.find<UserController>().token.value ??
        await AuthService.getAuthToken() ??
        '';
    final body = <String, dynamic>{
      'fullName': _fullNameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'experience': _selectedExperience,
      'experienceRange': _experienceRangeCtrl.text.trim(),
      'skills': _skills,
      'workTypes': _workTypes,
      'workingHours': _workingHoursCtrl.text.trim(),
      'servicesOffered': _servicesOffered,
      'preferredLanguages': _languages,
      'location': {
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'area': _areaCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      },
      if (photoUrl != null && photoUrl.isNotEmpty) 'profilePhotoUrl': photoUrl,
      if (!_isContractor && _selectedDob != null)
        'dob': _selectedDob!.toIso8601String(),
      if (_isContractor) 'companyName': _companyNameCtrl.text.trim(),
      if (_isContractor && logoUrl != null && logoUrl.isNotEmpty)
        'companyLogoUrl': logoUrl,
    };

    await AppLogger.instance.info(
      'profile_update_attempt',
      message: 'Profile update attempted',
      data: {'userType': _isContractor ? 'contractor' : 'labour'},
    );
    final res = await ApiService.updateProfile(fields: body, token: token);
    setState(() => _saving = false);

    if (res['success'] == true) {
      await AppLogger.instance.info(
        'profile_update_success',
        message: 'Profile updated successfully',
      );
      final updated = (res['data'] as Map<String, dynamic>?) ?? {};
      final merged = <String, dynamic>{
        ...(widget.profileData ?? {}),
        ...updated,
      };
      Get.find<UserController>().setUser(merged, token);
      widget.onSaved(merged);
      if (mounted) Navigator.of(context).pop();
    } else {
      await AppLogger.instance.error(
        'profile_update_failed',
        message: 'Profile update failed',
        data: {'message': res['message']},
      );
      setState(() {
        _error = (res['message'] ?? 'Update failed. Please try again.')
            .toString();
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final busy = _saving || _uploadingPhoto || _uploadingLogo;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: cs.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF2563EB),
                    ),
                  )
                : FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outline.withValues(alpha: 0.15)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverToBoxAdapter(child: _buildContent(cs)),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
      // Sticky bottom save bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            top: BorderSide(color: cs.outline.withValues(alpha: 0.15)),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        child: SizedBox(
          height: 50,
          child: FilledButton(
            onPressed: busy ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              disabledBackgroundColor: const Color(
                0xFF2563EB,
              ).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ── Error banner ──────────────────────────────────────────────────
          if (_error != null) ...[
            _ErrorBanner(
              message: _error!,
              onDismiss: () => setState(() => _error = null),
            ),
            const SizedBox(height: 16),
          ],

          // ── Photo section ─────────────────────────────────────────────────
          if (_isContractor)
            _ContractorPhotosRow(
              profilePhotoBytes: _pendingPhotoBytes,
              profilePhotoUrl: _profilePhotoUrl,
              uploadingProfile: _uploadingPhoto,
              onPickProfile: _pickPhoto,
              logoBytes: _pendingLogoBytes,
              logoUrl: _companyLogoUrl,
              uploadingLogo: _uploadingLogo,
              onPickLogo: _pickLogo,
            )
          else
            _PhotoHero(
              photoBytes: _pendingPhotoBytes,
              photoUrl: _profilePhotoUrl,
              uploading: _uploadingPhoto,
              onTap: _pickPhoto,
            ),
          const SizedBox(height: 24),

          // ── Account (read-only) ───────────────────────────────────────────
          _SectionHeader(
            label: 'ACCOUNT',
            icon: Icons.lock_outline_rounded,
            color: cs.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyField(
                  label: 'Email',
                  value: _email,
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReadOnlyField(
                  label: 'Mobile',
                  value: _mobile,
                  icon: Icons.phone_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Basic information ─────────────────────────────────────────────
          _SectionHeader(
            label: 'BASIC INFORMATION',
            icon: Icons.person_outline_rounded,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 10),
          _buildField(
            _fullNameCtrl,
            'Full Name',
            Icons.badge_outlined,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          if (_isContractor)
            _buildField(
              _companyNameCtrl,
              'Company Name',
              Icons.business_outlined,
            ),
          if (!_isContractor) ...[
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDob ?? DateTime(now.year - 25),
                  firstDate: DateTime(1950),
                  lastDate: DateTime(now.year - 18, now.month, now.day),
                  helpText: 'Select Date of Birth',
                );
                if (picked != null) setState(() => _selectedDob = picked);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      size: 20,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDob == null
                            ? 'Date of Birth'
                            : '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}',
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedDob == null
                              ? cs.onSurface.withValues(alpha: 0.35)
                              : cs.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
            ),
          ],
          _buildField(
            _bioCtrl,
            'Bio / About',
            Icons.notes_rounded,
            maxLines: 3,
            hint: 'Describe yourself or your work...',
          ),
          const SizedBox(height: 6),

          // ── Work & Skills ─────────────────────────────────────────────────
          _SectionHeader(
            label: _isContractor ? 'BUSINESS DETAILS' : 'WORK & SKILLS',
            icon: Icons.work_outline_rounded,
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 10),
          // Experience dropdown
          DropdownButtonFormField<String>(
            value: _selectedExperience,
            decoration: InputDecoration(
              labelText: 'Experience',
              prefixIcon: const Icon(Icons.timeline_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF7C3AED),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.02),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            items: AppConstants.experienceOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedExperience = v ?? _selectedExperience),
          ),
          const SizedBox(height: 10),

          // ── Skills picker ──────────────────────────────────────────────
          Builder(
            builder: (ctx) {
              final langCode =
                  context.read<AppState>().locale?.languageCode ?? 'en';
              String skillName(SkillModel s) {
                switch (langCode) {
                  case 'hi':
                    return s.hiName.isNotEmpty ? s.hiName : s.enName;
                  case 'mr':
                    return s.mrName.isNotEmpty ? s.mrName : s.enName;
                  default:
                    return s.enName;
                }
              }

              return GestureDetector(
                onTap: _showSkillsBottomSheet,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.build_outlined,
                            size: 14,
                            color: Color(0xFF7C3AED),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Skills',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7C3AED),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          if (_skillsLoading)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF7C3AED),
                              ),
                            )
                          else
                            const Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Color(0xFF7C3AED),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_skills.isEmpty)
                        Text(
                          'Tap to select skills',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.35),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _skills.map((id) {
                            final match = _availableSkills
                                .where((s) => s.id == id)
                                .firstOrNull;
                            final name = match != null ? skillName(match) : id;
                            return GestureDetector(
                              onTap: () => setState(() => _skills.remove(id)),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF7C3AED,
                                    ).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF7C3AED),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.close_rounded,
                                      size: 13,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 6),
          LanguageSelectorField(
            selected: _languages,
            onChanged: (v) => setState(() => _languages = v),
          ),
          const SizedBox(height: 20),

          // ── Location ──────────────────────────────────────────────────────
          _SectionHeader(
            label: 'LOCATION',
            icon: Icons.location_on_outlined,
            color: const Color(0xFF059669),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  _cityCtrl,
                  'City',
                  Icons.location_city_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField(_stateCtrl, 'State', Icons.map_outlined),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  _areaCtrl,
                  'Area / Locality',
                  Icons.near_me_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField(
                  _pincodeCtrl,
                  'Pincode',
                  Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          _buildField(
            _addressCtrl,
            'Full Address',
            Icons.home_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? hint,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            size: 18,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
          filled: true,
          fillColor: cs.onSurface.withValues(alpha: 0.025),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
          ),
          labelStyle: TextStyle(
            fontSize: 13,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
          hintStyle: TextStyle(
            fontSize: 13,
            color: cs.onSurface.withValues(alpha: 0.3),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: maxLines > 1 ? 14 : 0,
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          color: cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onSurface.withValues(alpha: 0.3)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.35),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            size: 13,
            color: cs.onSurface.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

class _PhotoHero extends StatelessWidget {
  final Uint8List? photoBytes;
  final String photoUrl;
  final bool uploading;
  final VoidCallback onTap;

  const _PhotoHero({
    required this.photoBytes,
    required this.photoUrl,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const accent = Color(0xFF2563EB);

    ImageProvider? bg;
    if (photoBytes != null) {
      bg = MemoryImage(photoBytes!);
    } else if (photoUrl.isNotEmpty) {
      bg = NetworkImage(photoUrl);
    }

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.35),
                      width: 3,
                    ),
                    image: bg != null
                        ? DecorationImage(image: bg, fit: BoxFit.cover)
                        : null,
                    color: accent.withValues(alpha: 0.08),
                  ),
                  child: bg == null
                      ? Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: accent.withValues(alpha: 0.5),
                        )
                      : null,
                ),
                if (uploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            photoBytes != null
                ? 'Photo ready — saves with form'
                : 'Tap to change photo',
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contractor dual-photo row ──────────────────────────────────────────────────

class _ContractorPhotosRow extends StatelessWidget {
  final Uint8List? profilePhotoBytes;
  final String profilePhotoUrl;
  final bool uploadingProfile;
  final VoidCallback onPickProfile;

  final Uint8List? logoBytes;
  final String logoUrl;
  final bool uploadingLogo;
  final VoidCallback onPickLogo;

  const _ContractorPhotosRow({
    required this.profilePhotoBytes,
    required this.profilePhotoUrl,
    required this.uploadingProfile,
    required this.onPickProfile,
    required this.logoBytes,
    required this.logoUrl,
    required this.uploadingLogo,
    required this.onPickLogo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _PhotoTile(
          label: 'Profile Photo',
          sublabel: 'Personal',
          bytes: profilePhotoBytes,
          url: profilePhotoUrl,
          uploading: uploadingProfile,
          onTap: onPickProfile,
          accent: const Color(0xFF2563EB),
          icon: Icons.person_outline_rounded,
          cs: cs,
          round: true,
        ),
        _PhotoTile(
          label: 'Company Logo',
          sublabel: 'Business',
          bytes: logoBytes,
          url: logoUrl,
          uploading: uploadingLogo,
          onTap: onPickLogo,
          accent: const Color(0xFF059669),
          icon: Icons.business_outlined,
          cs: cs,
          round: false,
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final Uint8List? bytes;
  final String url;
  final bool uploading;
  final VoidCallback onTap;
  final Color accent;
  final IconData icon;
  final ColorScheme cs;
  final bool round;

  const _PhotoTile({
    required this.label,
    required this.sublabel,
    required this.bytes,
    required this.url,
    required this.uploading,
    required this.onTap,
    required this.accent,
    required this.icon,
    required this.cs,
    required this.round,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? bg;
    if (bytes != null)
      bg = MemoryImage(bytes!);
    else if (url.isNotEmpty)
      bg = NetworkImage(url);

    final size = 84.0;
    final radius = round ? size / 2 : 16.0;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.3),
                    width: 2.5,
                  ),
                  image: bg != null
                      ? DecorationImage(image: bg, fit: BoxFit.cover)
                      : null,
                ),
                child: bg == null
                    ? Icon(
                        icon,
                        size: 32,
                        color: accent.withValues(alpha: 0.45),
                      )
                    : null,
              ),
              if (uploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -3,
                bottom: -3,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            sublabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (bytes != null) ...[
          const SizedBox(height: 3),
          Text(
            'Ready to save',
            style: TextStyle(
              fontSize: 10,
              color: accent.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}
