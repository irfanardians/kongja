import 'package:flutter/material.dart';

enum ActivitySessionMode { phone, video }

class ActivitySessionScreen extends StatefulWidget {
  const ActivitySessionScreen({
    super.key,
    required this.peerName,
    required this.peerAvatar,
    required this.sessionMode,
    required this.contextLabel,
    this.statusLabel,
    this.trailingLabel,
  });

  final String peerName;
  final String peerAvatar;
  final ActivitySessionMode sessionMode;
  final String contextLabel;
  final String? statusLabel;
  final String? trailingLabel;

  @override
  State<ActivitySessionScreen> createState() => _ActivitySessionScreenState();
}

class _ActivitySessionScreenState extends State<ActivitySessionScreen> {
  bool _isMuted = false;
  bool _speakerEnabled = true;
  bool _cameraEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.sessionMode == ActivitySessionMode.video;

    return Scaffold(
      backgroundColor: const Color(0xFF171514),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          isVideo ? 'Video Call' : 'Phone Call',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.contextLabel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.trailingLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.trailingLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isVideo)
                      Container(
                        height: 340,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          image: DecorationImage(
                            image: NetworkImage(widget.peerAvatar),
                            fit: BoxFit.cover,
                            colorFilter: const ColorFilter.mode(
                              Color(0x22000000),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(18),
                        child: Container(
                          width: 104,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2725),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: const Icon(
                            Icons.videocam_rounded,
                            color: Colors.white54,
                            size: 34,
                          ),
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 76,
                        backgroundImage: NetworkImage(widget.peerAvatar),
                      ),
                    const SizedBox(height: 22),
                    Text(
                      widget.peerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25211F),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.statusLabel ?? 'Session is active',
                        style: const TextStyle(
                          color: Color(0xFFD8CBC0),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _controlButton(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    background: _isMuted
                        ? const Color(0xFFE34B57)
                        : const Color(0xFF2E2A27),
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _controlButton(
                    icon: _speakerEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    background: const Color(0xFF2E2A27),
                    onTap: () => setState(() => _speakerEnabled = !_speakerEnabled),
                  ),
                  if (isVideo)
                    _controlButton(
                      icon: _cameraEnabled
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      background: const Color(0xFF2E2A27),
                      onTap: () => setState(() => _cameraEnabled = !_cameraEnabled),
                    ),
                  _controlButton(
                    icon: Icons.call_end_rounded,
                    background: const Color(0xFFE34B57),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color background,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}