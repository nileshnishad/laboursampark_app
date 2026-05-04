import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import '../../services/s3_upload_service.dart';
import '../../utils/toast_utils.dart';
import 'login_screen.dart';

// ── Static options ─────────────────────────────────────────────────────────

const _scExperienceOptions = [
  'Less than 1 year', '1-2 years', '2-3 years',
  '3-5 years', '5-10 years', '10+ years',
];

const _scTeamSizeOptions = [
  '1 worker', '2-5 workers', '6-10 workers',
  '11-20 workers', '21-50 workers', '50+ workers',
];

const _scBusinessTypes = [
  'General Construction',
  'Civil Construction',
  'Building Construction',
  'Electrical Work',
  'Plumbing',
  'Carpentry',
  'Painting',
  'Interior Design',
  'Road Construction',
  'Renovation',
  'Waterproofing',
  'Landscaping',
];

// ── Screen ─────────────────────────────────────────────────────────────────

class RegisterSubContractorScreen extends StatefulWidget {
  const RegisterSubContractorScreen({super.key});

  @override
  State<RegisterSubContractorScreen> createState() =>
      _RegisterSubContractorScreenState();
}

class _RegisterSubContractorScreenState
    extends State<RegisterSubContractorScreen> {
  static const _primary = Color(0xFF7C3AED);

  final _formKey = GlobalKey<FormState>();

  final _nameController         = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController        = TextEditingController();
  final _mobileController       = TextEditingController();
  final _passwordController     = TextEditingController();
  final _regNumberController    = TextEditingController();
  final _cityController         = TextEditingController();
  final _stateController        = TextEditingController();
  final _pincodeController      = TextEditingController();
  final _addressController      = TextEditingController();
  final _aboutController        = TextEditingController();

  bool   _obscurePassword = true;
  bool   _acceptTerms     = false;
  String _experienceRange = _scExperienceOptions[3];
  String _teamSize        = _scTeamSizeOptions[1];

  final Set<String> _businessTypes = {};

  // Company logo
  Uint8List? _logoBytes;
  String?    _logoUrl;
  bool       _logoUploading = false;

  // Business license
  Uint8List? _licenseBytes;
  String?    _licenseUrl;
  bool       _licenseUploading = false;

  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _regNumberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':  return 'image/png';
      case 'webp': return 'image/webp';
      case 'pdf':  return 'application/pdf';
      default:     return 'image/jpeg';
    }
  }

  Future<void> _pickLogo() async {
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
    setState(() { _logoBytes = bytes; _logoUrl = null; _logoUploading = true; });
    final url = await S3UploadService.upload(
      bytes: bytes, filename: 'company-logo-${xFile.name}',
      contentType: mime, folder: 'contractor',
    );
    if (!mounted) return;
    setState(() => _logoUploading = false);
    if (url != null) {
      setState(() => _logoUrl = url);
    } else {
      ToastUtils.showError('Logo upload failed. Try again.');
      setState(() => _logoBytes = null);
    }
  }

  Future<void> _pickLicense() async {
    final picker = ImagePicker();
    XFile? xFile;
    try {
      xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    } catch (_) {
      ToastUtils.showError('Could not open picker');
      return;
    }
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    final mime  = _mimeFromName(xFile.name);
    setState(() { _licenseBytes = bytes; _licenseUrl = null; _licenseUploading = true; });
    final url = await S3UploadService.upload(
      bytes: bytes, filename: 'business-license-${xFile.name}',
      contentType: mime, folder: 'contractor',
    );
    if (!mounted) return;
    setState(() => _licenseUploading = false);
    if (url != null) {
      setState(() => _licenseUrl = url);
    } else {
      ToastUtils.showError('License upload failed. Try again.');
      setState(() => _licenseBytes = null);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_businessTypes.isEmpty) {
      ToastUtils.showError('Select at least one business type');
      return;
    }
    if (!_acceptTerms) {
      ToastUtils.showError('Please accept Terms & Conditions');
      return;
    }
    if ((_logoBytes != null && _logoUrl == null) ||
        (_licenseBytes != null && _licenseUrl == null)) {
      ToastUtils.showError('Please wait — files are still uploading');
      return;
    }

    setState(() => _submitting = true);

    final mobile = _mobileController.text.trim();
    final normalizedMobile = mobile.startsWith('+') ? mobile : '+91$mobile';

    final body = <String, dynamic>{
      'userType':        'sub_contractor',
      'role':            'sub_contractor',
      'fullName':        _nameController.text.trim(),
      'businessName':    _businessNameController.text.trim(),
      'mobile':          normalizedMobile,
      'email':           _emailController.text.trim(),
      'password':        _passwordController.text.trim(),
      'experienceRange': _experienceRange,
      'teamSize':        _teamSize,
      'businessTypes':   _businessTypes.toList(),
      'about':           _aboutController.text.trim(),
      'termsAgreed':     true,
      'location': {
        'city':    _cityController.text.trim(),
        'state':   _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'country': 'India',
        'address': _addressController.text.trim(),
      },
      if (_regNumberController.text.trim().isNotEmpty)
        'registrationNumber': _regNumberController.text.trim(),
      if (_logoUrl != null)    'companyLogoUrl':     _logoUrl,
      if (_licenseUrl != null) 'businessLicenseUrl': _licenseUrl,
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

  // ── Widgets ────────────────────────────────────────────────────────────

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
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
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

  InputDecoration _dec(String label, {String? hint, Widget? prefix, Widget? suffix}) =>
      InputDecoration(
        labelText: label, hintText: hint, prefixIcon: prefix, suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border:             OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
        errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDC2626))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5)),
        filled: true, fillColor: const Color(0xFFFAFAFA),
      );

  Widget _uploadTile({
    required String label,
    required String hint,
    required IconData icon,
    required bool hasFile,
    required bool uploading,
    required String? url,
    required VoidCallback onTap,
  }) {
    final done = url != null;
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: done
              ? const Color(0xFFF5F3FF)
              : hasFile
                  ? const Color(0xFFFFF7ED)
                  : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: done
                ? _primary
                : hasFile
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFD1D5DB),
          ),
        ),
        child: Row(children: [
          Icon(
            done ? Icons.check_circle_rounded : uploading ? Icons.hourglass_top_rounded : icon,
            size: 20,
            color: done ? _primary : uploading ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: done ? _primary : const Color(0xFF374151))),
              const SizedBox(height: 2),
              Text(
                uploading ? 'Uploading...' : done ? 'Uploaded ✓' : hint,
                style: TextStyle(fontSize: 11, color: done ? _primary : const Color(0xFF9CA3AF)),
              ),
            ]),
          ),
          if (uploading)
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B)))
          else
            Icon(done ? Icons.edit_outlined : Icons.upload_rounded, size: 18,
                color: done ? _primary : const Color(0xFF6B7280)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0, scrolledUnderElevation: 1, surfaceTintColor: Colors.transparent,
        title: const Text('Register as Sub-Contractor',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Company Logo ──────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _logoUploading ? null : _pickLogo,
                  child: Stack(children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: const Color(0xFFF5F3FF),
                        border: Border.all(
                          color: _logoUrl != null ? _primary : _primary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _logoBytes != null
                            ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                            : const Icon(Icons.engineering_outlined, size: 42, color: _primary),
                      ),
                    ),
                    if (_logoUploading)
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
                _logoUrl != null ? 'Company logo uploaded ✓' : 'Tap to add company logo',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                    color: _logoUrl != null ? _primary : const Color(0xFF6B7280)),
              )),
              const SizedBox(height: 24),

              // ── Personal Info ─────────────────────────────
              _sectionCard(
                title: 'Personal Information', icon: Icons.person_outline_rounded,
                color: const Color(0xFF2563EB),
                children: [
                  TextFormField(
                    controller: _nameController, textCapitalization: TextCapitalization.words,
                    decoration: _dec('Full Name *', hint: 'Owner / Manager name',
                        prefix: const Icon(Icons.person_outline_rounded, size: 20)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    decoration: _dec('Email Address *', hint: 'name@company.com',
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

              // ── Account Security ──────────────────────────
              _sectionCard(
                title: 'Account Security', icon: Icons.lock_outline_rounded, color: _primary,
                children: [
                  TextFormField(
                    controller: _passwordController, obscureText: _obscurePassword,
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

              // ── Business Info ─────────────────────────────
              _sectionCard(
                title: 'Business Information', icon: Icons.engineering_outlined, color: _primary,
                children: [
                  TextFormField(
                    controller: _businessNameController, textCapitalization: TextCapitalization.words,
                    decoration: _dec('Business Name *', hint: 'Your company / firm name',
                        prefix: const Icon(Icons.storefront_outlined, size: 20)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Business name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _regNumberController,
                    decoration: _dec('Registration Number', hint: 'e.g. 3EDCVFR45TGB (optional)',
                        prefix: const Icon(Icons.numbers_rounded, size: 20)),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _experienceRange,
                    decoration: _dec('Experience Range *', prefix: const Icon(Icons.timeline_outlined, size: 20)),
                    items: _scExperienceOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _experienceRange = v ?? _experienceRange),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _teamSize,
                    decoration: _dec('Team Size *', prefix: const Icon(Icons.groups_outlined, size: 20)),
                    items: _scTeamSizeOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _teamSize = v ?? _teamSize),
                  ),
                  const SizedBox(height: 14),

                  // Business types
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.category_outlined, size: 14, color: _primary),
                    ),
                    const SizedBox(width: 8),
                    const Text('Business Types *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  ]),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _scBusinessTypes.map((type) {
                      final selected = _businessTypes.contains(type);
                      return GestureDetector(
                        onTap: () => setState(() {
                          selected ? _businessTypes.remove(type) : _businessTypes.add(type);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? _primary : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? _primary : const Color(0xFFD1D5DB)),
                          ),
                          child: Text(type, style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : const Color(0xFF6B7280),
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _aboutController, maxLines: 3,
                    decoration: _dec('About Your Business', hint: 'Brief description of your work...',
                        prefix: const Padding(padding: EdgeInsets.only(bottom: 40),
                            child: Icon(Icons.info_outline_rounded, size: 20))),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Location ──────────────────────────────────
              _sectionCard(
                title: 'Location', icon: Icons.location_on_outlined, color: const Color(0xFFF59E0B),
                children: [
                  TextFormField(
                    controller: _cityController,
                    decoration: _dec('City *', hint: 'e.g. Mumbai',
                        prefix: const Icon(Icons.location_city_outlined, size: 20)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'City is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _stateController,
                    decoration: _dec('State *', hint: 'e.g. Maharashtra',
                        prefix: const Icon(Icons.map_outlined, size: 20)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'State is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pincodeController,
                    decoration: _dec('Pincode *', hint: 'e.g. 400001',
                        prefix: const Icon(Icons.pin_drop_outlined, size: 20)),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Pincode is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController, maxLines: 2,
                    decoration: _dec('Full Address *', hint: 'Street, Area, Landmark...',
                        prefix: const Padding(padding: EdgeInsets.only(bottom: 24),
                            child: Icon(Icons.home_outlined, size: 20))),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Documents ─────────────────────────────────
              _sectionCard(
                title: 'Documents', icon: Icons.folder_outlined, color: _primary,
                children: [
                  _uploadTile(
                    label: 'Business License',
                    hint: 'Tap to upload license image',
                    icon: Icons.description_outlined,
                    hasFile: _licenseBytes != null,
                    uploading: _licenseUploading,
                    url: _licenseUrl,
                    onTap: _pickLicense,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Terms ─────────────────────────────────────
              InkWell(
                onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    SizedBox(width: 24, height: 24,
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

              // ── Register button ───────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: (_submitting || _logoUploading || _licenseUploading) ? null : _submit,
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
    );
  }
}
