import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/services/telephone_session_service.dart';

class TelephoneSessionScreen extends StatefulWidget {
  const TelephoneSessionScreen({
    super.key,
    required this.roomId,
    required this.fallbackPeerName,
    required this.fallbackPeerAvatar,
  });

  final String roomId;
  final String fallbackPeerName;
  final String fallbackPeerAvatar;

  @override
  State<TelephoneSessionScreen> createState() => _TelephoneSessionScreenState();
}

class _TelephoneSessionScreenState extends State<TelephoneSessionScreen> {
  TelephoneSessionDetail? _session;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';
  String _callBanner = '';
  Timer? _ticker;
  StreamSubscription<TelephoneCallEvent>? _callEventSubscription;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    _callEventSubscription = TelephoneSessionService.realtime.eventStream.listen(
      _handleCallEvent,
    );
    unawaited(
      TelephoneSessionService.realtime.ensureRoomSubscription(widget.roomId),
    );
    unawaited(_loadSession(forceRefresh: true));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _callEventSubscription?.cancel();
    super.dispose();
  }

  void _handleCallEvent(TelephoneCallEvent event) {
    if (event.roomId.isNotEmpty && event.roomId != widget.roomId) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _callBanner = switch (event.event) {
        'call_ringing' => 'Memanggil...',
        'call_accepted' => 'Telepon diangkat',
        'call_rejected' => 'Panggilan ditolak',
        'call_ended' => 'Panggilan selesai',
        'call_auto_ended' => 'Panggilan berakhir otomatis',
        'call_transaction_completed' => 'Sesi selesai permanen',
        'connect_error' => 'Koneksi realtime telephone gagal',
        _ => '',
      };
    });

    unawaited(_loadSession(forceRefresh: true));
  }

  Future<void> _loadSession({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final session = await TelephoneSessionService.getSessionDetail(
        widget.roomId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _session = session;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _runAction(
    Future<TelephoneSessionDetail> Function(String roomId) action,
  ) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final session = await action(widget.roomId);
      if (!mounted) {
        return;
      }
      setState(() {
        _session = session;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final peerName = session?.counterpartName.trim().isNotEmpty == true
        ? session!.counterpartName
        : widget.fallbackPeerName;
    final peerAvatar = session?.counterpartAvatarUrl.trim().isNotEmpty == true
        ? session!.counterpartAvatarUrl
        : widget.fallbackPeerAvatar;

    return Scaffold(
      backgroundColor: const Color(0xFF171514),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Telephone Session'),
        actions: [
          IconButton(
            onPressed: _isLoading || _isSubmitting
                ? null
                : () => _loadSession(forceRefresh: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading && session == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PeerCard(name: peerName, avatarUrl: peerAvatar),
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Status sesi',
                      value: _statusLabel(session),
                      subtitle: _statusHint(session),
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Sisa kuota',
                      value: _formatDuration(
                        session?.remainingDurationSeconds ?? 0,
                      ),
                      subtitle: 'Total alokasi ${_formatDuration(session?.allocatedDurationSeconds ?? 0)}',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Berlaku sampai',
                      value: _formatDateTime(session?.validUntil),
                      subtitle: _validityHint(session),
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Countdown call aktif',
                      value: _ongoingDeadlineLabel(session),
                      subtitle: 'Countdown ini hanya berjalan saat call sudah ongoing.',
                    ),
                    if (_callBanner.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2725),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _callBanner,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Color(0xFFFF9B9B)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (session != null) ..._buildActionButtons(session),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildActionButtons(TelephoneSessionDetail session) {
    final widgets = <Widget>[];
    final role = AuthSession.instance.role?.trim().toLowerCase() ?? 'user';

    if (role == 'talent' && session.status.trim().toLowerCase() == 'pending') {
      widgets.add(
        FilledButton(
          onPressed: _isSubmitting
              ? null
              : () => _runAction(TelephoneSessionService.confirmRequest),
          child: const Text('Confirm Request'),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    if (session.canRing) {
      widgets.add(
        FilledButton(
          onPressed: _isSubmitting
              ? null
              : () => _runAction(TelephoneSessionService.ring),
          child: const Text('Call'),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    if (session.canAccept) {
      widgets.add(
        FilledButton(
          onPressed: _isSubmitting
              ? null
              : () => _runAction(TelephoneSessionService.accept),
          child: const Text('Accept'),
        ),
      );
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        OutlinedButton(
          onPressed: _isSubmitting
              ? null
              : () => _runAction(TelephoneSessionService.reject),
          child: const Text('Reject'),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    if (session.canEnd) {
      widgets.add(
        OutlinedButton(
          onPressed: _isSubmitting
              ? null
              : () => _runAction(TelephoneSessionService.endCall),
          child: const Text('End Call'),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    if (session.canEndTransaction) {
      widgets.add(
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE34B57),
          ),
          onPressed: _isSubmitting
              ? null
              : () => _runAction(TelephoneSessionService.endTransaction),
          child: const Text('End Transaction'),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    if (widgets.isEmpty) {
      widgets.add(
        const Text(
          'Tidak ada aksi telephone yang tersedia saat ini. State dan permission mengikuti backend.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return widgets;
  }

  String _statusLabel(TelephoneSessionDetail? session) {
    if (session == null) {
      return 'Memuat...';
    }

    final status = session.status.trim().toLowerCase();
    final callStatus = session.callStatus.trim().toLowerCase();
    final remaining = session.remainingDurationSeconds;
    final now = DateTime.now();
    final isExpired = session.validUntil != null && now.isAfter(session.validUntil!);

    if (status == 'completed' || session.closedReason == 'manual_end_transaction') {
      return 'Sesi selesai permanen';
    }
    if (session.closedReason == 'expired' || isExpired) {
      return 'Sesi hangus';
    }
    if (remaining <= 0) {
      return 'Kuota telepon habis';
    }
    if (status == 'pending') {
      return 'Menunggu konfirmasi talent';
    }
    if (callStatus == 'ringing') {
      return 'Memanggil...';
    }
    if (callStatus == 'ongoing') {
      return 'Telepon aktif';
    }
    if (callStatus == 'ended') {
      return 'Panggilan selesai, masih bisa dipakai lagi';
    }
    return 'Siap ditelepon';
  }

  String _statusHint(TelephoneSessionDetail? session) {
    if (session == null) {
      return '';
    }
    if (session.closedReason.trim().isNotEmpty) {
      return 'Alasan backend: ${session.closedReason}';
    }
    return 'Room ID: ${session.roomId}';
  }

  String _validityHint(TelephoneSessionDetail? session) {
    if (session?.validUntil == null) {
      return 'Masa berlaku 24 jam akan dibaca dari backend.';
    }

    final now = DateTime.now();
    if (now.isAfter(session!.validUntil!)) {
      return 'Sesi sudah melewati batas 24 jam.';
    }
    return 'Sisa masa berlaku: ${_formatDuration(session.validUntil!.difference(now).inSeconds)}';
  }

  String _ongoingDeadlineLabel(TelephoneSessionDetail? session) {
    if (session?.deadlineAt == null) {
      return 'Belum berjalan';
    }

    final now = DateTime.now();
    final seconds = session!.deadlineAt!.difference(now).inSeconds;
    if (seconds <= 0) {
      return '00:00:00';
    }
    return _formatDuration(seconds);
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) {
      return '00:00:00';
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '-';
    }
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} ${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }
}

class _PeerCard extends StatelessWidget {
  const _PeerCard({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF25211F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: const Color(0xFF3A3430),
            backgroundImage: avatarUrl.trim().isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl.trim().isEmpty
                ? const Icon(Icons.call_rounded, color: Colors.white, size: 28)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF25211F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.white54)),
          ],
        ],
      ),
    );
  }
}