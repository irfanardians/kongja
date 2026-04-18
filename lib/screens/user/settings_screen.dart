// Flutter translation of cocoa/src/app/pages/Settings.tsx
//
// Semua aksi dan input harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - PATCH /settings
// - POST /verify
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String activeTab = 'basic';
  bool showPassword = false;
  final verificationStatus = {
    'idCard': false,
    'selfie': false,
    'phone': true,
    'email': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA96935), Color(0xFFC67334)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 4),
                  const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE9E4DE))),
              ),
              child: Row(
                children: [
                  _tabButton('basic', 'Basic Info'),
                  _tabButton('security', 'Security'),
                  _tabButton('verification', 'Verification'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (activeTab == 'basic') ...[
                      _sectionCard(
                        title: 'Personal Information',
                        children: [
                          _editableField('Call Name (Nickname)', Icons.person_outline_rounded, 'Alex', helper: 'This is how others will see your name'),
                          _editableField('Email Address', Icons.mail_outline_rounded, 'alex.johnson@email.com',
                              trailing: verificationStatus['email']! ? const Icon(Icons.check_circle, color: Color(0xFF2FA655)) : null,
                              warning: 'Changing email requires re-verification'),
                          _editableField('Phone Number', Icons.phone_outlined, '+1 (555) 123-4567',
                              trailing: verificationStatus['phone']! ? const Icon(Icons.check_circle, color: Color(0xFF2FA655)) : null,
                              warning: 'Changing phone requires re-verification'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: 'Address Information',
                        children: [
                          _editableField('Address', Icons.home_outlined, '123 Main Street, Apartment 4B', maxLines: 3),
                          _editableField('Country', Icons.public_rounded, 'United States'),
                          _editableField('City', Icons.location_city_outlined, 'New York'),
                          _editableField('Postcode / ZIP Code', Icons.pin_drop_outlined, '10001'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: 'Registration Information',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF3F1EF), borderRadius: BorderRadius.circular(999)),
                          child: const Text('Read Only', style: TextStyle(fontSize: 11, color: Color(0xFF8C867F))),
                        ),
                        children: [
                          _readonlyField('First Name', Icons.person_outline_rounded, 'Alexander'),
                          _readonlyField('Last Name', Icons.person_outline_rounded, 'Johnson'),
                          _readonlyField('Gender', Icons.groups_rounded, 'Male'),
                          _readonlyField('Date of Birth', Icons.calendar_month_outlined, 'June 15, 1995 (28 years old)'),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF5FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD8E7FF)),
                            ),
                            child: const Text(
                              'Legal Information: These fields are set during registration and cannot be changed for security and verification purposes.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF4D6C99)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _primaryButton('Save Changes', () {}),
                    ],
                    if (activeTab == 'security') ...[
                      _sectionCard(
                        title: 'Password & Security',
                        children: [
                          _passwordField('Current Password'),
                          _passwordField('New Password'),
                          _passwordField('Confirm New Password'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5E3),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF3D8A7)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Color(0xFFC89228)),
                                SizedBox(width: 8),
                                Text('Password Requirements', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF7C5A16))),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('• At least 8 characters long\n• Include uppercase and lowercase letters\n• Include at least one number\n• Include at least one special character', style: TextStyle(fontSize: 12, color: Color(0xFF8C713C))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _primaryButton('Update Password', () {}),
                    ],
                    if (activeTab == 'verification') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFF6E8), Color(0xFFFFEED8)]),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF1DFC6)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(color: userAmberDark, shape: BoxShape.circle),
                              child: const Icon(Icons.verified_user_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Account Verification', style: TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(
                                    verificationStatus['idCard']! && verificationStatus['selfie']! ? 'Fully Verified' : 'Verification Required',
                                    style: TextStyle(
                                      color: verificationStatus['idCard']! && verificationStatus['selfie']! ? const Color(0xFF2FA655) : userAmberDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _verificationCard(
                        title: 'ID Card Verification',
                        subtitle: 'Upload a photo of your government-issued ID.',
                        icon: Icons.credit_card_rounded,
                        color: const Color(0xFF3B82F6),
                        verified: verificationStatus['idCard']!,
                        onPressed: () => setState(() => verificationStatus['idCard'] = true),
                        buttonLabel: 'Upload ID Card',
                      ),
                      const SizedBox(height: 16),
                      _verificationCard(
                        title: 'Selfie Verification',
                        subtitle: 'Take a selfie holding your ID next to your face.',
                        icon: Icons.camera_alt_rounded,
                        color: const Color(0xFF8B5CF6),
                        verified: verificationStatus['selfie']!,
                        onPressed: () => setState(() => verificationStatus['selfie'] = true),
                        buttonLabel: 'Upload Selfie',
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: 'Contact Verification',
                        children: [
                          _contactVerificationTile('Email Verification', 'alex.johnson@email.com', Icons.mail_outline_rounded, verificationStatus['email']!),
                          _contactVerificationTile('Phone Verification', '+1 (555) 123-4567', Icons.phone_outlined, verificationStatus['phone']!),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF5FF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFD8E7FF)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_rounded, color: Color(0xFF3B82F6)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your privacy is protected. All verification documents are encrypted and securely stored.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF4C6A97)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String value, String label) {
    final isActive = activeTab == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => activeTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isActive ? userAmberDark : Colors.transparent, width: 2)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? userAmberDark : const Color(0xFF8F8881),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E4DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _editableField(String label, IconData icon, String initialValue, {Widget? trailing, String? helper, String? warning, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF8A847E))),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5DED5)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                  child: Icon(icon, color: const Color(0xFFAAA39C)),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: initialValue,
                    maxLines: maxLines,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                if (trailing != null) Padding(padding: const EdgeInsets.only(right: 12), child: trailing),
              ],
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(helper, style: const TextStyle(fontSize: 12, color: Color(0xFFAAA39C))),
          ],
          if (warning != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: userAmberDark),
                const SizedBox(width: 4),
                Text(warning, style: const TextStyle(fontSize: 12, color: userAmberDark)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _readonlyField(String label, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF8A847E))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4F1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DED5)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFAAA39C)),
                const SizedBox(width: 10),
                Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF5A544F)))),
                const Icon(Icons.lock_rounded, size: 18, color: Color(0xFFAAA39C)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF8A847E))),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5DED5)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 14, 10, 14),
                  child: Icon(Icons.lock_outline_rounded, color: Color(0xFFAAA39C)),
                ),
                Expanded(
                  child: TextField(
                    obscureText: !showPassword,
                    decoration: InputDecoration(border: InputBorder.none, hintText: 'Enter $label'),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => showPassword = !showPassword),
                  icon: Icon(showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFFAAA39C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool verified,
    required VoidCallback onPressed,
    required String buttonLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E4DE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
                    if (verified) const Icon(Icons.check_circle, color: Color(0xFF2FA655)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF837C76))),
                const SizedBox(height: 12),
                if (!verified)
                  OutlinedButton.icon(
                    onPressed: onPressed,
                    icon: Icon(icon, color: const Color(0xFF78726B)),
                    label: Text(buttonLabel, style: const TextStyle(color: Color(0xFF5E5853))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDAD3CB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8EF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCBEED6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 18, color: Color(0xFF2FA655)),
                        SizedBox(width: 6),
                        Text('Verified', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2FA655))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactVerificationTile(String title, String subtitle, IconData icon, bool verified) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF7F4F1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFAAA39C)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF8D8781))),
              ],
            ),
          ),
          verified
              ? const Icon(Icons.check_circle, color: Color(0xFF2FA655))
              : TextButton(onPressed: () {}, child: const Text('Verify', style: TextStyle(color: userAmberDark))),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: userAmberDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(label),
      ),
    );
  }
}
