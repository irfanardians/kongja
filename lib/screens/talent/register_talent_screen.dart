// Flutter translation of cocoa/src/app/pages/RegisterTalent.tsx

import 'package:flutter/material.dart';

import 'talent_ui_shared.dart';

class RegisterTalentScreen extends StatefulWidget {
  const RegisterTalentScreen({Key? key}) : super(key: key);

  @override
  State<RegisterTalentScreen> createState() => _RegisterTalentScreenState();
}

class _RegisterTalentScreenState extends State<RegisterTalentScreen> {
  bool showPassword = false;
  bool showConfirmPassword = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController stageNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController referralController = TextEditingController();

  final List<String> selectedLanguages = [];
  final List<String> selectedSpecialties = [];

  final List<String> availableLanguages = ['English', 'Spanish', 'French', 'German', 'Italian', 'Portuguese', 'Chinese', 'Japanese', 'Korean', 'Arabic'];
  final List<String> availableSpecialties = ['Casual Chat', 'Gaming', 'Music', 'Art', 'Fitness', 'Cooking', 'Travel', 'Technology', 'Fashion', 'Business'];

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    stageNameController.dispose();
    bioController.dispose();
    referralController.dispose();
    super.dispose();
  }

  void _submit() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (stageNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stage name is required')));
      return;
    }
    if (selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one language')));
      return;
    }
    Navigator.pushReplacementNamed(context, '/talent-home');
  }

  @override
  Widget build(BuildContext context) {
    final passwordsMatch = passwordController.text.isNotEmpty && passwordController.text == confirmPasswordController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [talentPurple, talentPink], begin: Alignment.centerLeft, end: Alignment.centerRight),
              ),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30)),
                  const SizedBox(width: 4),
                  const Text('Become a Talent', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
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
                          const Text('Account Credentials', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 14),
                          TextField(controller: usernameController, decoration: _inputDecoration('Username', Icons.person_outline_rounded)),
                          const SizedBox(height: 14),
                          TextField(
                            controller: passwordController,
                            obscureText: !showPassword,
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDecoration('Password', Icons.lock_outline_rounded).copyWith(
                              suffixIcon: IconButton(onPressed: () => setState(() => showPassword = !showPassword), icon: Icon(showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: !showConfirmPassword,
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDecoration('Confirm Password', Icons.lock_outline_rounded).copyWith(
                              suffixIcon: IconButton(onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword), icon: Icon(showConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(passwordsMatch ? Icons.check_circle : Icons.error_outline_rounded, size: 14, color: passwordsMatch ? const Color(0xFF2FA655) : const Color(0xFFD94B58)),
                              const SizedBox(width: 6),
                              Text(passwordsMatch ? 'Passwords match' : 'Passwords do not match', style: TextStyle(fontSize: 12, color: passwordsMatch ? const Color(0xFF2FA655) : const Color(0xFFD94B58))),
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
                              Icon(Icons.auto_awesome_rounded, color: talentPurple),
                              SizedBox(width: 8),
                              Text('Talent Profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(controller: stageNameController, decoration: _inputDecoration('Stage Name', Icons.star_rounded)),
                          const SizedBox(height: 8),
                          const Align(alignment: Alignment.centerLeft, child: Text('This is how users will see you on the platform', style: TextStyle(fontSize: 12, color: Color(0xFF8E8780)))),
                          const SizedBox(height: 14),
                          TextField(controller: bioController, maxLines: 4, decoration: _inputDecoration('Bio / Description', Icons.person_outline_rounded)),
                          const SizedBox(height: 8),
                          Align(alignment: Alignment.centerLeft, child: Text('${bioController.text.length}/500 characters', style: const TextStyle(fontSize: 12, color: Color(0xFF8E8780)))),
                          const SizedBox(height: 14),
                          TextField(controller: referralController, decoration: _inputDecoration('Referral Agency (Optional)', Icons.business_rounded)),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            items: const [
                              DropdownMenuItem(value: '1 year', child: Text('1 year')),
                              DropdownMenuItem(value: '2 years', child: Text('2 years')),
                              DropdownMenuItem(value: '3 years', child: Text('3 years')),
                              DropdownMenuItem(value: '4 years', child: Text('4 years')),
                              DropdownMenuItem(value: '5+ years', child: Text('5+ years')),
                            ],
                            onChanged: (_) {},
                            decoration: _inputDecoration('Years of Experience', Icons.work_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TalentSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Languages', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableLanguages.map((language) {
                              final active = selectedLanguages.contains(language);
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
                          const Text('Specialties', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableSpecialties.map((specialty) {
                              final active = selectedSpecialties.contains(specialty);
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
                          const Text('Identity & Media', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 14),
                          _uploadTile(Icons.badge_outlined, 'Upload Identity Card', 'Required for verification'),
                          const SizedBox(height: 12),
                          _uploadTile(Icons.camera_alt_rounded, 'Upload Selfie Verification', 'Take a selfie holding your ID'),
                          const SizedBox(height: 12),
                          _uploadTile(Icons.photo_library_outlined, 'Upload Portfolio Photos', 'Show users your best photos'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(backgroundColor: talentPurple, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE6DED6))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE6DED6))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: talentPurple)),
    );
  }

  Widget _uploadTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF8F5F1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE6DED6))),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFEDE5FF), child: Icon(icon, color: talentPurple)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF817A74))),
              ],
            ),
          ),
          OutlinedButton(onPressed: () {}, child: const Text('Upload')),
        ],
      ),
    );
  }
}
