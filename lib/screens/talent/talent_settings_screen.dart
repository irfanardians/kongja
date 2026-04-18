// Flutter translation of cocoa/src/app/pages/TalentSettings.tsx

import 'package:flutter/material.dart';

import 'talent_ui_shared.dart';

class TalentSettingsScreen extends StatefulWidget {
  const TalentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<TalentSettingsScreen> createState() => _TalentSettingsScreenState();
}

class _TalentSettingsScreenState extends State<TalentSettingsScreen> {
  String activeTab = 'basic';
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  late final TextEditingController _referralCodeController;
  late bool _isReferralCodeLocked;

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
  final List<String> selectedLanguages = ['English', 'Spanish', 'French'];
  final List<String> selectedSpecialties = ['Casual Chat', 'Gaming', 'Music'];

  @override
  void initState() {
    super.initState();
    _referralCodeController = TextEditingController(text: 'TalentHub Agency');
    _isReferralCodeLocked = _referralCodeController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacementNamed('/talent-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: talentBg,
      bottomNavigationBar: const TalentBottomNav(
        currentRoute: '/talent-settings',
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBack();
          }
        },
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [talentAmberDark, talentAmber],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _handleBack,
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Talent Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        _topTab('basic', 'Basic'),
                        _topTab('talent', 'Talent'),
                        _topTab('security', 'Security'),
                        _topTab('verification', 'Verify'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        children: [
                          if (activeTab == 'basic') ...[
                            TalentSectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 14),
                                  TalentField(
                                    label: 'Call Name (Nickname)',
                                    icon: Icons.person_outline_rounded,
                                    initialValue: 'Jess',
                                    helper: 'This is your personal nickname',
                                  ),
                                  TalentField(
                                    label: 'Email Address',
                                    icon: Icons.mail_outline_rounded,
                                    initialValue: 'jessica.martinez@email.com',
                                    helper:
                                        'Changing email requires re-verification',
                                    trailing: Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2FA655),
                                    ),
                                  ),
                                  TalentField(
                                    label: 'Phone Number',
                                    icon: Icons.phone_outlined,
                                    initialValue: '+1 (555) 987-6543',
                                    helper:
                                        'Changing phone requires re-verification',
                                    trailing: Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2FA655),
                                    ),
                                  ),
                                  TalentField(
                                    label: 'Address',
                                    icon: Icons.home_outlined,
                                    initialValue: '456 Oak Avenue, Suite 12',
                                    maxLines: 3,
                                  ),
                                  TalentField(
                                    label: 'Country',
                                    icon: Icons.public_rounded,
                                    initialValue: 'Mexico',
                                  ),
                                  TalentField(
                                    label: 'City',
                                    icon: Icons.location_on_outlined,
                                    initialValue: 'Mexico City',
                                  ),
                                  TalentField(
                                    label: 'Postcode / ZIP Code',
                                    icon: Icons.pin_drop_outlined,
                                    initialValue: '03100',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TalentSectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Registration Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 14),
                                  TalentField(
                                    label: 'First Name',
                                    icon: Icons.person_outline_rounded,
                                    initialValue: 'Jessica',
                                    enabled: false,
                                  ),
                                  TalentField(
                                    label: 'Last Name',
                                    icon: Icons.person_outline_rounded,
                                    initialValue: 'Martinez',
                                    enabled: false,
                                  ),
                                  TalentField(
                                    label: 'Gender',
                                    icon: Icons.groups_rounded,
                                    initialValue: 'Female',
                                    enabled: false,
                                  ),
                                  TalentField(
                                    label: 'Date of Birth',
                                    icon: Icons.calendar_month_outlined,
                                    initialValue: 'Mar 22, 1996',
                                    enabled: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (activeTab == 'talent') ...[
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
                                  const TalentField(
                                    label: 'Stage Name',
                                    icon: Icons.star_rounded,
                                    initialValue: 'Jessica Martinez',
                                    helper:
                                        'This is how users will see you on the platform',
                                  ),
                                  const TalentField(
                                    label: 'Bio / Description',
                                    icon: Icons.person_outline_rounded,
                                    initialValue:
                                        'Hey! I\'m Jessica, a friendly companion who loves deep conversations, gaming, and helping people feel heard.',
                                    maxLines: 4,
                                    helper: '250/500 characters',
                                  ),
                                  TalentField(
                                    label: 'Referral Agency Code',
                                    icon: Icons.business_rounded,
                                    initialValue: '',
                                    controller: _referralCodeController,
                                    enabled: !_isReferralCodeLocked,
                                    helper: _isReferralCodeLocked
                                        ? 'This referral code has already been assigned and cannot be changed.'
                                        : 'If this field is empty, you can enter a talent referral code once.',
                                    trailing: _isReferralCodeLocked
                                        ? const Icon(
                                            Icons.lock_rounded,
                                            color: Color(0xFFA59D96),
                                          )
                                        : const Icon(
                                            Icons.edit_rounded,
                                            color: talentPurple,
                                          ),
                                  ),
                                  const TalentField(
                                    label: 'Years of Experience',
                                    icon: Icons.work_outline_rounded,
                                    initialValue: '4 years',
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Languages',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: availableLanguages.map((
                                      language,
                                    ) {
                                      final active = selectedLanguages.contains(
                                        language,
                                      );
                                      return FilterChip(
                                        label: Text(language),
                                        selected: active,
                                        onSelected: (_) {
                                          setState(() {
                                            if (active) {
                                              selectedLanguages.remove(
                                                language,
                                              );
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
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: availableSpecialties.map((
                                      specialty,
                                    ) {
                                      final active = selectedSpecialties
                                          .contains(specialty);
                                      return FilterChip(
                                        label: Text(specialty),
                                        selected: active,
                                        onSelected: (_) {
                                          setState(() {
                                            if (active) {
                                              selectedSpecialties.remove(
                                                specialty,
                                              );
                                            } else {
                                              selectedSpecialties.add(
                                                specialty,
                                              );
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
                          ],
                          if (activeTab == 'security') ...[
                            TalentSectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Password & Security',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _passwordField(
                                    'Current Password',
                                    showCurrentPassword,
                                    () => setState(
                                      () => showCurrentPassword =
                                          !showCurrentPassword,
                                    ),
                                  ),
                                  _passwordField(
                                    'New Password',
                                    showNewPassword,
                                    () => setState(
                                      () => showNewPassword = !showNewPassword,
                                    ),
                                  ),
                                  _passwordField(
                                    'Confirm New Password',
                                    showConfirmPassword,
                                    () => setState(
                                      () => showConfirmPassword =
                                          !showConfirmPassword,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5E3),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFF3D8A7),
                                ),
                              ),
                              child: const Text(
                                'Password Requirements\n\n• At least 8 characters\n• Include uppercase and lowercase letters\n• Include at least one number\n• Include at least one special character',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF805F20),
                                ),
                              ),
                            ),
                          ],
                          if (activeTab == 'verification') ...[
                            TalentSectionCard(
                              child: Column(
                                children: [
                                  Row(
                                    children: const [
                                      CircleAvatar(
                                        backgroundColor: talentAmberDark,
                                        child: Icon(
                                          Icons.verified_user_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Account Verification',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Fully Verified',
                                              style: TextStyle(
                                                color: Color(0xFF2FA655),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _verifyTile(
                                    'ID Card Verification',
                                    'Your government-issued ID is verified.',
                                    Icons.credit_card_rounded,
                                    const Color(0xFF3B82F6),
                                  ),
                                  const SizedBox(height: 12),
                                  _verifyTile(
                                    'Selfie Verification',
                                    'Your selfie verification has been approved.',
                                    Icons.camera_alt_rounded,
                                    talentPurple,
                                  ),
                                  const SizedBox(height: 12),
                                  _verifyTile(
                                    'Email Verification',
                                    'jessica.martinez@email.com',
                                    Icons.mail_outline_rounded,
                                    const Color(0xFF2FA655),
                                  ),
                                  const SizedBox(height: 12),
                                  _verifyTile(
                                    'Phone Verification',
                                    '+1 (555) 987-6543',
                                    Icons.phone_outlined,
                                    const Color(0xFF2FA655),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                if (activeTab == 'talent' &&
                                    !_isReferralCodeLocked &&
                                    _referralCodeController.text
                                        .trim()
                                        .isNotEmpty) {
                                  setState(() {
                                    _isReferralCodeLocked = true;
                                  });
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      activeTab == 'security'
                                          ? 'Password updated successfully.'
                                          : 'Changes saved successfully.',
                                    ),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: talentAmberDark,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                activeTab == 'security'
                                    ? 'Update Password'
                                    : 'Save Changes',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topTab(String value, String label) {
    final active = activeTab == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => activeTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? talentAmberDark : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? talentAmberDark : const Color(0xFF8E8780),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField(String label, bool visible, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7F7770)),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6DED6)),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 14, 10, 14),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFFA59D96),
                  ),
                ),
                Expanded(
                  child: TextField(
                    obscureText: !visible,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter $label',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    visible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFFA59D96),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifyTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
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
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF2FA655)),
        ],
      ),
    );
  }
}
