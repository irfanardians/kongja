import 'dart:async';
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../auth/auth_session.dart';
import '../config/api_config.dart';
import 'api_client.dart';
import 'auth_service.dart';

class TelephoneSessionService {
  TelephoneSessionService._();

  static const Duration _sessionCacheMaxAge = Duration(minutes: 1);
  static final TelephoneCallRealtimeClient realtime =
      TelephoneCallRealtimeClient.instance;

  static Future<TelephoneSessionDetail> createOrReuseSession({
    required String talentAccountId,
  }) async {
    final trimmedTalentAccountId = talentAccountId.trim();
    if (trimmedTalentAccountId.isEmpty) {
      throw const AuthServiceException('ID talent tidak ditemukan.');
    }

    final existingSession = await _findReusableSession(
      talentAccountId: trimmedTalentAccountId,
    );
    if (existingSession != null) {
      return existingSession;
    }

    final response = await ApiClient.postJson(
      '/meet-requests',
      body: {
        'talent_account_id': trimmedTalentAccountId,
        'channel_type': 'telephone',
        'duration_minutes': 60,
      },
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(
          response.body,
          fallback: 'Gagal membuat sesi telephone.',
        ),
      );
    }

    invalidateCache();

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    final roomId = _resolveCreatedRoomId(decoded);
    if (roomId.isNotEmpty) {
      return getSessionDetail(roomId, forceRefresh: true);
    }

    final createdSession = await _findCreatedSession(
      talentAccountId: trimmedTalentAccountId,
    );
    if (createdSession != null) {
      return createdSession;
    }

    if (roomId.isEmpty) {
      throw const AuthServiceException(
        'Sesi telephone berhasil dibuat tetapi room ID tidak ditemukan.',
      );
    }

    return getSessionDetail(roomId, forceRefresh: true);
  }

  static Future<List<TelephoneSessionListItem>> getSessions({
    bool forceRefresh = false,
  }) async {
    final decoded = await ApiClient.getJson(
      '/call-sessions',
      useCache: true,
      forceRefresh: forceRefresh,
      maxAge: _sessionCacheMaxAge,
    );

    final candidates = <dynamic>[];
    if (decoded is Map<String, dynamic>) {
      candidates.addAll([decoded['data'], decoded['items'], decoded['results']]);
    } else {
      candidates.add(decoded);
    }

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .map(_parseSessionListItem)
            .whereType<TelephoneSessionListItem>()
            .toList(growable: false);
      }
    }

    final singleItem = _parseSessionListItem(decoded);
    if (singleItem != null) {
      return [singleItem];
    }

    return const [];
  }

  static Future<TelephoneSessionDetail> getSessionDetail(
    String roomId, {
    bool forceRefresh = false,
  }) async {
    final trimmedRoomId = roomId.trim();
    if (trimmedRoomId.isEmpty) {
      throw const AuthServiceException('Room ID sesi telephone tidak valid.');
    }

    final decoded = await ApiClient.getJson(
      '/sessions/$trimmedRoomId',
      useCache: true,
      forceRefresh: forceRefresh,
      maxAge: const Duration(seconds: 10),
    );

    final parsed = _parseSessionDetail(decoded);
    if (parsed != null) {
      return parsed;
    }

    throw const AuthServiceException(
      'Detail sesi telephone tidak ditemukan atau tidak bisa dibaca.',
    );
  }

  static Future<TelephoneSessionDetail> ring(String roomId) async {
    return _postAction(roomId, '/call/$roomId/ring');
  }

  static Future<TelephoneSessionDetail> accept(String roomId) async {
    return _postAction(roomId, '/call/$roomId/accept');
  }

  static Future<TelephoneSessionDetail> confirmRequest(String roomId) async {
    final trimmedRoomId = roomId.trim();
    final response = await ApiClient.patchJson(
      '/talent/meet-requests/$trimmedRoomId/confirm',
      body: const {'duration_minutes': 60},
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(
          response.body,
          fallback: 'Gagal mengonfirmasi sesi telephone.',
        ),
      );
    }

    invalidateCache(trimmedRoomId);
    return getSessionDetail(trimmedRoomId, forceRefresh: true);
  }

  static Future<TelephoneSessionDetail> reject(String roomId) async {
    return _postAction(roomId, '/call/$roomId/reject');
  }

  static Future<TelephoneSessionDetail> endCall(String roomId) async {
    return _postAction(roomId, '/call/$roomId/end');
  }

  static Future<TelephoneSessionDetail> endTransaction(String roomId) async {
    return _postAction(roomId, '/call/$roomId/end-transaction');
  }

  static void invalidateCache([String? roomId]) {
    ApiClient.invalidateCache('/call-sessions');
    final trimmedRoomId = roomId?.trim() ?? '';
    if (trimmedRoomId.isNotEmpty) {
      ApiClient.invalidateCache('/sessions/$trimmedRoomId');
    }
  }

  static Future<TelephoneSessionDetail?> _findReusableSession({
    required String talentAccountId,
  }) async {
    final sessions = await getSessions(forceRefresh: true);
    for (final session in sessions) {
      if (session.counterpartAccountId != talentAccountId) {
        continue;
      }

      if (session.status == 'completed' ||
          session.status == 'cancelled' ||
          session.status == 'rejected') {
        continue;
      }

      return getSessionDetail(session.roomId, forceRefresh: true);
    }

    return null;
  }

  static Future<TelephoneSessionDetail?> _findCreatedSession({
    required String talentAccountId,
  }) async {
    final sessions = await getSessions(forceRefresh: true);
    final matchingSessions = sessions.where(
      (session) => session.counterpartAccountId == talentAccountId,
    );

    TelephoneSessionListItem? latestSession;
    for (final session in matchingSessions) {
      if (latestSession == null) {
        latestSession = session;
        continue;
      }

      final candidateUpdatedAt = session.updatedAt;
      final currentUpdatedAt = latestSession.updatedAt;
      if (candidateUpdatedAt != null && currentUpdatedAt != null) {
        if (candidateUpdatedAt.isAfter(currentUpdatedAt)) {
          latestSession = session;
        }
        continue;
      }

      if (candidateUpdatedAt != null && currentUpdatedAt == null) {
        latestSession = session;
      }
    }

    if (latestSession == null) {
      return null;
    }

    return getSessionDetail(latestSession.roomId, forceRefresh: true);
  }

  static Future<TelephoneSessionDetail> _postAction(
    String roomId,
    String path,
  ) async {
    final trimmedRoomId = roomId.trim();
    final response = await ApiClient.postJson(
      path,
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(response.body, fallback: 'Aksi sesi telephone gagal.'),
      );
    }

    invalidateCache(trimmedRoomId);
    return getSessionDetail(trimmedRoomId, forceRefresh: true);
  }

  static TelephoneSessionListItem? _parseSessionListItem(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final roomId = _extractRoomId(value);
    if (roomId.isEmpty) {
      return null;
    }

    final participant = _resolveCounterpart(value);
    final channelType = _normalizeChannelType(_firstNonEmpty([
      value['channel_type'],
      value['type'],
    ]));
    if (channelType != 'telephone') {
      return null;
    }

    return TelephoneSessionListItem(
      roomId: roomId,
      counterpartName: participant.name,
      counterpartAvatarUrl: participant.avatarUrl,
      counterpartAccountId: participant.accountId,
      counterpartCountryCode: participant.countryCode,
      status: _firstNonEmpty([value['status']], fallback: 'pending'),
      callStatus: _firstNonEmpty([
        _nestedMap(value, 'call_session')['status'],
      ], fallback: 'idle'),
      remainingDurationSeconds: _intValue(
        _nestedMap(value, 'call_session')['remaining_duration_seconds'],
      ),
      validUntil: _dateTimeFromAny(
        _nestedMap(value, 'call_session')['valid_until'],
      ),
      closedReason: _firstNonEmpty([
        _nestedMap(value, 'call_session')['closed_reason'],
      ]),
      updatedAt: _dateTimeFromAny(
        _firstNonEmpty([
          value['updated_at'],
          value['created_at'],
        ]),
      ),
    );
  }

  static TelephoneSessionDetail? _parseSessionDetail(dynamic value) {
    if (value is Map<String, dynamic>) {
      final roomId = _extractRoomId(value);
      if (roomId.isEmpty) {
        final nested = value['data'];
        if (nested != null && nested != value) {
          return _parseSessionDetail(nested);
        }
        return null;
      }

      final participant = _resolveCounterpart(value);
      final callSession = _nestedMap(value, 'call_session');
      final permissions = _nestedMap(value, 'permissions');
      final channelType = _normalizeChannelType(_firstNonEmpty([
        value['channel_type'],
        value['type'],
      ]));
      if (channelType != 'telephone') {
        return null;
      }

      return TelephoneSessionDetail(
        roomId: roomId,
        counterpartName: participant.name,
        counterpartAvatarUrl: participant.avatarUrl,
        counterpartAccountId: participant.accountId,
        status: _firstNonEmpty([value['status']], fallback: 'pending'),
        callStatus: _firstNonEmpty([
          callSession['status'],
        ], fallback: 'idle'),
        allocatedDurationSeconds: _intValue(
          callSession['allocated_duration_seconds'],
        ),
        remainingDurationSeconds: _intValue(
          callSession['remaining_duration_seconds'],
        ),
        validUntil: _dateTimeFromAny(callSession['valid_until']),
        deadlineAt: _dateTimeFromAny(callSession['deadline_at']),
        closedReason: _firstNonEmpty([callSession['closed_reason']]),
        canRing: _boolValue(permissions['can_ring']),
        canAccept: _boolValue(permissions['can_accept']),
        canEnd: _boolValue(permissions['can_end']),
        canEndTransaction: _boolValue(permissions['can_end_transaction']),
      );
    }

    return null;
  }

  static _TelephoneParticipant _resolveCounterpart(Map<String, dynamic> value) {
    final role = AuthSession.instance.role?.trim().toLowerCase() ?? 'user';
    final roleSpecific = role == 'talent'
        ? _participantFromAny(value['user'])
        : _participantFromAny(value['talent']);
    if (roleSpecific.accountId.isNotEmpty || roleSpecific.name.isNotEmpty) {
      return roleSpecific;
    }

    return _participantFromAny(value['counterpart'])
        .merge(_participantFromAny(value['participant']))
        .merge(
          _participantFromAny({
            'name': role == 'talent'
                ? _firstNonEmpty([
                    value['user_name'],
                    value['customer_name'],
                  ])
                : _firstNonEmpty([
                    value['talent_name'],
                    value['talent_stage_name'],
                  ]),
            'avatar_url': role == 'talent'
                ? _firstNonEmpty([
                    value['user_avatar_url'],
                    value['customer_avatar_url'],
                  ])
                : _firstNonEmpty([
                    value['talent_avatar_url'],
                    value['avatar_url'],
                  ]),
            'account_id': role == 'talent'
                ? _firstNonEmpty([
                    value['user_account_id'],
                    value['customer_account_id'],
                  ])
                : _firstNonEmpty([
                    value['talent_account_id'],
                    value['account_id'],
                  ]),
            'country_code': role == 'talent'
                ? _firstNonEmpty([
                    value['user_country_code'],
                    value['customer_country_code'],
                  ], fallback: 'US')
                : _firstNonEmpty([
                    value['talent_country_code'],
                  ], fallback: 'US'),
          }),
        );
  }

  static _TelephoneParticipant _participantFromAny(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return const _TelephoneParticipant();
    }

    return _TelephoneParticipant(
      name: _firstNonEmpty([
        value['name'],
        value['stage_name'],
        value['display_name'],
      ]),
      avatarUrl: _firstNonEmpty([
        value['avatar_url'],
        value['avatar'],
        value['image_url'],
      ]),
      accountId: _firstNonEmpty([
        value['account_id'],
        value['id'],
      ]),
      countryCode: _firstNonEmpty([
        value['country_code'],
        value['phone_country_code'],
      ], fallback: 'US'),
    );
  }

  static String _extractRoomId(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return '';
    }

    return _firstNonEmpty([
      value['room_id'],
      value['session_id'],
      _nestedMap(value, 'room')['room_id'],
      _nestedMap(value, 'room')['id'],
      value['id'],
    ]);
  }

  static String _resolveCreatedRoomId(dynamic value) {
    final directRoomId = _extractRoomId(value);
    if (directRoomId.isNotEmpty) {
      return directRoomId;
    }

    if (value is! Map<String, dynamic>) {
      return '';
    }

    for (final nestedKey in const ['data', 'item', 'result', 'session', 'room']) {
      final nestedValue = value[nestedKey];
      if (nestedValue == null || identical(nestedValue, value)) {
        continue;
      }

      final nestedRoomId = _resolveCreatedRoomId(nestedValue);
      if (nestedRoomId.isNotEmpty) {
        return nestedRoomId;
      }
    }

    return '';
  }

  static Map<String, dynamic> _nestedMap(
    Map<String, dynamic> source,
    String key,
  ) {
    final value = source[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    return const {};
  }

  static String _normalizeChannelType(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'telephone':
      case 'voice':
      case 'voice_call':
      case 'call':
      case 'audio':
        return 'telephone';
      default:
        return normalized;
    }
  }

  static String _extractMessage(String body, {required String fallback}) {
    if (body.trim().isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      return body;
    }

    return fallback;
  }

  static String _firstNonEmpty(
    Iterable<dynamic> values, {
    String fallback = '',
  }) {
    for (final value in values) {
      final stringValue = _stringValue(value);
      if (stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    return fallback;
  }

  static String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    return value.toString().trim();
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_stringValue(value)) ?? 0;
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }
    final normalized = _stringValue(value).toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static DateTime? _dateTimeFromAny(dynamic value) {
    final stringValue = _stringValue(value);
    if (stringValue.isEmpty) {
      return null;
    }
    return DateTime.tryParse(stringValue)?.toLocal();
  }
}

class TelephoneSessionListItem {
  const TelephoneSessionListItem({
    required this.roomId,
    required this.counterpartName,
    required this.counterpartAvatarUrl,
    required this.counterpartAccountId,
    required this.counterpartCountryCode,
    required this.status,
    required this.callStatus,
    required this.remainingDurationSeconds,
    required this.validUntil,
    required this.closedReason,
    required this.updatedAt,
  });

  final String roomId;
  final String counterpartName;
  final String counterpartAvatarUrl;
  final String counterpartAccountId;
  final String counterpartCountryCode;
  final String status;
  final String callStatus;
  final int remainingDurationSeconds;
  final DateTime? validUntil;
  final String closedReason;
  final DateTime? updatedAt;
}

class TelephoneSessionDetail {
  const TelephoneSessionDetail({
    required this.roomId,
    required this.counterpartName,
    required this.counterpartAvatarUrl,
    required this.counterpartAccountId,
    required this.status,
    required this.callStatus,
    required this.allocatedDurationSeconds,
    required this.remainingDurationSeconds,
    required this.validUntil,
    required this.deadlineAt,
    required this.closedReason,
    required this.canRing,
    required this.canAccept,
    required this.canEnd,
    required this.canEndTransaction,
  });

  final String roomId;
  final String counterpartName;
  final String counterpartAvatarUrl;
  final String counterpartAccountId;
  final String status;
  final String callStatus;
  final int allocatedDurationSeconds;
  final int remainingDurationSeconds;
  final DateTime? validUntil;
  final DateTime? deadlineAt;
  final String closedReason;
  final bool canRing;
  final bool canAccept;
  final bool canEnd;
  final bool canEndTransaction;
}

class _TelephoneParticipant {
  const _TelephoneParticipant({
    this.name = '',
    this.avatarUrl = '',
    this.accountId = '',
    this.countryCode = 'US',
  });

  final String name;
  final String avatarUrl;
  final String accountId;
  final String countryCode;

  _TelephoneParticipant merge(_TelephoneParticipant other) {
    return _TelephoneParticipant(
      name: name.isNotEmpty ? name : other.name,
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : other.avatarUrl,
      accountId: accountId.isNotEmpty ? accountId : other.accountId,
      countryCode: countryCode.isNotEmpty ? countryCode : other.countryCode,
    );
  }
}

class TelephoneCallRealtimeClient {
  TelephoneCallRealtimeClient._();

  static final TelephoneCallRealtimeClient instance =
      TelephoneCallRealtimeClient._();

  final StreamController<TelephoneCallEvent> _eventController =
      StreamController<TelephoneCallEvent>.broadcast();
  io.Socket? _socket;
  String _token = '';
  final Set<String> _joinedRooms = <String>{};

  Stream<TelephoneCallEvent> get eventStream => _eventController.stream;

  Future<void> connect() async {
    final token = AuthSession.instance.accessToken ?? '';
    final socketUrl = '${ApiConfig.socketBaseUrl}/call';

    if (_socket != null && _token != token) {
      _socket?.dispose();
      _socket = null;
      _token = '';
      _joinedRooms.clear();
    }

    if (_socket != null) {
      await _waitForConnection(_socket!);
      return;
    }

    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .disableAutoConnect()
          .setExtraHeaders(
            token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {},
          )
          .setAuth(token.isNotEmpty ? {'token': token} : {})
          .build(),
    );

    _socket = socket;
    _token = token;
    _bindEvents(socket);
    await _waitForConnection(socket);
  }

  Future<void> ensureRoomSubscription(String roomId) async {
    final trimmedRoomId = roomId.trim();
    if (trimmedRoomId.isEmpty) {
      return;
    }

    await connect();
    final socket = _socket;
    if (socket == null || !socket.connected) {
      throw const AuthServiceException('Koneksi realtime telephone belum siap.');
    }

    if (_joinedRooms.add(trimmedRoomId)) {
      socket.emitWithAck('join_room', {'room_id': trimmedRoomId}, ack: (_) {});
    }
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _token = '';
    _joinedRooms.clear();
  }

  void _bindEvents(io.Socket socket) {
    socket.on('connect_error', (dynamic payload) {
      _eventController.add(
        TelephoneCallEvent(
          event: 'connect_error',
          roomId: '',
          payload: payload,
        ),
      );
    });

    for (final event in const [
      'call_ringing',
      'call_accepted',
      'call_rejected',
      'call_ended',
      'call_auto_ended',
      'call_transaction_completed',
    ]) {
      socket.on(event, (dynamic payload) {
        _eventController.add(
          TelephoneCallEvent(
            event: event,
            roomId: _extractEventRoomId(payload),
            payload: payload,
          ),
        );
      });
    }
  }

  Future<void> _waitForConnection(io.Socket socket) async {
    final completer = Completer<void>();

    void handleConnect(dynamic _) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    void handleConnectError(dynamic error) {
      if (!completer.isCompleted) {
        completer.completeError(
          AuthServiceException(error?.toString() ?? 'Koneksi telephone gagal.'),
        );
      }
    }

    socket.once('connect', handleConnect);
    socket.once('connect_error', handleConnectError);
    socket.connect();

    if (socket.connected && !completer.isCompleted) {
      completer.complete();
    }

    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {
        throw const AuthServiceException('Koneksi realtime telephone timeout.');
      },
    );
  }

  String _extractEventRoomId(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return TelephoneSessionService._firstNonEmpty([
        payload['room_id'],
        payload['session_id'],
        TelephoneSessionService._nestedMap(payload, 'data')['room_id'],
      ]);
    }
    return '';
  }
}

class TelephoneCallEvent {
  const TelephoneCallEvent({
    required this.event,
    required this.roomId,
    required this.payload,
  });

  final String event;
  final String roomId;
  final dynamic payload;
}