// Flutter translation of cocoa/src/app/pages/Profile.tsx
//
// Semua aksi (chat, voice, video, favorite, meet offline, payment) harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /profile/:id
// - POST /favorite
// - POST /payment
//
// Komponen reusable (PhotoGallery, MeetOfflineModal, dsb) dibuat di folder components terpisah.
//
// Untuk pengembangan backend, pastikan response sesuai kebutuhan UI.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final host = demoUserHosts.first;
  bool isFavorite = false;
  bool idVerified = false;
  bool selfieVerified = false;

  Future<void> _openPhotoGallery(int initialIndex) async {
    final pageController = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Photo gallery',
      barrierColor: Colors.black.withValues(alpha: 0.94),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: host.portfolio.length,
                      onPageChanged: (index) => setModalState(() => currentIndex = index),
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Center(
                            child: Image.network(
                              host.portfolio[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${host.portfolio.length}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    pageController.dispose();
  }

  Future<void> _showPaymentSheet(String type) async {
    final multiplier = type == 'chat' ? 1.0 : type == 'voice' ? 1.5 : 2.0;
    final hourlyRate = (host.pricePerMin * 60 * multiplier).round();
    final title = type == 'chat' ? 'Start Chat' : type == 'voice' ? 'Start Voice Call' : 'Start Video Call';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                type == 'chat' ? 'You will be charged per hour for chatting' : type == 'voice' ? 'You will be charged per hour for voice calling' : 'You will be charged per hour for video calling',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF817A74)),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFF6EA), Color(0xFFFFEBD9)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('Current Balance', style: TextStyle(color: Color(0xFF817A74))),
                    const SizedBox(height: 4),
                    const Text('🪙 1,250', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text('Rate: 🪙 $hourlyRate / hour', style: const TextStyle(fontWeight: FontWeight.w700, color: userAmberDark)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (type == 'chat') {
                      Navigator.pushNamed(context, '/chat');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title started with ${host.name}')));
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: userAmberDark, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleMeet() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Meet Offline'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request an offline meeting with ${host.name} in ${host.location}.'),
            if (!idVerified || !selfieVerified) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: userAmberDark, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo mode: verification is temporarily bypassed so you can preview this UI flow.',
                        style: TextStyle(fontSize: 12, color: userAmberDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context), style: FilledButton.styleFrom(backgroundColor: userAmberDark), child: const Text('Send Request')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.network(host.imageUrl, fit: BoxFit.cover)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45), const Color(0xFF171717)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glassButton(Icons.chevron_left_rounded, () => Navigator.pop(context)),
                      Row(
                        children: [
                          _glassButton(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, () => setState(() => isFavorite = !isFavorite), active: isFavorite),
                          const SizedBox(width: 10),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(color: const Color(0xFF2FA655), borderRadius: BorderRadius.circular(999)),
                            child: const Center(child: Icon(Icons.circle, size: 14, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 160),
                        Text('${host.name}, ${host.age}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(host.description, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: host.badges
                              .map(
                                (badge) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                                  child: Text(badge, style: const TextStyle(color: Colors.white)),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _showPaymentSheet('chat'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFCA6C34),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                            child: Text('Chat Now 🪙 ${host.pricePerMin} / Min →', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.photo_library_outlined, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text('Photos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                                  const Spacer(),
                                  Text('${host.portfolio.length} photos', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: host.portfolio.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () => _openPhotoGallery(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(host.portfolio[index], fit: BoxFit.cover),
                                      ),
                                      if (index == 0)
                                        Positioned(
                                          right: 6,
                                          bottom: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.42),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: _actionCard(Icons.call_rounded, 'Voice', 'Talk live by voice', const Color(0xFF31B56A), () => _showPaymentSheet('voice'))),
                            const SizedBox(width: 12),
                            Expanded(child: _actionCard(Icons.videocam_rounded, 'Video', 'Start face-to-face call', const Color(0xFF7A5AF8), () => _showPaymentSheet('video'))),
                            const SizedBox(width: 12),
                            Expanded(child: _actionCard(Icons.location_on_rounded, 'Meet', 'Preview offline request', const Color(0xFFCA6C34), _handleMeet, showWarning: !idVerified || !selfieVerified)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Reviews', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                                  const SizedBox(width: 8),
                                  ...List.generate(5, (index) => const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF1B62D))),
                                  const SizedBox(width: 6),
                                  Text('${host.rating} (${host.reviewCount} Reviews)', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Aditya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                        SizedBox(height: 4),
                                        Text('Clara is really sweet and easy to talk to. Always makes me smile!', style: TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text('♥ 125 Reviews', style: TextStyle(color: Color(0xFFF1B62D), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
    );
  }

  Widget _glassButton(IconData icon, VoidCallback onTap, {bool active = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(999)),
        child: Icon(icon, color: active ? const Color(0xFFE95A69) : Colors.white),
      ),
    );
  }

  Widget _actionCard(IconData icon, String label, String subtitle, Color accentColor, VoidCallback onTap, {bool showWarning = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor.withValues(alpha: 0.30), Colors.white.withValues(alpha: 0.10)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
          if (showWarning)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(color: Color(0xFFE34A57), shape: BoxShape.circle),
                child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
              ),
            ),
        ],
      ),
    );
  }
}
