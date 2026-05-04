import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/user_controller.dart';
import '../../services/api_service.dart';
import '../../services/s3_upload_service.dart';
import 'models/my_job.dart';

class CreateJobScreen extends StatefulWidget {
  final String userType; // 'contractor' | 'sub_contractor'
  final MyJob? existingJob; // if set → edit mode
  const CreateJobScreen({super.key, required this.userType, this.existingJob});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _workersController = TextEditingController();
  final _skillsInputController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();

  // State
  String _target = 'labour'; // 'labour' | 'sub_contractor' | 'both'
  final List<String> _skills = [];
  final List<_NewImageItem> _newImages = []; // newly picked images (auto-uploaded)
  // Existing remote image URLs (edit mode)
  List<String> _existingImageUrls = [];
  bool _submitting = false;

  bool get _isEditMode => widget.existingJob != null;

  @override
  void initState() {
    super.initState();
    final job = widget.existingJob;
    if (job != null) {
      _titleController.text = job.workTitle;
      _workersController.text = job.workersNeeded.toString();
      _descriptionController.text = job.description;
      _cityController.text = job.city;
      _areaController.text = job.area;
      _stateController.text = job.state;
      _addressController.text = job.address;
      _pincodeController.text = job.pincode;
      if (job.estimatedBudget != null) {
        _budgetController.text = job.estimatedBudget!.toStringAsFixed(0);
      }
      _skills.addAll(job.requiredSkills);
      _existingImageUrls = List<String>.from(job.images);
      // Determine target
      if (job.target.contains('labour') && job.target.contains('sub_contractor')) {
        _target = 'both';
      } else if (job.target.contains('sub_contractor')) {
        _target = 'sub_contractor';
      } else {
        _target = 'labour';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _workersController.dispose();
    _skillsInputController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    return widget.userType == 'contractor'
        ? const Color(0xFF059669)
        : const Color(0xFF7C3AED);
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final totalImages = _newImages.length + _existingImageUrls.length;
    if (totalImages >= 5) {
      _showSnack('Maximum 5 images allowed');
      return;
    }
    final picker = ImagePicker();
    List<XFile> picked;
    try {
      picked = await picker.pickMultiImage(imageQuality: 80);
    } catch (e) {
      _showSnack('Could not open image picker. Try restarting the app.');
      return;
    }
    if (picked.isEmpty) return;

    final remaining = 5 - totalImages;
    final toAdd = picked.take(remaining).toList();

    for (final xFile in toAdd) {
      final bytes = await xFile.readAsBytes();
      if (!mounted) return;
      final item = _NewImageItem(
        bytes: bytes,
        name: xFile.name,
        mimeType: _mimeType(xFile.name),
      );
      setState(() => _newImages.add(item));
      // Auto-upload immediately in background
      _uploadSingleImage(item);
    }
  }

  Future<void> _uploadSingleImage(_NewImageItem item) async {
    debugPrint('[imgUpload] Uploading ${item.name}...');
    final url = await S3UploadService.upload(
      bytes: item.bytes,
      filename: item.name,
      contentType: item.mimeType,
    );
    if (!mounted) return;
    setState(() {
      if (url != null) {
        item.status = _UploadStatus.done;
        item.uploadedUrl = url;
        debugPrint('[imgUpload] Done: $url');
      } else {
        item.status = _UploadStatus.failed;
        debugPrint('[imgUpload] Failed for ${item.name}');
      }
    });
  }

  String _mimeType(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'heic': // image_picker compresses HEIC → JPEG bytes
      case 'heif':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  void _removeImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  // ── Skills chip input ─────────────────────────────────────────────────────

  void _addSkill(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final parts = trimmed.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    setState(() {
      for (final p in parts) {
        if (!_skills.contains(p)) _skills.add(p);
      }
      _skillsInputController.clear();
    });
  }

  void _removeSkill(String skill) => setState(() => _skills.remove(skill));

  // ── Form submit ───────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      _showSnack('Add at least one required skill');
      return;
    }

    // Block submit if any image is still uploading
    if (_newImages.any((img) => img.status == _UploadStatus.uploading)) {
      _showSnack('Please wait — images are still uploading');
      return;
    }
    // Warn about failed uploads
    if (_newImages.any((img) => img.status == _UploadStatus.failed)) {
      _showSnack('Some images failed to upload. Remove them or retry.');
      return;
    }

    setState(() => _submitting = true);

    final token = Get.find<UserController>().token.value ?? '';

    // Images already uploaded — just collect URLs
    final newImageUrls = _newImages
        .where((img) => img.uploadedUrl != null)
        .map((img) => img.uploadedUrl!)
        .toList();

    // Combine existing remote URLs + newly uploaded URLs
    final allImageUrls = [..._existingImageUrls, ...newImageUrls];

    debugPrint('══════════ [submit] IMAGE STATE ══════════');
    debugPrint('[submit] _existingImageUrls (${_existingImageUrls.length}): $_existingImageUrls');
    debugPrint('[submit] newImageUrls (${newImageUrls.length}): $newImageUrls');
    debugPrint('[submit] allImageUrls (${allImageUrls.length}): $allImageUrls');
    debugPrint('══════════════════════════════════════════');
    // Build target array
    final List<String> targetList = _target == 'both'
        ? ['labour', 'sub_contractor']
        : [_target];

    final jobData = <String, dynamic>{
      'workTitle': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'workersNeeded': int.tryParse(_workersController.text.trim()) ?? 1,
      'requiredSkills': _skills,
      'target': targetList,
      'location': {
        'city': _cityController.text.trim(),
        'area': _areaController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'state': _stateController.text.trim(),
        'address': _addressController.text.trim(),
      },
      if (_budgetController.text.trim().isNotEmpty)
        'estimatedBudget': double.tryParse(_budgetController.text.trim()),
      'images': allImageUrls,
    };

    Map<String, dynamic> result;
    if (_isEditMode) {
      result = await ApiService.updateJob(
          token: token, jobId: widget.existingJob!.id, jobData: jobData);
    } else {
      result = await ApiService.createJob(token: token, jobData: jobData);
    }
    if (!mounted) return;

    setState(() => _submitting = false);

    if (result['success'] == true || result['_id'] != null || result['data'] != null) {
      _showSnack(
          _isEditMode ? 'Job updated successfully!' : 'Job posted successfully!',
          isError: false);
      Navigator.of(context).pop(true);
    } else {
      _showSnack(result['message']?.toString() ??
          (_isEditMode ? 'Failed to update job' : 'Failed to create job'));
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final primary = _primaryColor;
    final isContractor = widget.userType == 'contractor';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isEditMode ? 'Edit Job' : (isContractor ? 'Create New Job' : 'Post a Job'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                  )
                : TextButton(
                    onPressed: _submit,
                    style: TextButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    child: Text(_isEditMode ? 'Save Changes' : 'Post Job'),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewPadding.bottom + 24),
          children: [
            // ── Job Details section ──────────────────────────
            _SectionCard(
              icon: Icons.work_outline_rounded,
              title: 'JOB DETAILS',
              color: primary,
              children: [
                _label('Work Title', required: true),
                _field(
                  controller: _titleController,
                  hint: 'e.g., Building Renovation Work',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Target', required: true),
                          _DropdownField(
                            value: _target,
                            items: const [
                              DropdownMenuItem(value: 'labour', child: Text('Labour')),
                              DropdownMenuItem(value: 'sub_contractor', child: Text('Sub-Contractor')),
                              DropdownMenuItem(value: 'both', child: Text('Both')),
                            ],
                            onChanged: (v) => setState(() => _target = v ?? _target),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Workers
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Workers Needed', required: true),
                          _field(
                            controller: _workersController,
                            hint: 'e.g., 5',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              final n = int.tryParse(v.trim());
                              if (n == null || n < 1) return 'Min 1';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _label('Required Skills', required: true),
                // Chip display
                if (_skills.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _skills.map((s) => Chip(
                      label: Text(s, style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
                      deleteIcon: Icon(Icons.close, size: 14, color: primary),
                      onDeleted: () => _removeSkill(s),
                      backgroundColor: primary.withValues(alpha: 0.08),
                      side: BorderSide(color: primary.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _skillsInputController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Mason, Carpenter (comma-separated)',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primary, width: 1.5),
                          ),
                        ),
                        onFieldSubmitted: _addSkill,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _addSkill(_skillsInputController.text),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                if (_skills.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Add at least one skill',
                        style: TextStyle(fontSize: 11, color: Colors.red.shade400)),
                  ),
                const SizedBox(height: 14),
                _label('Description', required: true),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Explain work scope, timeline, special requirements...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primary, width: 1.5),
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 14),
                _label('Estimated Budget (Optional)'),
                _field(
                  controller: _budgetController,
                  hint: 'e.g., 50000',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  prefixText: '₹ ',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Location section ──────────────────────────────
            _SectionCard(
              icon: Icons.location_on_outlined,
              title: 'WORK LOCATION',
              color: const Color(0xFF2563EB),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('City', required: true),
                          _field(
                            controller: _cityController,
                            hint: 'Mumbai',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Area', required: true),
                          _field(
                            controller: _areaController,
                            hint: 'Bandra',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Pincode', required: true),
                          _field(
                            controller: _pincodeController,
                            hint: '400050',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (v.trim().length != 6) return '6 digits';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('State', required: false, optional: true),
                          _field(
                            controller: _stateController,
                            hint: 'Maharashtra',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _label('Address'),
                _field(
                  controller: _addressController,
                  hint: 'Plot 12, Bandra West...',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Site Images section ───────────────────────────
            _SectionCard(
              icon: Icons.photo_library_outlined,
              title: 'SITE IMAGES',
              color: const Color(0xFFF59E0B),
              children: [
                if (_newImages.isEmpty && _existingImageUrls.isEmpty)
                  const Text(
                    'Add site photos to help applicants understand the work location (max 5).',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // ── Existing remote images (edit mode) ──
                    ..._existingImageUrls.asMap().entries.map((entry) {
                      final i = entry.key;
                      final url = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF059669), width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(url, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image_outlined,
                                      color: Color(0xFFD1D5DB))),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _existingImageUrls.removeAt(i)),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 13, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    ..._newImages.asMap().entries.map((entry) {
                      final i = entry.key;
                      final img = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: img.status == _UploadStatus.failed
                                    ? const Color(0xFFDC2626)
                                    : img.status == _UploadStatus.done
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.memory(img.bytes, fit: BoxFit.cover),
                                ),
                                if (img.status == _UploadStatus.uploading)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Remove button (not while uploading)
                          if (img.status != _UploadStatus.uploading)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(i),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 13, color: Colors.white),
                                ),
                              ),
                            ),
                          // Uploaded tick
                          if (img.status == _UploadStatus.done)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF059669),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                          // Failed — tap to retry
                          if (img.status == _UploadStatus.failed)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => img.status = _UploadStatus.uploading);
                                  _uploadSingleImage(img);
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.refresh, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    // Add button
                    if (_newImages.length + _existingImageUrls.length < 5)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFF59E0B), size: 28),
                              SizedBox(height: 4),
                              Text('Add', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (_newImages.isNotEmpty || _existingImageUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${_newImages.length + _existingImageUrls.length}/5 image${(_newImages.length + _existingImageUrls.length) > 1 ? 's' : ''} selected',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Submit button ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        _isEditMode ? 'Save Changes' : 'Post Job',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _label(String text, {bool required = false, bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151), letterSpacing: 0.2),
          children: [
            if (required)
              const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFDC2626))),
            if (optional)
              const TextSpan(
                text: '  (opt)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? prefixText,
    int maxLines = 1,
  }) {
    final primary = _primaryColor;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;

  const _DropdownField({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280)),
        style: const TextStyle(fontSize: 14, color: Color(0xFF111827), fontFamily: 'Poppins'),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

/// Represents a locally-picked image that is auto-uploaded to S3 on pick.
class _NewImageItem {
  final Uint8List bytes;
  final String name;
  final String mimeType;
  _UploadStatus status;
  String? uploadedUrl; // set when upload succeeds

  _NewImageItem({
    required this.bytes,
    required this.name,
    required this.mimeType,
  }) : status = _UploadStatus.uploading;
}

enum _UploadStatus { uploading, done, failed }
