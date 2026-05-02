import 'package:flutter/material.dart';
import 'widgets/company_logo_picker.dart';

class RegisterContractorScreen extends StatefulWidget {
  const RegisterContractorScreen({super.key});

  @override
  State<RegisterContractorScreen> createState() => _RegisterContractorScreenState();
}

class _RegisterContractorScreenState extends State<RegisterContractorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  String? _logoPath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Widget _sectionCard({required String title, required IconData icon, required Color color, required List<Widget> children}) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF059669);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        title: const Text('Register as Contractor', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CompanyLogoPicker(
                  imagePath: _logoPath,
                  onPick: () {},
                ),
              ),
              const SizedBox(height: 24),
              _sectionCard(
                title: 'Company / Personal Information',
                icon: Icons.business_center_rounded,
                color: primary,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', hintText: 'Company or owner name', prefixIcon: Icon(Icons.person_outline_rounded, size: 20)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address', hintText: 'name@company.com', prefixIcon: Icon(Icons.email_outlined, size: 20)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _mobileController,
                    decoration: const InputDecoration(labelText: 'Mobile Number', hintText: '+91 XXXXX XXXXX', prefixIcon: Icon(Icons.phone_outlined, size: 20)),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter mobile number' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Account Security',
                icon: Icons.lock_outline_rounded,
                color: const Color(0xFF2563EB),
                children: [
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a strong password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter password' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Business Details',
                icon: Icons.work_outline_rounded,
                color: const Color(0xFF7C3AED),
                children: [
                  TextFormField(
                    controller: _skillsController,
                    decoration: const InputDecoration(labelText: 'Specialization / Trade', hintText: 'e.g. Civil, Electrical, Plumbing', prefixIcon: Icon(Icons.handyman_outlined, size: 20)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter specialization' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _experienceController,
                    decoration: const InputDecoration(labelText: 'Years in Business', hintText: 'e.g. 5 years', prefixIcon: Icon(Icons.timeline_outlined, size: 20)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter experience' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'About Your Company', hintText: 'Brief description of your business...', alignLabelWithHint: true),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter about' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24, height: 24,
                        child: Checkbox(
                          value: _acceptTerms,
                          onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          activeColor: primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                            children: [
                              TextSpan(text: 'Terms & Conditions', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true && _acceptTerms) {
                      // TODO: Submit registration
                    } else if (!_acceptTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept Terms & Conditions')));
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
