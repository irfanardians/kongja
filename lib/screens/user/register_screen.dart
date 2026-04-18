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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Semua field register
  String username = '';
  String password = '';
  String confirmPassword = '';
  String firstName = '';
  String lastName = '';
  String callName = '';
  String email = '';
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

  // Komentar backend:
  // TODO: Ganti bagian handleRegister dengan pemanggilan API POST /register
  void handleRegister() {
    // TODO: Ganti bagian ini dengan pemanggilan API POST /register
    // Jika register berhasil, arahkan ke halaman login
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match!')));
      return;
    }
    Navigator.pushReplacementNamed(context, '/login');
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
                    color: Colors.black.withOpacity(0.08),
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
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
                              const Text('Account Credentials', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              // Username
                              _buildTextField(
                                label: 'Username',
                                value: username,
                                onChanged: (v) => setState(() => username = v),
                                icon: Icons.person_outline,
                                required: true,
                                hint: 'Choose a username',
                              ),
                              const SizedBox(height: 12),
                              // Password
                              _buildPasswordField(
                                label: 'Password',
                                value: password,
                                onChanged: (v) => setState(() => password = v),
                                show: showPassword,
                                toggleShow: () => setState(() => showPassword = !showPassword),
                                required: true,
                                hint: 'Enter password',
                              ),
                              const SizedBox(height: 12),
                              // Confirm Password
                              _buildPasswordField(
                                label: 'Confirm Password',
                                value: confirmPassword,
                                onChanged: (v) => setState(() => confirmPassword = v),
                                show: showConfirmPassword,
                                toggleShow: () => setState(() => showConfirmPassword = !showConfirmPassword),
                                required: true,
                                hint: 'Re-enter password',
                              ),
                              if (password.isNotEmpty && confirmPassword.isNotEmpty && password != confirmPassword)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.error_outline, color: Colors.red, size: 16),
                                      SizedBox(width: 4),
                                      Text('Passwords do not match', style: TextStyle(color: Colors.red, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              if (password.isNotEmpty && confirmPassword.isNotEmpty && password == confirmPassword)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                                      SizedBox(width: 4),
                                      Text('Passwords match', style: TextStyle(color: Colors.green, fontSize: 12)),
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
                                  style: TextStyle(fontSize: 12, color: Color(0xFFF59E42)),
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
                              const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'First Name',
                                value: firstName,
                                onChanged: (v) => setState(() => firstName = v),
                                icon: Icons.person_outline,
                                required: true,
                                hint: 'Enter your first name',
                                helper: 'Legal name as per ID (cannot be changed later)',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Last Name',
                                value: lastName,
                                onChanged: (v) => setState(() => lastName = v),
                                icon: Icons.person_outline,
                                required: true,
                                hint: 'Enter your last name',
                                helper: 'Legal name as per ID (cannot be changed later)',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Call Name (Nickname)',
                                value: callName,
                                onChanged: (v) => setState(() => callName = v),
                                icon: Icons.person_outline,
                                required: true,
                                hint: 'How should others call you?',
                                helper: 'This is how others will see your name',
                              ),
                              const SizedBox(height: 12),
                              _buildDropdownField(
                                label: 'Gender',
                                value: gender,
                                onChanged: (v) => setState(() => gender = v ?? ''),
                                icon: Icons.people_outline,
                                required: true,
                                items: const ['Male', 'Female', 'Other'],
                                helper: 'Cannot be changed later',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Date of Birth',
                                value: dateOfBirth,
                                onChanged: (v) => setState(() => dateOfBirth = v),
                                icon: Icons.calendar_today,
                                required: true,
                                hint: 'YYYY-MM-DD',
                                isDate: true,
                                helper: 'Cannot be changed later',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Email Address',
                                value: email,
                                onChanged: (v) => setState(() => email = v),
                                icon: Icons.email_outlined,
                                required: true,
                                hint: 'Enter your email',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Phone Number',
                                value: phone,
                                onChanged: (v) => setState(() => phone = v),
                                icon: Icons.phone_outlined,
                                required: true,
                                hint: 'Enter your phone number',
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
                              const Text('Address Information', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Address',
                                value: address,
                                onChanged: (v) => setState(() => address = v),
                                icon: Icons.home_outlined,
                                required: true,
                                hint: 'Enter your full address',
                                isMultiline: true,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Country',
                                value: country,
                                onChanged: (v) => setState(() => country = v),
                                icon: Icons.public,
                                required: true,
                                hint: 'Enter your country',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'City',
                                value: city,
                                onChanged: (v) => setState(() => city = v),
                                icon: Icons.location_city,
                                required: true,
                                hint: 'Enter your city',
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Postcode / ZIP Code',
                                value: postcode,
                                onChanged: (v) => setState(() => postcode = v),
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
                                onChanged: (v) => setState(() => agree = v ?? false),
                                activeColor: const Color(0xFF1976D2),
                              ),
                              const Expanded(
                                child: Text(
                                  'I agree to the Terms of Service and Privacy Policy. I confirm that all information provided is accurate and truthful.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF0D47A1)),
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
                                  color: Colors.black.withOpacity(0.15),
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ),

                        // Login Link
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFFF59E42),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
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
    required String value,
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
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
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
                      controller: TextEditingController(text: value),
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                      ),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          onChanged(picked.toIso8601String().split('T').first);
                        }
                      },
                    )
                  : TextField(
                      controller: TextEditingController(text: value),
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
            child: Text(helper, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String value,
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
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: value),
                obscureText: !show,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9CA3AF)),
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
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
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
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onChanged,
                underline: Container(),
              ),
            ),
          ],
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(helper, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          ),
      ],
    );
  }
}
