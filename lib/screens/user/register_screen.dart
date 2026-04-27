// Flutter translation of cocoa/src/app/pages/Register.tsx
//
// Semua input (username, password, nama, email, phone, dst) harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - POST /register { ... }
//
// Untuk pengembangan backend, pastikan validasi dan response sesuai kebutuhan UI.

import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../shared/loading_splash.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _callNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneCountryCodeController =
      TextEditingController(text: '+62');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();

  // Semua field register
  String username = '';
  String password = '';
  String confirmPassword = '';
  String firstName = '';
  String lastName = '';
  String callName = '';
  String email = '';
  String phoneCountryCode = '+62';
  String phone = '';
  String gender = '';
  String dateOfBirth = '';
  String address = '';
  String country = '';
  String city = '';
  String postcode = '';
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool agree = false;

  @override
  void initState() {
    super.initState();
    _bindController(_usernameController, (value) => username = value);
    _bindController(_passwordController, (value) => password = value);
    _bindController(
      _confirmPasswordController,
      (value) => confirmPassword = value,
    );
    _bindController(_firstNameController, (value) => firstName = value);
    _bindController(_lastNameController, (value) => lastName = value);
    _bindController(_callNameController, (value) => callName = value);
    _bindController(_emailController, (value) => email = value);
    _bindController(
      _phoneCountryCodeController,
      (value) => phoneCountryCode = value,
    );
    _bindController(_phoneController, (value) => phone = value);
    _bindController(_addressController, (value) => address = value);
    _bindController(_countryController, (value) => country = value);
    _bindController(_cityController, (value) => city = value);
    _bindController(_postcodeController, (value) => postcode = value);

    phoneCountryCode = _phoneCountryCodeController.text;
  }

  void _bindController(
    TextEditingController controller,
    ValueChanged<String> assign,
  ) {
    assign(controller.text);
    controller.addListener(() {
      assign(controller.text);
    });
  }

  void _setDateOfBirth(DateTime value) {
    dateOfBirth = _formatDateForApi(value);
    _dateOfBirthController.text = _formatDateForDisplay(value);
  }

  String _formatDateForApi(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDateForDisplay(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  DateTime _initialDateOfBirth() {
    return DateTime.tryParse(dateOfBirth) ?? DateTime.now();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _callNameController.dispose();
    _emailController.dispose();
    _phoneCountryCodeController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  // Komentar backend:
  // TODO: Ganti bagian handleRegister dengan pemanggilan API POST /register
  Future<void> handleRegister() async {
    final validationMessage = _validateForm();
    if (validationMessage != null) {
      _showSnackBar(validationMessage);
      return;
    }

    final confirmed = await _showConfirmationDialog(
      title: 'Konfirmasi Register',
      message: 'Apakah Anda yakin ingin membuat akun ini?',
    );
    if (confirmed != true) {
      return;
    }

    try {
      await AppLoadingOverlay.of(context).run<void>(
        () => AuthService.registerUser(_buildRegisterPayload()),
        message: 'Membuat akun user...',
      );

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
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      await _showRegisterResultDialog(
        title: 'Register Gagal',
        message: error.message,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      await _showRegisterResultDialog(
        title: 'Register Gagal',
        message: 'Terjadi kesalahan saat membuat akun. Coba lagi.',
      );
    }
  }

  Map<String, dynamic> _buildRegisterPayload() {
    return {
      'username': username.trim(),
      'password': password,
      'confirm_password': confirmPassword,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'call_name': callName.trim(),
      'gender': gender.toLowerCase(),
      'date_of_birth': dateOfBirth.trim(),
      'email': email.trim(),
      'phone_country_code': phoneCountryCode.trim(),
      'phone': _normalizeLocalPhoneNumber(),
      'address': address.trim(),
      'country': country.trim(),
      'city': city.trim(),
      'postcode': postcode.trim(),
      'agree_terms': agree,
    };
  }

  String _normalizeLocalPhoneNumber() {
    final rawPhone = phone.trim();
    final countryCodeDigits = phoneCountryCode.replaceAll(RegExp(r'\D'), '');
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

  String? _validateForm() {
    if (username.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        callName.trim().isEmpty ||
        gender.isEmpty ||
        dateOfBirth.trim().isEmpty ||
        email.trim().isEmpty ||
        phoneCountryCode.trim().isEmpty ||
        phone.trim().isEmpty ||
        address.trim().isEmpty ||
        country.trim().isEmpty ||
        city.trim().isEmpty ||
        postcode.trim().isEmpty) {
      return 'Semua field wajib diisi.';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match!';
    }

    if (!agree) {
      return 'Anda harus menyetujui Terms of Service dan Privacy Policy.';
    }

    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F1E8),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF59E42), Color(0xFFFF9800)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Credentials
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Credentials',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              // Username
                              _buildTextField(
                                label: 'Username',
                                controller: _usernameController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.person_outline,
                                required: true,
                                hint: 'Choose a username',
                              ),
                              const SizedBox(height: 12),
                              // Password
                              _buildPasswordField(
                                label: 'Password',
                                controller: _passwordController,
                                onChanged: (_) => setState(() {}),
                                show: showPassword,
                                toggleShow: () => setState(
                                  () => showPassword = !showPassword,
                                ),
                                required: true,
                                hint: 'Enter password',
                              ),
                              const SizedBox(height: 12),
                              // Confirm Password
                              _buildPasswordField(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                onChanged: (_) => setState(() {}),
                                show: showConfirmPassword,
                                toggleShow: () => setState(
                                  () => showConfirmPassword =
                                      !showConfirmPassword,
                                ),
                                required: true,
                                hint: 'Re-enter password',
                              ),
                              if (password.isNotEmpty &&
                                  confirmPassword.isNotEmpty &&
                                  password != confirmPassword)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Passwords do not match',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (password.isNotEmpty &&
                                  confirmPassword.isNotEmpty &&
                                  password == confirmPassword)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Passwords match',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  border: Border.all(color: Color(0xFFFFECB3)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: const Text(
                                  'Password Requirements:\n• At least 8 characters long\n• Include uppercase and lowercase letters\n• Include at least one number\n• Include at least one special character',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFF59E42),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Personal Information
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personal Information',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'First Name',
                                controller: _firstNameController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.person_outline,
                                required: true,
                                hint: 'Enter your first name',
                                helper:
                                    'Legal name as per ID (cannot be changed later)',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Last Name',
                                controller: _lastNameController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.person_outline,
                                required: true,
                                hint: 'Enter your last name',
                                helper:
                                    'Legal name as per ID (cannot be changed later)',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Call Name (Nickname)',
                                controller: _callNameController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.person_outline,
                                required: true,
                                hint: 'How should others call you?',
                                helper: 'This is how others will see your name',
                              ),
                              const SizedBox(height: 12),
                              _buildDropdownField(
                                label: 'Gender',
                                value: gender,
                                onChanged: (v) =>
                                    setState(() => gender = v ?? ''),
                                icon: Icons.people_outline,
                                required: true,
                                items: const ['Male', 'Female', 'Other'],
                                helper: 'Cannot be changed later',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Date of Birth',
                                controller: _dateOfBirthController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.calendar_today,
                                required: true,
                                hint: 'DD/MM/YYYY',
                                isDate: true,
                                helper: 'Cannot be changed later',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Email Address',
                                controller: _emailController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.email_outlined,
                                required: true,
                                hint: 'Enter your email',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Phone Country Code',
                                controller: _phoneCountryCodeController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.add_call,
                                required: true,
                                hint: 'Contoh: +62',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.phone_outlined,
                                required: true,
                                hint: 'Contoh: 08123456789',
                                helper:
                                    'Masukkan nomor lokal tanpa kode negara.',
                              ),
                            ],
                          ),
                        ),

                        // Address Information
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Address Information',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Address',
                                controller: _addressController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.home_outlined,
                                required: true,
                                hint: 'Enter your full address',
                                isMultiline: true,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'City',
                                controller: _cityController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.location_city,
                                required: true,
                                hint: 'Enter your city',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Country',
                                controller: _countryController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.public,
                                required: true,
                                hint: 'Enter your country',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Postcode / ZIP Code',
                                controller: _postcodeController,
                                onChanged: (_) => setState(() {}),
                                icon: Icons.location_on_outlined,
                                required: true,
                                hint: 'Enter your postcode',
                              ),
                            ],
                          ),
                        ),

                        // Terms & Privacy
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            border: Border.all(color: const Color(0xFF90CAF9)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: agree,
                                onChanged: (v) =>
                                    setState(() => agree = v ?? false),
                                activeColor: const Color(0xFF1976D2),
                              ),
                              const Expanded(
                                child: Text(
                                  'I agree to the Terms of Service and Privacy Policy. I confirm that all information provided is accurate and truthful.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E42), Color(0xFFFF9800)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: agree ? handleRegister : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Login Link
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFFF59E42),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Login here'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required IconData icon,
    bool required = false,
    String? hint,
    String? helper,
    bool isMultiline = false,
    bool isDate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: const Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(
              child: isDate
                  ? TextField(
                      controller: controller,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                      ),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _initialDateOfBirth(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _setDateOfBirth(picked);
                          onChanged(controller.text);
                        }
                      },
                    )
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                      ),
                      minLines: isMultiline ? 3 : 1,
                      maxLines: isMultiline ? 5 : 1,
                    ),
            ),
          ],
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              helper,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required bool show,
    required VoidCallback toggleShow,
    bool required = false,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: !show,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                show ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9CA3AF),
              ),
              onPressed: toggleShow,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    bool required = false,
    List<String> items = const [],
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: const Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                value: value.isEmpty ? null : value,
                isExpanded: true,
                hint: const Text('Select'),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
                underline: Container(),
              ),
            ),
          ],
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              helper,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
      ],
    );
  }
}
