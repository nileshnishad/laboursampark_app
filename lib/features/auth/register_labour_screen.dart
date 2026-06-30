import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/models/skill_model.dart';
import '../../services/api_service.dart';
import '../../services/s3_upload_service.dart';
import '../../services/skills_service.dart';
import '../../utils/toast_utils.dart';
import 'login_screen.dart';
import 'package:flutter/services.dart';

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

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptTerms = false;
  String _experience = _experienceOptions[3];

  List<SkillModel> _availableSkills = [];
  final List<String> _selectedSkillIds = [];
  bool _skillsLoading = true;

  Uint8List? _photoBytes;
  String? _photoUrl;
  bool _photoUploading = false;
  bool _submitting = false;
  bool _fetchingLocation = false;

  // Password validation helpers
  bool _hasMinLength(String password) => password.length >= 8;
  bool _hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase(String password) => password.contains(RegExp(r'[a-z]'));
  bool _hasNumber(String password) => password.contains(RegExp(r'[0-9]'));

  bool _isPasswordValid(String password) {
    return _hasMinLength(password) &&
        _hasUppercase(password) &&
        _hasLowercase(password) &&
        _hasNumber(password);
  }

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
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (mounted) setState(() {});
    });
    _fetchSkills();
  }

  Future<void> _fetchSkills() async {
    setState(() => _skillsLoading = true);
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

  Future<void> _fetchCurrentLocation() async {
    setState(() => _fetchingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _fetchingLocation = false);
        ToastUtils.showError('Please enable location services');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() => _fetchingLocation = false);
          ToastUtils.showError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _fetchingLocation = false);
        ToastUtils.showError(
          'Location permission permanently denied. Enable from settings.',
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];

        setState(() {
          // Fill the location fields
          if (place.locality != null && place.locality!.isNotEmpty) {
            _cityController.text = place.locality!;
          }
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            _stateController.text = place.administrativeArea!;
          }
          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            _pincodeController.text = place.postalCode!;
          }

          // Construct full address
          String address = '';
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            address += '${place.subLocality}, ';
          }
          if (place.street != null && place.street!.isNotEmpty) {
            address += '${place.street}, ';
          }
          if (place.subAdministrativeArea != null &&
              place.subAdministrativeArea!.isNotEmpty) {
            address += place.subAdministrativeArea!;
          }

          if (address.isNotEmpty) {
            _addressController.text = address;
          }

          _fetchingLocation = false;
        });

        ToastUtils.showSuccess('Location fetched successfully');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _fetchingLocation = false);
      ToastUtils.showError('Failed to fetch location: ${e.toString()}');
    }
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green[700] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? Colors.green[700] : Colors.grey[700],
                fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSkill(String skillId) {
    setState(() {
      if (_selectedSkillIds.contains(skillId)) {
        _selectedSkillIds.remove(skillId);
      } else {
        _selectedSkillIds.add(skillId);
      }
    });
  }

  void _showSkillsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.handyman_outlined, color: _primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Skills',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Choose multiple skills that match your expertise',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Skills List
              Expanded(
                child: _skillsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _availableSkills.isEmpty
                    ? const Center(
                        child: Text(
                          'No skills available',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _availableSkills.length,
                        itemBuilder: (context, index) {
                          final skill = _availableSkills[index];
                          final isSelected = _selectedSkillIds.contains(
                            skill.id,
                          );
                          return InkWell(
                            onTap: () {
                              setState(() => _toggleSkill(skill.id));
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(
                                        0xFF059669,
                                      ).withValues(alpha: 0.08)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF059669)
                                      : const Color(0xFFE5E7EB),
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
                                        ? const Color(0xFF059669)
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
                                          skill.enName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFF059669)
                                                : const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          skill.hiName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
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
                  top: 16,
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        '${_selectedSkillIds.length} skill${_selectedSkillIds.length == 1 ? '' : 's'} selected',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
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
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    XFile? xFile;
    try {
      xFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
    } catch (_) {
      ToastUtils.showError('Could not open image picker');
      return;
    }
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    final mime = _mimeFromName(xFile.name);
    setState(() {
      _photoBytes = bytes;
      _photoUrl = null;
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
      setState(() {
        _photoBytes = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkillIds.isEmpty) {
      ToastUtils.showError('Select at least one skill');
      return;
    }
    if (!_acceptTerms) {
      ToastUtils.showError('Please accept Terms & Conditions');
      return;
    }
    if (_photoBytes != null && _photoUrl == null) {
      ToastUtils.showError('Please wait — profile photo is still uploading');
      return;
    }

    setState(() => _submitting = true);

    final mobile = _mobileController.text.trim();
    final normalizedMobile = mobile.startsWith('+') ? mobile : '+91$mobile';

    final body = <String, dynamic>{
      'userType': 'labour',
      'fullName': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'mobile': normalizedMobile,
      'email': _emailController.text.trim().toLowerCase(),
      'password': _passwordController.text.trim(),
      'experience': _experience,
      'skills': _selectedSkillIds,
      'bio': _bioController.text.trim(),
      'termsAgreed': true,
      'location': {
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
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
      ToastUtils.showSuccess(
        result['message'] ?? 'Account created successfully!',
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      ToastUtils.showError(
        result['message']?.toString() ?? 'Registration failed',
      );
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
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

  InputDecoration _dec(
    String label, {
    String? hint,
    Widget? prefix,
    Widget? suffix,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefix,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDC2626)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
    ),
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
        title: const Text(
          'Register as Labour',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
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
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEFF6FF),
                            border: Border.all(
                              color: _photoUrl != null
                                  ? const Color(0xFF059669)
                                  : _primary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _photoBytes != null
                                ? Image.memory(_photoBytes!, fit: BoxFit.cover)
                                : const Icon(
                                    Icons.person_outline_rounded,
                                    size: 44,
                                    color: _primary,
                                  ),
                          ),
                        ),
                        if (_photoUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x80000000),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    _photoUrl != null
                        ? 'Photo uploaded ✓'
                        : 'Tap to add profile photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: _photoUrl != null
                          ? const Color(0xFF059669)
                          : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Personal Information ───────────────────────
                _sectionCard(
                  title: 'Personal Information',
                  icon: Icons.person_outline_rounded,
                  color: _primary,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec(
                        'Full Name *',
                        hint: 'Enter your full name',
                        prefix: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Full name is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _ageController,
                      decoration: _dec(
                        'Age *',
                        hint: 'e.g. 25',
                        prefix: const Icon(Icons.cake_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Age is required';
                        final age = int.tryParse(v.trim());
                        if (age == null || age < 18 || age > 70)
                          return 'Enter valid age (18–70)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      decoration: _dec(
                        'Email Address *',
                        hint: 'name@example.com',
                        prefix: const Icon(Icons.email_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) => newValue.copyWith(
                            text: newValue.text.toLowerCase(),
                          ),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email is required';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _mobileController,
                      decoration: _dec(
                        'Mobile Number *',
                        hint: 'XXXXX XXXXX',
                        prefix: const Icon(Icons.phone_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Mobile number is required';
                        final digits = v.trim();
                        if (digits.length != 10)
                          return 'Enter a valid 10-digit mobile number';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Account Security ───────────────────────────
                _sectionCard(
                  title: 'Account Security',
                  icon: Icons.lock_outline_rounded,
                  color: const Color(0xFF7C3AED),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.security,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Password Requirements:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildPasswordRequirement(
                            'At least 8 characters',
                            _hasMinLength(_passwordController.text),
                          ),
                          _buildPasswordRequirement(
                            'One uppercase letter (A-Z)',
                            _hasUppercase(_passwordController.text),
                          ),
                          _buildPasswordRequirement(
                            'One lowercase letter (a-z)',
                            _hasLowercase(_passwordController.text),
                          ),
                          _buildPasswordRequirement(
                            'One number (0-9)',
                            _hasNumber(_passwordController.text),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _dec(
                        'Password *',
                        hint:
                            'Minimum 8 characters with uppercase, lowercase & number',
                        prefix: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Password is required';
                        if (!_isPasswordValid(v.trim()))
                          return 'Password does not meet requirements';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Location ───────────────────────────────────
                _sectionCard(
                  title: 'Location',
                  icon: Icons.location_on_outlined,
                  color: const Color(0xFFF59E0B),
                  children: [
                    // Use Current Location Button
                    OutlinedButton.icon(
                      onPressed: _fetchingLocation
                          ? null
                          : _fetchCurrentLocation,
                      icon: _fetchingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(
                        _fetchingLocation
                            ? 'Fetching Location...'
                            : 'Use Current Location',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF59E0B),
                        side: const BorderSide(
                          color: Color(0xFFF59E0B),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: _dec(
                        'City *',
                        hint: 'e.g. Mumbai',
                        prefix: const Icon(
                          Icons.location_city_outlined,
                          size: 20,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'City is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _stateController,
                      decoration: _dec(
                        'State *',
                        hint: 'e.g. Maharashtra',
                        prefix: const Icon(Icons.map_outlined, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'State is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pincodeController,
                      decoration: _dec(
                        'Pincode *',
                        hint: 'e.g. 400001',
                        prefix: const Icon(Icons.pin_drop_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Pincode is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: _dec(
                        'Full Address *',
                        hint: 'House no., Street, Area...',
                        prefix: const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Icon(Icons.home_outlined, size: 20),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Address is required'
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Work Information ───────────────────────────
                _sectionCard(
                  title: 'Work Information',
                  icon: Icons.work_outline_rounded,
                  color: const Color(0xFF059669),
                  children: [
                    DropdownButtonFormField<String>(
                      value: _experience,
                      decoration: _dec(
                        'Experience *',
                        prefix: const Icon(Icons.timeline_outlined, size: 20),
                      ),
                      items: _experienceOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _experience = v ?? _experience),
                    ),
                    const SizedBox(height: 14),
                    // Skills Multi-Select Button
                    InkWell(
                      onTap: _skillsLoading ? null : _showSkillsBottomSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedSkillIds.isEmpty
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF059669),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.handyman_outlined,
                              size: 20,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _skillsLoading
                                  ? const Text(
                                      'Loading skills...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    )
                                  : _selectedSkillIds.isEmpty
                                  ? const Text(
                                      'Select Skills *',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    )
                                  : Text(
                                      '${_selectedSkillIds.length} skill${_selectedSkillIds.length == 1 ? '' : 's'} selected',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: _skillsLoading
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedSkillIds.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _selectedSkillIds.map((skillId) {
                          final skill = _availableSkills.firstWhere(
                            (s) => s.id == skillId,
                            orElse: () => SkillModel(
                              id: skillId,
                              enName: skillId,
                              hiName: '',
                              mrName: '',
                            ),
                          );
                          return Chip(
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  skill.enName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                                if (skill.hiName.isNotEmpty)
                                  Text(
                                    skill.hiName,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                              ],
                            ),
                            backgroundColor: const Color(
                              0xFF059669,
                            ).withValues(alpha: 0.1),
                            side: const BorderSide(
                              color: Color(0xFF059669),
                              width: 0.8,
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF059669),
                            ),
                            onDeleted: () => setState(
                              () => _selectedSkillIds.remove(skillId),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: _dec(
                        'About Yourself',
                        hint: 'Brief description about your work...',
                        prefix: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.info_outline_rounded, size: 20),
                        ),
                      ),
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
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _acceptTerms,
                            onChanged: (v) =>
                                setState(() => _acceptTerms = v ?? false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: _primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: _primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Register button ────────────────────────────
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: (_submitting || _photoUploading)
                        ? null
                        : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      _submitting ? 'Creating Account...' : 'Create Account',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
