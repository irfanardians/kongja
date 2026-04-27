import 'dart:convert';

// Flutter translation of cocoa/src/app/pages/RegisterTalent.tsx

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/auth_service.dart';
import '../shared/loading_splash.dart';
import 'talent_ui_shared.dart';

class RegisterTalentScreen extends StatefulWidget {
  const RegisterTalentScreen({super.key});

  @override
  State<RegisterTalentScreen> createState() => _RegisterTalentScreenState();
}

class _RegisterTalentScreenState extends State<RegisterTalentScreen> {
  bool showPassword = false;
  bool showConfirmPassword = false;
  String selectedGender = '';
  String selectedYearsOfExperience = '';
  final ImagePicker _imagePicker = ImagePicker();
  String? _identityDocumentPath;
  String? _selfieVerificationPath;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController stageNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneCountryCodeController =
      TextEditingController(text: '+62');
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();

  final List<String> selectedLanguages = [];
  final List<String> selectedSpecialties = [];

  final List<String> availableLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
  ];
  final List<String> availableSpecialties = [
    'Casual Chat',
    'Gaming',
    'Music',
    'Art',
    'Fitness',
    'Cooking',
    'Travel',
    'Technology',
    'Fashion',
    'Business',
  ];

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    stageNameController.dispose();
    bioController.dispose();
    referralController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    phoneCountryCodeController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    postcodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (stageNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Stage name is required')));
      return;
    }
    if (selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one language')),
      );
      return;
    }
    if (selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one specialty')),
      );
      return;
    }
    if (birthDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birth date is required')),
      );
      return;
    }
    if (selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gender is required')),
      );
      return;
    }
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name and last name are required')),
      );
      return;
    }
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return;
    }
    if (phoneCountryCodeController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone country code and number are required')),
      );
      return;
    }
    if (addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        countryController.text.trim().isEmpty ||
        postcodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address, city, country, and postcode are required')),
      );
      return;
    }
    if (selectedYearsOfExperience.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Years of experience is required')),
      );
      return;
    }
    if (_identityDocumentPath == null || _identityDocumentPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identity document is required')),
      );
      return;
    }
    if (_selfieVerificationPath == null || _selfieVerificationPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selfie verification is required')),
      );
      return;
    }
    final confirmed = await _showConfirmationDialog(
      title: 'Konfirmasi Register',
      message: 'Apakah Anda yakin ingin membuat akun talent ini?',
    );
    if (confirmed != true) {
      return;
    }

    try {
      await AppLoadingOverlay.of(context).run<void>(() async {
        await AuthService.registerTalent(
          fields: _buildRegisterPayload(),
          identityDocumentPath: _identityDocumentPath!,
          selfieVerificationPath: _selfieVerificationPath!,
        );
      }, message: 'Membuat akun talent...');
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }

      await _showRegisterResultDialog(
        title: 'Register Gagal',
        message: error.message,
      );
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }

      await _showRegisterResultDialog(
        title: 'Register Gagal',
        message: 'Terjadi kesalahan saat membuat akun talent. Coba lagi.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await _showRegisterResultDialog(
      title: 'Verifikasi Email Dikirim',
      message:
          'Verifikasi sudah dikirim ke email Anda. Mohon verifikasi terlebih dahulu agar akun bisa aktif.',
    );

    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final passwordsMatch =
        passwordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [talentPurple, talentPink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Become a Talent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    TalentSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Credentials',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: usernameController,
                            decoration: _inputDecoration(
                              'Username',
                              Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: passwordController,
                            obscureText: !showPassword,
                            onChanged: (_) => setState(() {}),
                            decoration:
                                _inputDecoration(
                                  'Password',
                                  Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => showPassword = !showPassword,
                                    ),
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                    ),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: !showConfirmPassword,
                            onChanged: (_) => setState(() {}),
                            decoration:
                                _inputDecoration(
                                  'Confirm Password',
                                  Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => showConfirmPassword =
                                          !showConfirmPassword,
                                    ),
                                    icon: Icon(
                                      showConfirmPassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                    ),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                passwordsMatch
                                    ? Icons.check_circle
                                    : Icons.error_outline_rounded,
                                size: 14,
                                color: passwordsMatch
                                    ? const Color(0xFF2FA655)
                                    : const Color(0xFFD94B58),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                passwordsMatch
                                    ? 'Passwords match'
                                    : 'Passwords do not match',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: passwordsMatch
                                      ? const Color(0xFF2FA655)
                                      : const Color(0xFFD94B58),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TalentSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: talentPurple,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Talent Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: stageNameController,
                            decoration: _inputDecoration(
                              'Stage Name',
                              Icons.star_rounded,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'This is how users will see you on the platform',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8780),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: bioController,
                            maxLines: 4,
                            decoration: _inputDecoration(
                              'Bio / Description',
                              Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${bioController.text.length}/500 characters',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8780),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: referralController,
                            decoration: _inputDecoration(
                              'Referral Agency (Optional)',
                              Icons.business_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: selectedYearsOfExperience.isEmpty
                                ? null
                                : selectedYearsOfExperience,
                            items: const [
                              DropdownMenuItem(
                                value: '1',
                                child: Text('1 year'),
                              ),
                              DropdownMenuItem(
                                value: '2',
                                child: Text('2 years'),
                              ),
                              DropdownMenuItem(
                                value: '3',
                                child: Text('3 years'),
                              ),
                              DropdownMenuItem(
                                value: '4',
                                child: Text('4 years'),
                              ),
                              DropdownMenuItem(
                                value: '5',
                                child: Text('5+ years'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedYearsOfExperience = value ?? '';
                              });
                            },
                            decoration: _inputDecoration(
                              'Years of Experience',
                              Icons.work_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TalentSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: selectedGender.isEmpty ? null : selectedGender,
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value ?? '';
                              });
                            },
                            decoration: _inputDecoration(
                              'Gender',
                              Icons.people_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: firstNameController,
                            decoration: _inputDecoration(
                              'First Name',
                              Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: lastNameController,
                            decoration: _inputDecoration(
                              'Last Name',
                              Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: birthDateController,
                            readOnly: true,
                            onTap: _pickBirthDate,
                            decoration: _inputDecoration(
                              'Birth Date (DD/MM/YYYY)',
                              Icons.calendar_today_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'Email Address',
                              Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: phoneCountryCodeController,
                            decoration: _inputDecoration(
                              'Phone Country Code',
                              Icons.add_call,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              'Phone Number',
                              Icons.phone_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TalentSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Address Information',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: addressController,
                            maxLines: 3,
                            decoration: _inputDecoration(
                              'Address',
                              Icons.home_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: cityController,
                            decoration: _inputDecoration(
                              'City',
                              Icons.location_city_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: countryController,
                            decoration: _inputDecoration(
                              'Country',
                              Icons.public_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: postcodeController,
                            decoration: _inputDecoration(
                              'Postcode / ZIP Code',
                              Icons.markunread_mailbox_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TalentSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Languages',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableLanguages.map((language) {
                              final active = selectedLanguages.contains(
                                language,
                              );
                              return FilterChip(
                                label: Text(language),
                                selected: active,
                                onSelected: (_) {
                                  setState(() {
                                    if (active) {
                                      selectedLanguages.remove(language);
                                    } else {
                                      selectedLanguages.add(language);
                                    }
                                  });
                                },
                                selectedColor: const Color(0xFFEDE5FF),
                                checkmarkColor: talentPurple,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Specialties',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableSpecialties.map((specialty) {
                              final active = selectedSpecialties.contains(
                                specialty,
                              );
                              return FilterChip(
                                label: Text(specialty),
                                selected: active,
                                onSelected: (_) {
                                  setState(() {
                                    if (active) {
                                      selectedSpecialties.remove(specialty);
                                    } else {
                                      selectedSpecialties.add(specialty);
                                    }
                                  });
                                },
                                selectedColor: const Color(0xFFFFE9F3),
                                checkmarkColor: talentPink,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TalentSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Identity & Media',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _uploadTile(
                            Icons.badge_outlined,
                            'Upload Identity Card',
                            'Required for verification',
                            selectedLabel: _selectedFileName(_identityDocumentPath),
                            onPressed: _pickIdentityDocument,
                          ),
                          const SizedBox(height: 12),
                          _uploadTile(
                            Icons.camera_alt_rounded,
                            'Upload Selfie Verification',
                            'Take a selfie holding your ID',
                            selectedLabel: _selectedFileName(_selfieVerificationPath),
                            onPressed: _pickSelfieVerification,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: talentPurple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Create Talent Account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFA59D96)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE6DED6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE6DED6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: talentPurple),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final initialDate = _parseBirthDate() ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    final day = picked.day.toString().padLeft(2, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final year = picked.year.toString().padLeft(4, '0');

    setState(() {
      birthDateController.text = '$day/$month/$year';
    });
  }

  Map<String, String> _buildRegisterPayload() {
    return {
      'username': usernameController.text.trim(),
      'password': passwordController.text,
      'confirm_password': confirmPasswordController.text,
      'stage_name': stageNameController.text.trim(),
      'bio': bioController.text.trim(),
      'referral_agency': referralController.text.trim(),
      'years_of_experience': selectedYearsOfExperience,
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'languages': jsonEncode(selectedLanguages),
      'specialties': jsonEncode(selectedSpecialties),
      'gender': selectedGender.toLowerCase(),
      'date_of_birth': _formatBirthDateForApi(),
      'phone_country_code': phoneCountryCodeController.text.trim(),
      'phone': _normalizeLocalPhoneNumber(),
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),
      'country': countryController.text.trim(),
      'postcode': postcodeController.text.trim(),
    };
  }

  String _formatBirthDateForApi() {
    final parsed = _parseBirthDate();
    if (parsed == null) {
      return '';
    }

    final year = parsed.year.toString().padLeft(4, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _normalizeLocalPhoneNumber() {
    final rawPhone = phoneNumberController.text.trim();
    final countryCodeDigits = phoneCountryCodeController.text.replaceAll(
      RegExp(r'\D'),
      '',
    );
    final phoneDigits = rawPhone.replaceAll(RegExp(r'\D'), '');

    if (phoneDigits.isEmpty) {
      return rawPhone;
    }

    if (countryCodeDigits.isNotEmpty &&
        phoneDigits.startsWith(countryCodeDigits)) {
      return '0${phoneDigits.substring(countryCodeDigits.length)}';
    }

    return phoneDigits.startsWith('0') ? phoneDigits : rawPhone;
  }

  Future<void> _pickIdentityDocument() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _identityDocumentPath = file.path;
    });
  }

  Future<void> _pickSelfieVerification() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _selfieVerificationPath = file.path;
    });
  }

  String? _selectedFileName(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  Future<void> _showRegisterResultDialog({
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
    );
  }

  DateTime? _parseBirthDate() {
    final raw = birthDateController.text.trim();
    if (raw.isEmpty) {
      return null;
    }

    final parts = raw.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  Widget _uploadTile(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onPressed,
    String? selectedLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6DED6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEDE5FF),
            child: Icon(icon, color: talentPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF817A74),
                  ),
                ),
                if (selectedLabel != null && selectedLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      selectedLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: talentPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          OutlinedButton(onPressed: onPressed, child: const Text('Upload')),
        ],
      ),
    );
  }
}
