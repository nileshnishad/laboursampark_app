import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import '../../services/s3_upload_service.dart';
import '../../utils/toast_utils.dart';
import 'login_screen.dart';

// ── Experience options ─────────────────────────────────────────────────────
const _experienceOptions = [
  'Less than 1 year',
  '1-2 years',
  '2-3 years',
  '3-5 years',
  '5-10 years',
  '10+ years',
];

class RegisterLabourScreen extends StatefulWidget {
  const RegisterLabourScreen({super.key});

  @override
  State<RegisterLabourScreen> createState() => _RegisterLabourScreenState();
}

class _RegisterLabourScreenState extends State<RegisterLabourScreen> {
  static const _primary = Color(0xFF2563EB);

  final _formKey = GlobalKey<FormState>();

  final _nameController       = TextEditingController();
  final _ageController        = TextEditingController();
  final _emailController      = TextEditingController();
  final _mobileController     = TextEditingController();
  final _passwordController   = TextEditingController();
  final _cityController       = TextEditingController();
  final _stateController      = TextEditingController();
  final _pincodeController    = TextEditingController();
  final _addressController    = TextEditingController();
  final _skillInputController = TextEditingController();
  final _bioController        = TextEditingController();

  bool   _obscurePassword = true;
  bool   _acceptTerms     = false;
  String _experience      = _experienceOptions[3];

  final List<String> _skills = [];

  Uint8List? _photoBytes;
  String?    _photoMime;
  String?    _photoUrl;
  bool       _photoUploading = false;
  bool       _submitting     = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _skillInputController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _addSkill(String value) {
    final parts = value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    setState(() {
      for (final p in parts) {
        if (!_skills.contains(p)) _skills.add(p);
      }
      _skillInputController.clear();
    });
  }

  String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':  return 'image/png';
      case 'webp': return 'image/webp';
      default:     return 'image/jpeg';
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    XFile? xFile;
    try {
      xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    } catch (_) {
      ToastUtils.showError('Could not open image picker');
      return;
    }
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    final mime  = _mimeFromName(xFile.name);
    setState(() {
      _photoBytes     = bytes;
      _photoMime      = mime;
      _photoUrl       = null;
      _photoUploading = true;
    });

    final url = await S3UploadService.upload(
      bytes: bytes,
      filename: xFile.name,
      contentType: mime,
      folder: 'labour',
    );

    if (!mounted) return;
    setState(() => _photoUploading = false);

    if (url != null) {
      setState(() => _photoUrl = url);
    } else {
      ToastUtils.showError('Photo upload failed. Try again.');
      setState(() { _photoBytes = null; _photoMime = null; });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) { ToastUtils.showError('Add at least one skill'); return; }
    if (!_acceptTerms)   { ToastUtils.showError('Please accept Terms & Conditions'); return; }
    if (_photoBytes != null && _photoUrl == null) {
      ToastUtils.showError('Please wait — profile photo is still uploading');
      return;
    }

    setState(() => _submitting = true);

    final mobile = _mobileController.text.trim();
    final normalizedMobile = mobile.startsWith('+') ? mobile : '+91$mobile';

    final body = <String, dynamic>{
      'userType':   'labour',
      'fullName':   _nameController.text.trim(),
      'age':        int.tryParse(_ageController.text.trim()) ?? 0,
      'mobile':     normalizedMobile,
      'email':      _emailController.text.trim(),
      'password':   _passwordController.text.trim(),
      'experience': _experience,
      'skills':     _skills,
      'bio':        _bioController.text.trim(),
      'termsAgreed': true,
      'location': {
        'city':    _cityController.text.trim(),
        'state':   _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'country': 'India',
        'address': _addressController.text.trim(),
      },
      if (_photoUrl != null) 'profilePhotoUrl': _photoUrl,
    };

    final result = await ApiService.registerUser(body);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] == true) {
      ToastUtils.showSuccess(result['message'] ?? 'Account created successfully!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ToastUtils.showError(result['message']?.toString() ?? 'Registration failed');
    }
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ]),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _dec(String label, {String? hint, Widget? prefix, Widget? suffix}) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefix,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border:             OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
    enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
    focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
    errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDC2626))),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5)),
    filled: true,
    fillColor: const Color(0xFFFAFAFA),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        title: const Text('Register as Labour', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Profile Photo ─────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _photoUploading ? null : _pickPhoto,
                  child: Stack(children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(
                          color: _photoUrl != null ? const Color(0xFF059669) : _primary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _photoBytes != null
                            ? Image.memory(_photoBytes!, fit: BoxFit.cover)
                            : const Icon(Icons.person_outline_rounded, size: 44, color: _primary),
                      ),
                    ),
                    if (_photoUploading)
                      Positioned.fill(child: Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x80000000)),
                        child: const Center(child: SizedBox(width: 28, height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))),
                      )),
                    Positioned(bottom: 2, right: 2,
                      child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                      )),
                  ]),
                ),
              ),
              const SizedBox(height: 6),
              Center(child: Text(
                _photoUrl != null ? 'Photo uploaded ✓' : 'Tap to add profile photo',
                style: TextStyle(
                  fontSize: 12,
                  color: _photoUrl != null ? const Color(0xFF059669) : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              )),
              const SizedBox(height: 24),

              // ── Personal Information ───────────────────────
              _sectionCard(
                title: 'Personal Information', icon: Icons.person_outline_rounded, color: _primary,
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('Full Name *', hint: 'Enter your full name',
                        prefix: const Icon(Icons.person_outline_rounded, size: 20)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _ageController,
                    decoration: _dec('Age *', hint: 'e.g. 25', prefix: const Icon(Icons.cake_outlined, size: 20)),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Age is required';
                      final age = int.tryParse(v.trim());
                      if (age == null || age < 18 || age > 70) return 'Enter valid age (18–70)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    decoration: _dec('Email Address *', hint: 'name@example.com',
                        prefix: const Icon(Icons.email_outlined, size: 20)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _mobileController,
                    decoration: _dec('Mobile Number *', hint: '+91 XXXXX XXXXX',
                        prefix: const Icon(Icons.phone_outlined, size: 20)),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Mobile number is required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Account Security ───────────────────────────
              _sectionCard(
                title: 'Account Security', icon: Icons.lock_outline_rounded, color: const Color(0xFF7C3AED),
                children: [
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _dec('Password *', hint: 'Minimum 6 characters',
                        prefix: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        )),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Password is required';
                      if (v.trim().length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Location ───────────────────────────────────
              _sectionCard(
                title: 'Location', icon: Icons.location_on_outlined, color: const Color(0xFFF59E0B),
                children: [
                  TextFormField(
                    controller: _cityController,
                    decoration: _dec('City *', hint: 'e.g. Mumbai', prefix: const Icon(Icons.location_city_outlined, size: 20)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'City is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _stateController,
                    decoration: _dec('State *', hint: 'e.g. Maharashtra', prefix: const Icon(Icons.map_outlined, size: 20)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'State is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pincodeController,
                    decoration: _dec('Pincode *', hint: 'e.g. 400001', prefix: const Icon(Icons.pin_drop_outlined, size: 20)),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Pincode is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: _dec('Full Address *', hint: 'House no., Street, Area...',
                        prefix: const Padding(padding: EdgeInsets.only(bottom: 24), child: Icon(Icons.home_outlined, size: 20))),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Work Information ───────────────────────────
              _sectionCard(
                title: 'Work Information', icon: Icons.work_outline_rounded, color: const Color(0xFF059669),
                children: [
                  DropdownButtonFormField<String>(
                    value: _experience,
                    decoration: _dec('Experience *', prefix: const Icon(Icons.timeline_outlined, size: 20)),
                    items: _experienceOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _experience = v ?? _experience),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _skillInputController,
                    decoration: _dec('Add Skills *', hint: 'Type skill, press Enter or comma',
                        prefix: const Icon(Icons.handyman_outlined, size: 20),
                        suffix: IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () => _addSkill(_skillInputController.text),
                        )),
                    onFieldSubmitted: _addSkill,
                    textInputAction: TextInputAction.done,
                  ),
                  if (_skills.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: _skills.map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFF059669).withValues(alpha: 0.1),
                        side: const BorderSide(color: Color(0xFF059669), width: 0.8),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF059669)),
                        onDeleted: () => setState(() => _skills.remove(s)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: _dec('About Yourself', hint: 'Brief description about your work...',
                        prefix: const Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.info_outline_rounded, size: 20))),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Terms ──────────────────────────────────────
              InkWell(
                onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    SizedBox(
                      width: 24, height: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeColor: _primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text.rich(TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                        children: [
                          TextSpan(text: 'Terms & Conditions',
                              style: TextStyle(color: _primary, fontWeight: FontWeight.w600)),
                        ],
                      )),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              // ── Register button ────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: (_submitting || _photoUploading) ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _submitting ? 'Creating Account...' : 'Create Account',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
