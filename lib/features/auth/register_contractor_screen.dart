import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../common/models/business_type_model.dart';
import '../../common/widgets/language_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_state.dart';
import '../../services/api_service.dart';
import '../../services/business_type_service.dart';
import '../../utils/toast_utils.dart';
import 'login_screen.dart';
import 'package:flutter/services.dart';

// ── Static options ─────────────────────────────────────────────────────────

const _experienceOptions = [
  'Less than 1 year',
  '1-2 years',
  '2-3 years',
  '3-5 years',
  '5-10 years',
  '10+ years',
];

const _teamSizeOptions = [
  '1 worker',
  '2-5 workers',
  '6-10 workers',
  '11-20 workers',
  '21-50 workers',
  '50+ workers',
];

// ── Screen ─────────────────────────────────────────────────────────────────

class RegisterContractorScreen extends StatefulWidget {
  const RegisterContractorScreen({super.key});

  @override
  State<RegisterContractorScreen> createState() =>
      _RegisterContractorScreenState();
}

class _RegisterContractorScreenState extends State<RegisterContractorScreen> {
  bool _fetchingLocation = false;

  Future<void> _fetchCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _fetchingLocation = false);
        ToastUtils.showError('Please enable location services');
        return;
      }
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
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        setState(() {
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
      ToastUtils.showError('Failed to fetch location: e.toString()}');
    }
  }

  static const _primary = Color(0xFF059669);

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _aboutController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptTerms = false;
  String _experienceRange = _experienceOptions[3];
  String _teamSize = _teamSizeOptions[1];

  bool _submitting = false;

  DateTime? _selectedDob;
  final List<String> _selectedLanguages = ['Hindi'];

  // Password validation helpers
  bool _hasMinLength(String password) => password.length >= 8;
  bool _isPasswordValid(String password) => _hasMinLength(password);

  bool _businessTypesLoading = false;
  List<BusinessTypeModel> _availableBusinessTypes = [];
  final Set<String> _selectedBusinessTypeIds = {};

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

  @override
  void initState() {
    super.initState();
    _aboutController.text =
        'We provide quality work and are looking to connect with skilled workers.';
    _passwordController.addListener(() {
      if (mounted) setState(() {});
    });
    _fetchBusinessTypes();
  }

  Future<void> _fetchBusinessTypes() async {
    setState(() => _businessTypesLoading = true);
    final result = await BusinessTypeService.getAllBusinessTypes();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _availableBusinessTypes =
            result['businessTypes'] as List<BusinessTypeModel>;
        _businessTypesLoading = false;
      });
    } else {
      setState(() => _businessTypesLoading = false);
      ToastUtils.showError(
        result['message']?.toString() ?? 'Failed to load business types',
      );
    }
  }

  void _updateLocaleFromSelectedLanguages(List<String> selected) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (selected.contains('Hindi')) {
      appState.setLocale(const Locale('hi'));
    } else if (selected.contains('Marathi')) {
      appState.setLocale(const Locale('mr'));
    } else if (selected.contains('English')) {
      appState.setLocale(const Locale('en'));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBusinessTypeIds.isEmpty) {
      ToastUtils.showError(
        AppLocalizations.of(context).selectAtLeastOneBusinessType,
      );
      return;
    }
    if (_selectedLanguages.isEmpty) {
      ToastUtils.showError(
        AppLocalizations.of(context).selectAtLeastOneLanguage,
      );
      return;
    }
    if (!_acceptTerms) {
      ToastUtils.showError(AppLocalizations.of(context).pleaseAcceptTerms);
      return;
    }
    setState(() => _submitting = true);

    final mobile = _mobileController.text.trim();
    final normalizedMobile = mobile.startsWith('+') ? mobile : '+91$mobile';
    final email = _emailController.text.trim().toLowerCase();

    final body = <String, dynamic>{
      'userType': 'contractor',
      'role': 'contractor',
      'fullName': _nameController.text.trim(),
      'businessName': _businessNameController.text.trim(),
      'mobile': normalizedMobile,
      if (email.isNotEmpty) 'email': email,
      'password': _passwordController.text.trim(),
      'experienceRange': _experienceRange,
      'teamSize': _teamSize,
      'businessTypes': _selectedBusinessTypeIds.toList(),
      'about': _aboutController.text.trim(),
      'termsAgreed': true,
      'location': {
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'country': 'India',
        'address': _addressController.text.trim(),
      },
      if (_regNumberController.text.trim().isNotEmpty)
        'registrationNumber': _regNumberController.text.trim(),
      if (_selectedDob != null) 'dob': _selectedDob!.toIso8601String(),
      'preferredLanguages': _selectedLanguages,
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

  // ── Widgets ────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 9),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: color.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 16),
        ...children,
      ],
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
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
    fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context).registerAsContractor,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: RegistrationLocaleSwitcher(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Personal Info ───────────────────────────────
                _sectionCard(
                  title: AppLocalizations.of(context).personalInformation,
                  icon: Icons.person_outline_rounded,
                  color: const Color(0xFF2563EB),
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec(
                        '${AppLocalizations.of(context).fullName} *',
                        hint: AppLocalizations.of(context).ownerManagerNameHint,
                        prefix: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppLocalizations.of(context).fullNameRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    // DOB picker
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDob ?? DateTime(now.year - 30),
                          firstDate: DateTime(1950),
                          lastDate: DateTime(now.year - 18, now.month, now.day),
                          helpText: AppLocalizations.of(context).dateOfBirth,
                        );
                        if (picked != null)
                          setState(() => _selectedDob = picked);
                      },
                      child: InputDecorator(
                        decoration: _dec(
                          '${AppLocalizations.of(context).dateOfBirth} *',
                          prefix: const Icon(Icons.cake_outlined, size: 20),
                          suffix: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                        ),
                        child: Text(
                          _selectedDob == null
                              ? 'Select date of birth'
                              : '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}',
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedDob == null
                                ? Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.45)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      decoration: _dec(
                        AppLocalizations.of(context).email,
                        hint: AppLocalizations.of(context).emailHint,
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
                        if (v == null || v.trim().isEmpty) return null;
                        if (!v.contains('@'))
                          return AppLocalizations.of(context).enterValidEmail;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _mobileController,
                      decoration: _dec(
                        '${AppLocalizations.of(context).mobileNumber} *',
                        hint: AppLocalizations.of(context).mobileNumberHint,
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

                // ── Password ───────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _dec(
                        '${AppLocalizations.of(context).password} *',
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
                          return AppLocalizations.of(context).passwordRequired;
                        if (!_isPasswordValid(v.trim()))
                          return AppLocalizations.of(context).passwordInvalid;
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Business Info ───────────────────────────────
                _sectionCard(
                  title: AppLocalizations.of(context).businessInformation,
                  icon: Icons.business_center_rounded,
                  color: _primary,
                  children: [
                    TextFormField(
                      controller: _businessNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec(
                        '${AppLocalizations.of(context).businessName} *',
                        hint: AppLocalizations.of(context).businessNameHint,
                        prefix: const Icon(Icons.storefront_outlined, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppLocalizations.of(context).businessNameRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _regNumberController,
                      decoration: _dec(
                        'Business Reg. / GST / PAN Number',
                        hint:
                            'e.g. 27AAEPM1234C1Z5, AAAPL1234C, or any business reg. number',
                        prefix: const Icon(Icons.numbers_rounded, size: 20),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [UpperCaseTextFormatter()],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _experienceRange,
                      decoration: _dec(
                        AppLocalizations.of(context).experienceRange,
                        prefix: const Icon(Icons.timeline_outlined, size: 20),
                      ),
                      items: _experienceOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => _experienceRange = v ?? _experienceRange,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _teamSize,
                      decoration: _dec(
                        AppLocalizations.of(context).teamSize,
                        prefix: const Icon(Icons.groups_outlined, size: 20),
                      ),
                      items: _teamSizeOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _teamSize = v ?? _teamSize),
                    ),
                    const SizedBox(height: 14),

                    // Business types (multi-select dropdown style)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.category_outlined,
                            size: 14,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).businessTypes,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _businessTypesLoading
                          ? null
                          : () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setModalState) => Container(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.75,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
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
                                            color: _primary.withValues(
                                              alpha: 0.05,
                                            ),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.category_outlined,
                                                color: _primary,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      ).selectBusinessTypes,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      ).chooseBusinessTypes,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xFF6B7280,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Business Types List
                                        Expanded(
                                          child: _businessTypesLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : _availableBusinessTypes.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    ).noBusinessTypesAvailable,
                                                    style: const TextStyle(
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  itemCount:
                                                      _availableBusinessTypes
                                                          .length,
                                                  itemBuilder: (context, index) {
                                                    final type =
                                                        _availableBusinessTypes[index];
                                                    final isSelected =
                                                        _selectedBusinessTypeIds
                                                            .contains(type.id);
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (isSelected) {
                                                            _selectedBusinessTypeIds
                                                                .remove(
                                                                  type.id,
                                                                );
                                                          } else {
                                                            _selectedBusinessTypeIds
                                                                .add(type.id);
                                                          }
                                                        });
                                                        setModalState(() {});
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 12,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              14,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? _primary
                                                                    .withValues(
                                                                      alpha:
                                                                          0.08,
                                                                    )
                                                              : Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surfaceContainerLow,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors.black,
                                                            width: isSelected
                                                                ? 1.5
                                                                : 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              isSelected
                                                                  ? Icons
                                                                        .check_circle
                                                                  : Icons
                                                                        .circle_outlined,
                                                              color: isSelected
                                                                  ? _primary
                                                                  : const Color(
                                                                      0xFF9CA3AF,
                                                                    ),
                                                              size: 22,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    type.enName,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          isSelected
                                                                          ? _primary
                                                                          : Theme.of(
                                                                              context,
                                                                            ).colorScheme.onSurface,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    type.hiName,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Color(
                                                                        0xFF6B7280,
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
                                                  },
                                                ),
                                        ),
                                        // Footer
                                        Container(
                                          padding: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 16,
                                            bottom:
                                                16 +
                                                MediaQuery.of(
                                                  context,
                                                ).padding.bottom,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, -3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${_selectedBusinessTypeIds.length} selected',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _primary,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  ).done,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
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
                            },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _businessTypesLoading
                                  ? Text(
                                      AppLocalizations.of(
                                        context,
                                      ).loadingBusinessTypes,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    )
                                  : _availableBusinessTypes.isEmpty
                                  ? Text(
                                      AppLocalizations.of(
                                        context,
                                      ).noBusinessTypesAvailable,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    )
                                  : _selectedBusinessTypeIds.isEmpty
                                  ? Text(
                                      AppLocalizations.of(
                                        context,
                                      ).selectBusinessTypes,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    )
                                  : Text(
                                      '${_selectedBusinessTypeIds.length} selected',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _primary,
                                      ),
                                    ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: _businessTypesLoading
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedBusinessTypeIds.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _selectedBusinessTypeIds.map((id) {
                          final type = _availableBusinessTypes.firstWhere(
                            (t) => t.id == id,
                            orElse: () => BusinessTypeModel(
                              id: id,
                              enName: id,
                              hiName: '',
                              mrName: '',
                              category: '',
                            ),
                          );
                          return Chip(
                            label: Text(
                              type.hiName.isNotEmpty
                                  ? '${type.enName} (${type.hiName})'
                                  : type.enName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: _primary.withValues(alpha: 0.1),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => setState(
                              () => _selectedBusinessTypeIds.remove(type.id),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _aboutController,
                      maxLines: 3,
                      decoration: _dec(
                        AppLocalizations.of(context).aboutYourBusiness,
                        hint: AppLocalizations.of(context).bioHint,
                        prefix: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.info_outline_rounded, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Location ────────────────────────────────────
                _sectionCard(
                  title: AppLocalizations.of(context).locationSection,
                  icon: Icons.location_on_outlined,
                  color: const Color(0xFFF59E0B),
                  children: [
                    // Use Current Location Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _fetchingLocation
                            ? null
                            : _fetchCurrentLocation,
                        icon: _fetchingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.my_location, size: 18),
                        label: Text(
                          _fetchingLocation
                              ? AppLocalizations.of(context).fetchingLocation
                              : AppLocalizations.of(context).useCurrentLocation,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFFF59E0B,
                          ).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _cityController,
                      decoration: _dec(
                        AppLocalizations.of(context).cityLabel,
                        hint: 'e.g. Mumbai',
                        prefix: const Icon(
                          Icons.location_city_outlined,
                          size: 20,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '${AppLocalizations.of(context).cityLabel} is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _stateController,
                      decoration: _dec(
                        AppLocalizations.of(context).stateLabel,
                        hint: 'e.g. Maharashtra',
                        prefix: const Icon(Icons.map_outlined, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '${AppLocalizations.of(context).stateLabel} is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pincodeController,
                      decoration: _dec(
                        AppLocalizations.of(context).pincodeLabel,
                        hint: 'e.g. 400001',
                        prefix: const Icon(Icons.pin_drop_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '${AppLocalizations.of(context).pincodeLabel} is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: _dec(
                        AppLocalizations.of(context).fullAddress,
                        hint: AppLocalizations.of(context).addressHint,
                        prefix: const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Icon(Icons.home_outlined, size: 20),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '${AppLocalizations.of(context).fullAddress} is required'
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                LanguageSelectorField(
                  selected: _selectedLanguages,
                  onChanged: (v) => setState(() {
                    _selectedLanguages.clear();
                    _selectedLanguages.addAll(v);
                    _updateLocaleFromSelectedLanguages(v);
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).chooseSupportedLanguage,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Terms ───────────────────────────────────────
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
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).acceptTermsText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Register button ─────────────────────────────
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
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
                      _submitting
                          ? AppLocalizations.of(context).creatingAccount
                          : AppLocalizations.of(context).createAccount,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper to force uppercase input in TextFormField
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
