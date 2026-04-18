// Flutter translation of cocoa/src/app/pages/Login.tsx
//
// Semua input (email, password, tipe login) harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - POST /login { email, password, type }
//
// Untuk pengembangan backend, pastikan response mengembalikan token/user info.

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String loginType = 'user';
  bool showPassword = false;
  String email = '';
  String password = '';
  bool rememberMe = false;

  void handleLogin() {
    // TODO: Ganti bagian ini dengan pemanggilan API POST /login
    // Jika login berhasil, arahkan ke halaman berikut:
    if (loginType == 'user') {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/talent-home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFFFF3E0),
              Color(0xFFFFECB3),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Logo/Header
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF92400E), Color(0xFFF59E42)], // amber-700 to amber-600
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('💬', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Attention',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Connect with people who care',
                  style: TextStyle(color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 24),

                // Login Card
                Container(
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
                    children: [
                      // Type Selector
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6), // gray-100
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => setState(() => loginType = 'user'),
                                style: TextButton.styleFrom(
                                  backgroundColor: loginType == 'user' ? Colors.white : Colors.transparent,
                                  foregroundColor: loginType == 'user' ? Color(0xFF92400E) : Color(0xFF6B7280),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                                  elevation: loginType == 'user' ? 2 : 0,
                                ),
                                child: const Text('Login as User'),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () => setState(() => loginType = 'talent'),
                                style: TextButton.styleFrom(
                                  backgroundColor: loginType == 'talent' ? Colors.white : Colors.transparent,
                                  foregroundColor: loginType == 'talent' ? Color(0xFF92400E) : Color(0xFF6B7280),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                                  elevation: loginType == 'talent' ? 2 : 0,
                                ),
                                child: const Text('Login as Talent'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back!',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loginType == 'user'
                                  ? 'Sign in to find someone to talk with'
                                  : 'Sign in to start connecting with users',
                              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                            ),
                            const SizedBox(height: 24),

                            // Email Input
                            const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                            const SizedBox(height: 6),
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF9CA3AF)),
                                hintText: 'Enter your email',
                                filled: true,
                                fillColor: Color(0xFFF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Color(0xFFF59E42)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              ),
                              onChanged: (v) => setState(() => email = v),
                            ),
                            const SizedBox(height: 18),

                            // Password Input
                            const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                            const SizedBox(height: 6),
                            Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                TextField(
                                  obscureText: !showPassword,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
                                    hintText: 'Enter your password',
                                    filled: true,
                                    fillColor: Color(0xFFF9FAFB),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFFF59E42)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  ),
                                  onChanged: (v) => setState(() => password = v),
                                ),
                                IconButton(
                                  icon: Icon(
                                    showPassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  onPressed: () => setState(() => showPassword = !showPassword),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Remember me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      onChanged: (v) => setState(() => rememberMe = v ?? false),
                                      activeColor: Color(0xFFF59E42),
                                    ),
                                    const Text('Remember me', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(0xFF92400E),
                                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  child: const Text('Forgot Password?'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF92400E), Color(0xFFF59E42)],
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
                                  onPressed: handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                                ),
                              ),
                            ),

                            // Divider
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Or continue with', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                                  ),
                                  Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                                ],
                              ),
                            ),

                            // Social Login
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/4/4a/Logo_2013_Google.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    label: const Text('Google'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: Icon(Icons.facebook, color: Color(0xFF1877F2)),
                                    label: const Text('Facebook'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(0xFF92400E),
                                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  child: const Text('Sign Up'),
                                ),
                              ],
                            ),

                            // Talent Sign Up Link
                            if (loginType == 'talent')
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Want to become a talent? ', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/register-talent');
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Color(0xFF7C3AED),
                                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      child: const Text('Join as Talent'),
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

                // Additional Info
                const SizedBox(height: 24),
                const Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(color: Color(0xFF92400E), decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: Color(0xFF92400E), decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
