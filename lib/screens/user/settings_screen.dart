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

import '../../core/services/auth_service.dart';
import '../../core/services/user_profile_service.dart';
import '../shared/loading_splash.dart';
import 'user_ui_shared.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String activeTab = 'basic';
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  UserProfileData? _profile;
  bool _isLoadingProfile = false;
  late final TextEditingController _callNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneCountryCodeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _postcodeController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  final verificationStatus = {
    'idCard': false,
    'selfie': false,
    'phone': true,
    'email': true,
  };

  @override
  void initState() {
    super.initState();
    _callNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneCountryCodeController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
    _postcodeController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    final cachedProfile = UserProfileService.peekCachedMyProfile();
    if (cachedProfile != null) {
      _applyProfile(cachedProfile);
    }

    _loadProfile(forceRefresh: cachedProfile != null);
  }

  @override
  void dispose() {
    _callNameController.dispose();
    _emailController.dispose();
    _phoneCountryCodeController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postcodeController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _applyProfile(UserProfileData profile) {
    _profile = profile;
    _callNameController.text = profile.callName;
    _emailController.text = profile.email;
    _phoneCountryCodeController.text = profile.phoneCountryCode;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address;
    _cityController.text = profile.city;
    _countryController.text = profile.country;
    _postcodeController.text = profile.postcode;
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    if (_isLoadingProfile) {
      return;
    }

    setState(() => _isLoadingProfile = true);
    try {
      final profile = await UserProfileService.getMyProfile(
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _applyProfile(profile);
      });
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pengaturan user: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _saveBasicSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Perubahan'),
          content: const Text(
            'Apakah anda yakin ingin mengubah settingan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final profile = await AppLoadingOverlay.of(context).run<UserProfileData>(
        () async {
          return UserProfileService.updateBasicSettings(
            callName: _callNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneCountryCode: _phoneCountryCodeController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            country: _countryController.text.trim(),
            postcode: _postcodeController.text.trim(),
          );
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _applyProfile(profile);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan user berhasil disimpan.')),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengaturan user: $error')),
      );
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field password harus diisi.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password baru tidak cocok.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Perubahan'),
          content: const Text('Apakah anda yakin ingin mengubah password ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Oke'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await AppLoadingOverlay.of(context).run<void>(() async {
        await UserProfileService.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );
      });

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password user berhasil diperbarui.')),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah password user: $error')),
      );
    }
  }

  String _displayValue(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty ? trimmed : '-';
  }

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
                          if (_isLoadingProfile && _profile == null)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 14),
                              child: LinearProgressIndicator(minHeight: 3),
                            ),
                          _editableField('Call Name (Nickname)', Icons.person_outline_rounded,
                              controller: _callNameController,
                              helper: 'This is how others will see your name'),
                          _editableField('Email Address', Icons.mail_outline_rounded,
                              controller: _emailController,
                              trailing: verificationStatus['email']! ? const Icon(Icons.check_circle, color: Color(0xFF2FA655)) : null,
                              warning: 'Changing email requires re-verification'),
                          _editableField('Phone Country Code', Icons.flag_outlined,
                              controller: _phoneCountryCodeController,
                              helper: 'Example: +62'),
                          _editableField('Phone Number', Icons.phone_outlined,
                              controller: _phoneController,
                              trailing: verificationStatus['phone']! ? const Icon(Icons.check_circle, color: Color(0xFF2FA655)) : null,
                              warning: 'Changing phone requires re-verification'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: 'Address Information',
                        children: [
                          _editableField('Address', Icons.home_outlined,
                              controller: _addressController, maxLines: 3),
                          _editableField('Country', Icons.public_rounded,
                              controller: _countryController),
                          _editableField('City', Icons.location_city_outlined,
                              controller: _cityController),
                          _editableField('Postcode / ZIP Code', Icons.pin_drop_outlined,
                              controller: _postcodeController),
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
                          _readonlyField('First Name', Icons.person_outline_rounded, _displayValue(_profile?.firstName ?? '')),
                          _readonlyField('Last Name', Icons.person_outline_rounded, _displayValue(_profile?.lastName ?? '')),
                          _readonlyField('Gender', Icons.groups_rounded, _displayValue(_profile?.gender ?? '')),
                          _readonlyField('Date of Birth', Icons.calendar_month_outlined, _displayValue(_profile?.dateOfBirth ?? '')),
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
                      _primaryButton('Save Changes', _saveBasicSettings),
                    ],
                    if (activeTab == 'security') ...[
                      _sectionCard(
                        title: 'Password & Security',
                        children: [
                          _passwordField(
                            'Current Password',
                            controller: _currentPasswordController,
                            visible: showCurrentPassword,
                            onToggle: () => setState(
                              () => showCurrentPassword = !showCurrentPassword,
                            ),
                          ),
                          _passwordField(
                            'New Password',
                            controller: _newPasswordController,
                            visible: showNewPassword,
                            onToggle: () => setState(
                              () => showNewPassword = !showNewPassword,
                            ),
                          ),
                          _passwordField(
                            'Confirm New Password',
                            controller: _confirmPasswordController,
                            visible: showConfirmPassword,
                            onToggle: () => setState(
                              () =>
                                  showConfirmPassword = !showConfirmPassword,
                            ),
                          ),
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
                      _primaryButton('Update Password', _changePassword),
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
                          _contactVerificationTile('Email Verification', _displayValue(_emailController.text), Icons.mail_outline_rounded, verificationStatus['email']!),
                          _contactVerificationTile('Phone Verification',
                              '${_displayValue(_phoneCountryCodeController.text)} ${_displayValue(_phoneController.text)}'.trim(), Icons.phone_outlined, verificationStatus['phone']!),
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

  Widget _editableField(String label, IconData icon,
      {required TextEditingController controller,
      Widget? trailing,
      String? helper,
      String? warning,
      int maxLines = 1}) {
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
                    controller: controller,
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

  Widget _passwordField(
    String label, {
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
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
                    controller: controller,
                    obscureText: !visible,
                    decoration: InputDecoration(border: InputBorder.none, hintText: 'Enter $label'),
                  ),
                ),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(visible ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFFAAA39C)),
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
