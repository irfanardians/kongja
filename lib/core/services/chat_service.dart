import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../auth/auth_session.dart';
import '../config/api_config.dart';
import 'api_client.dart';
import 'auth_service.dart';

class ChatService {
  ChatService._();

  static const Duration _sessionCacheMaxAge = Duration(minutes: 1);
  static final ChatRealtimeClient realtime = ChatRealtimeClient.instance;

  static bool _shouldRefreshSocketSession(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized.contains('jwt expired') ||
        normalized.contains('socket session is not authenticated') ||
        normalized.contains('unauthorized socket');
  }

  static Future<T> _retryWithFreshRealtimeSession<T>(
    Future<T> Function() action,
  ) async {
    final refreshed = await AuthSession.instance.refreshSession();
    if (!refreshed) {
      throw const AuthServiceException(
        'Sesi login sudah berakhir. Silakan login ulang.',
      );
    }

    realtime.disconnect();
    return action();
  }

  static Future<ChatSessionSummary> createChatRoom({
    required String talentAccountId,
    int durationMinutes = 60,
  }) async {
    final reusableSession = await _findReusableChatSession(
      talentAccountId: talentAccountId,
    );
    if (reusableSession != null) {
      return reusableSession;
    }

    final response = await ApiClient.postJson(
      '/meet-requests',
      body: {
        'talent_account_id': talentAccountId,
        'channel_type': 'chat',
        'duration_minutes': durationMinutes,
      },
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final existingSession = await _findExistingChatSession(
        counterpartAccountId: talentAccountId,
      );
      if (existingSession != null) {
        return existingSession;
      }

      throw AuthServiceException(
        _extractMessage(response, fallbackPrefix: 'Gagal membuat room chat'),
      );
    }

    invalidateSessionCache();

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    final directSession = _parseSessionFromAny(decoded);
    if (directSession != null && directSession.roomId.isNotEmpty) {
      return directSession;
    }

    final existingSession = await _findExistingChatSession(
      counterpartAccountId: talentAccountId,
    );
    if (existingSession != null) {
      return existingSession;
    }

    throw const AuthServiceException(
      'Room chat berhasil dibuat tetapi data room tidak ditemukan.',
    );
  }

  static Future<ChatSessionSummary> createCallSession({
    required String talentAccountId,
    required String channelType,
    int durationMinutes = 60,
  }) async {
    final trimmedTalentAccountId = talentAccountId.trim();
    final normalizedChannelType = _normalizeChannelType(channelType);
    final requestChannelType = normalizedChannelType == 'voice'
        ? 'telephone'
        : normalizedChannelType;
    if (trimmedTalentAccountId.isEmpty) {
      throw const AuthServiceException('ID talent tidak ditemukan.');
    }

    if (normalizedChannelType != 'voice' && normalizedChannelType != 'video') {
      throw AuthServiceException(
        'Jenis call "$channelType" belum didukung.',
      );
    }

    final response = await ApiClient.postJson(
      '/meet-requests',
      body: {
        'talent_account_id': trimmedTalentAccountId,
        'channel_type': requestChannelType,
        'duration_minutes': durationMinutes,
      },
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(
          response,
          fallbackPrefix: 'Gagal membuat sesi ${normalizedChannelType == 'voice' ? 'voice call' : 'video call'}',
        ),
      );
    }

    invalidateSessionCache();

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    final directSession = _parseSessionFromAny(decoded);
    if (directSession != null && directSession.roomId.isNotEmpty) {
      return directSession;
    }

    final sessions = await getChatSessions(forceRefresh: true);
    for (final session in sessions) {
      if (session.counterpartAccountId == trimmedTalentAccountId &&
          _normalizeChannelType(session.channelType) == normalizedChannelType) {
        return session;
      }
    }

    throw AuthServiceException(
      'Sesi ${normalizedChannelType == 'voice' ? 'voice call' : 'video call'} berhasil dibuat tetapi data session tidak ditemukan.',
    );
  }

  static Future<List<ChatSessionSummary>> getChatSessions({
    bool forceRefresh = false,
  }) async {
    final decoded = await ApiClient.getJson(
      '/chat-sessions',
      useCache: true,
      forceRefresh: forceRefresh,
      maxAge: _sessionCacheMaxAge,
    );

    return _parseSessionList(decoded);
  }

  static Future<List<ChatMessageData>> getMessages(
    String roomId, {
    bool forceRefresh = false,
  }) async {
    final decoded = await ApiClient.getJson(
      '/chat/$roomId/messages',
      useCache: false,
      forceRefresh: forceRefresh,
    );

    return _parseMessageList(decoded);
  }

  static Future<ChatMessageData> sendMessage(
    String roomId,
    String message, {
    String? clientMessageId,
  }) async {
    await realtime.ensureRoomSubscription(roomId);

    try {
      final realtimeMessage = await realtime.sendMessage(
        roomId,
        message,
        clientMessageId: clientMessageId,
      );
      invalidateSessionCache();
      return realtimeMessage;
    } on AuthServiceException catch (error) {
      if (_shouldRefreshSocketSession(error.message)) {
        final retriedRealtimeMessage = await _retryWithFreshRealtimeSession(
          () => realtime.sendMessage(
            roomId,
            message,
            clientMessageId: clientMessageId,
          ),
        );
        invalidateSessionCache();
        return retriedRealtimeMessage;
      }
      if (_shouldReactivateRoom(error.message)) {
        await reactivateRoom(roomId);
        final retriedRealtimeMessage = await realtime.sendMessage(
          roomId,
          message,
          clientMessageId: clientMessageId,
        );
        invalidateSessionCache();
        return retriedRealtimeMessage;
      }
      rethrow;
    }

    // Kode lama fallback ke REST endpoint (disimpan untuk rollback jika diperlukan):
    /*
    final response = await ApiClient.postJson(
      '/chat/$roomId/messages',
      body: {'content': message},
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final extractedMessage = _extractMessage(
        response,
        fallbackPrefix: 'Gagal mengirim pesan',
      );

      if (_shouldReactivateRoom(extractedMessage)) {
        await reactivateRoom(roomId);
        final retryResponse = await ApiClient.postJson(
          '/chat/$roomId/messages',
          body: {'content': message},
          authorized: true,
        );

        if (retryResponse.statusCode < 200 || retryResponse.statusCode >= 300) {
          throw AuthServiceException(
            _extractMessage(
              retryResponse,
              fallbackPrefix: 'Gagal mengirim pesan',
            ),
          );
        }

        invalidateSessionCache();

        final retryDecoded =
            retryResponse.body.isEmpty ? null : jsonDecode(retryResponse.body);
        final retryParsed = _parseMessageFromAny(retryDecoded);
        if (retryParsed != null) {
          return retryParsed;
        }

        return ChatMessageData(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          roomId: roomId,
          text: message,
          senderRole: _currentRole(),
          senderAccountId: '',
          timestampLabel: _timeLabel(DateTime.now()),
          createdAt: DateTime.now(),
          roomStatus: '',
          clientMessageId: '',
        );
      }

      throw AuthServiceException(extractedMessage);
    }

    invalidateSessionCache();

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    final parsed = _parseMessageFromAny(decoded);
    if (parsed != null) {
      return parsed;
    }

    return ChatMessageData(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      roomId: roomId,
      text: message,
      senderRole: _currentRole(),
      senderAccountId: '',
      timestampLabel: _timeLabel(DateTime.now()),
      createdAt: DateTime.now(),
      roomStatus: '',
      clientMessageId: '',
    );
    */
  }

  static Future<void> reactivateRoom(
    String roomId, {
    int durationMinutes = 60,
  }) async {
    final response = await ApiClient.postJson(
      '/chat/$roomId/reactivate',
      body: <String, dynamic>{'duration_minutes': durationMinutes},
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(response, fallbackPrefix: 'Gagal mengaktifkan ulang room chat'),
      );
    }

    invalidateSessionCache();
  }

  static void invalidateSessionCache() {
    ApiClient.invalidateCache('/chat-sessions');
  }

  static List<ChatSessionSummary> _parseSessionList(dynamic decoded) {
    final candidates = <dynamic>[];
    if (decoded is Map<String, dynamic>) {
      candidates.addAll([
        decoded['data'],
        decoded['items'],
        decoded['results'],
        decoded,
      ]);
    } else {
      candidates.add(decoded);
    }

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .map(_parseSessionFromAny)
            .whereType<ChatSessionSummary>()
            .toList(growable: false);
      }
    }

    final singleSession = _parseSessionFromAny(decoded);
    if (singleSession != null) {
      return [singleSession];
    }

    return const [];
  }

  static ChatSessionSummary? _parseSessionFromAny(dynamic value) {
    if (value is Map<String, dynamic>) {
      final roomId = _firstNonEmpty([
        value['room_id'],
        value['session_id'],
        value['chat_room_id'],
        _nestedValue(value['room'], 'room_id'),
        _nestedValue(value['room'], 'id'),
        value['id'],
      ]);
      if (roomId.isEmpty) {
        final nested = value['data'];
        if (nested != null && nested != value) {
          return _parseSessionFromAny(nested);
        }
        return null;
      }

      final participant = _resolveCounterpartParticipant(value);

      final channelType = _normalizeChannelType(
        _firstNonEmpty([
          value['channel_type'],
          value['type'],
        ], fallback: 'chat'),
      );

      return ChatSessionSummary(
        roomId: roomId,
        counterpartName: participant?.name ?? 'Chat User',
        counterpartAvatarUrl: participant?.avatarUrl ?? '',
        counterpartAccountId: participant?.accountId ?? '',
        counterpartCountry: participant?.country ?? _countryNameFromAny(value),
        counterpartCountryCode:
            participant?.countryCode ?? _countryCodeFromAny(value),
        counterpartRole: participant?.role ?? '',
        channelType: channelType,
        lastMessageText: _firstNonEmpty([
          _nestedValue(value['last_message'], 'message'),
          _nestedValue(value['last_message'], 'text'),
          _nestedValue(value['last_message'], 'content'),
          value['last_message'],
        ]),
        lastMessageTimeLabel: _timeLabel(
          _dateTimeFromAny(
            _firstNonEmpty([
              _nestedValue(value['last_message'], 'created_at'),
              value['updated_at'],
              value['created_at'],
            ]),
          ),
        ),
        isActiveNow: _sessionIsActiveNow(value),
        status: _firstNonEmpty([
          value['status'],
          if (_boolValue(value['is_active'])) 'active',
        ], fallback: 'active'),
        unreadCount: _intValue(value['unread_count']),
      );
    }
    return null;
  }

  static Future<ChatSessionSummary?> _findExistingChatSession({
    required String counterpartAccountId,
  }) async {
    final trimmedCounterpartAccountId = counterpartAccountId.trim();
    if (trimmedCounterpartAccountId.isEmpty) {
      return null;
    }

    final sessions = await getChatSessions(forceRefresh: true);
    for (final session in sessions) {
      if (session.channelType != 'chat') {
        continue;
      }

      if (session.counterpartAccountId == trimmedCounterpartAccountId) {
        return session;
      }
    }

    return null;
  }

  static Future<ChatSessionSummary?> _findReusableChatSession({
    required String talentAccountId,
  }) async {
    final trimmedTalentAccountId = talentAccountId.trim();
    if (trimmedTalentAccountId.isEmpty) {
      return null;
    }

    final decoded = await ApiClient.getJson(
      '/chat-sessions',
      useCache: true,
      forceRefresh: true,
      maxAge: _sessionCacheMaxAge,
    );

    for (final sessionMap in _extractSessionMaps(decoded)) {
      if (!_hasReusableChatStatus(sessionMap)) {
        continue;
      }

      if (_sessionTalentAccountId(sessionMap) != trimmedTalentAccountId) {
        continue;
      }

      final parsedSession = _parseSessionFromAny(sessionMap);
      if (parsedSession != null) {
        return parsedSession;
      }
    }

    return null;
  }

  static Iterable<Map<String, dynamic>> _extractSessionMaps(
    dynamic value,
  ) sync* {
    if (value is List) {
      for (final item in value) {
        yield* _extractSessionMaps(item);
      }
      return;
    }

    if (value is! Map<String, dynamic>) {
      return;
    }

    final nestedCollections = [value['data'], value['items'], value['results']];

    var yieldedNested = false;
    for (final nested in nestedCollections) {
      if (nested is List || nested is Map<String, dynamic>) {
        yieldedNested = true;
        yield* _extractSessionMaps(nested);
      }
    }

    if (!yieldedNested) {
      yield value;
    }
  }

  static bool _hasReusableChatStatus(Map<String, dynamic> session) {
    final normalizedStatus = _firstNonEmpty([
      session['status'],
      _nestedValue(session['room'], 'status'),
      if (_boolValue(session['is_active'])) 'active',
    ]).trim().toLowerCase();

    return normalizedStatus == 'active' || normalizedStatus == 'confirmed';
  }

  static String _sessionTalentAccountId(Map<String, dynamic> session) {
    return _firstNonEmpty([
      _nestedValue(session['talent'], 'account_id'),
      session['talent_account_id'],
      _nestedValue(session['room'], 'talent_account_id'),
      session['counterpart_role'] == 'talent'
          ? session['counterpart_account_id']
          : '',
      _currentRole() == 'user'
          ? _resolveCounterpartParticipant(session)?.accountId
          : '',
    ]);
  }

  static List<ChatMessageData> _parseMessageList(dynamic decoded) {
    final candidates = <dynamic>[];
    if (decoded is Map<String, dynamic>) {
      candidates.addAll([
        decoded['data'],
        decoded['items'],
        decoded['messages'],
        decoded['results'],
        decoded,
      ]);
    } else {
      candidates.add(decoded);
    }

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .map(_parseMessageFromAny)
            .whereType<ChatMessageData>()
            .toList(growable: false);
      }
    }

    final singleMessage = _parseMessageFromAny(decoded);
    if (singleMessage != null) {
      return [singleMessage];
    }

    return const [];
  }

  static ChatMessageData? _parseMessageFromAny(dynamic value) {
    if (value is Map<String, dynamic>) {
      final nested = value['data'];
      if (nested != null && nested != value) {
        final nestedMessage = _parseMessageFromAny(nested);
        if (nestedMessage != null) {
          return nestedMessage;
        }
      }

      final text = _firstNonEmpty([
        value['content'],
        value['text'],
        value['body'],
        value['message'],
      ]);
      if (text.isEmpty) {
        return null;
      }

      final createdAt = _dateTimeFromAny(
        _firstNonEmpty([
          value['created_at'],
          value['sent_at'],
          value['timestamp'],
        ]),
      );

      return ChatMessageData(
        id: _firstNonEmpty([
          value['id'],
          value['message_id'],
          createdAt.millisecondsSinceEpoch.toString(),
        ]),
        roomId: _firstNonEmpty([value['room_id'], value['chat_room_id']]),
        text: text,
        senderRole: _normalizeSenderRole(
          _firstNonEmpty([
            value['sender_role'],
            _nestedValue(value['sender'], 'role'),
            value['role'],
            _nestedValue(value['sender'], 'type'),
          ], fallback: 'user'),
        ),
        senderAccountId: _firstNonEmpty([
          value['sender_account_id'],
          _nestedValue(value['sender'], 'account_id'),
          value['account_id'],
        ]),
        timestampLabel: _timeLabel(createdAt),
        createdAt: createdAt,
        roomStatus: _firstNonEmpty([
          value['room_status'],
          _nestedValue(value['room'], 'status'),
        ]),
        clientMessageId: _firstNonEmpty([value['client_message_id']]),
      );
    }
    return null;
  }

  static bool _shouldReactivateRoom(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized.contains('chat_session_closed') ||
        normalized.contains('not active at this time') ||
        normalized.contains('session closed');
  }

  static bool _sessionIsActiveNow(Map<String, dynamic> value) {
    if (value.containsKey('is_active_now')) {
      return _boolValue(value['is_active_now']);
    }
    final nestedRoomIsActiveNow = _nestedValue(value['room'], 'is_active_now');
    if (nestedRoomIsActiveNow != null) {
      return _boolValue(nestedRoomIsActiveNow);
    }

    final normalizedStatus = _firstNonEmpty([
      value['status'],
      _nestedValue(value['room'], 'status'),
      if (_boolValue(value['is_active'])) 'active',
    ]).trim().toLowerCase();
    return normalizedStatus == 'active' ||
        normalizedStatus == 'pending' ||
        normalizedStatus == 'confirmed';
  }

  static _ChatParticipant? _participantFromAny(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _ChatParticipant(
        name: _firstNonEmpty([
          value['stage_name'],
          value['call_name'],
          value['name'],
          value['display_name'],
          [
            _stringValue(value['first_name']),
            _stringValue(value['last_name']),
          ].where((item) => item.isNotEmpty).join(' '),
        ], fallback: 'Chat User'),
        avatarUrl: ApiConfig.resolveExternalUrl(
          _firstNonEmpty([
            value['avatar_url'],
            value['image_url'],
            _nestedValue(value['talent_information'], 'avatar_url'),
            _nestedValue(value['profile_summary'], 'avatar_url'),
          ]),
        ),
        accountId: _firstNonEmpty([value['account_id'], value['id']]),
        country: _countryNameFromAny(value),
        role: _firstNonEmpty([value['role'], value['type']]),
        countryCode: _countryCodeFromAny(value),
      );
    }
    return null;
  }

  static String _countryNameFromAny(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return '';
    }

    return _firstNonEmpty([
      value['country'],
      value['nationality'],
      _nestedValue(value['account'], 'country'),
      _nestedValue(value['talent_information'], 'country'),
      _nestedValue(value['profile_summary'], 'country'),
    ]);
  }

  static String _countryCodeFromAny(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return '';
    }

    final directCode = _firstNonEmpty([
      value['country_code'],
      value['countryCode'],
      value['nationality_code'],
      value['phone_country_code'],
      _nestedValue(value['account'], 'country_code'),
      _nestedValue(value['account'], 'phone_country_code'),
      _nestedValue(value['talent_information'], 'country_code'),
      _nestedValue(value['profile_summary'], 'country_code'),
    ]);
    if (directCode.isNotEmpty) {
      final digitOnly = directCode.replaceAll(RegExp(r'\D'), '');
      if (digitOnly.isNotEmpty) {
        const phoneCountryCodeMap = {
          '62': 'ID',
          '63': 'PH',
          '66': 'TH',
          '84': 'VN',
          '81': 'JP',
          '1': 'US',
          '44': 'GB',
          '60': 'MY',
          '65': 'SG',
          '82': 'KR',
        };
        final mappedCode = phoneCountryCodeMap[digitOnly];
        if (mappedCode != null) {
          return mappedCode;
        }
      }

      final normalized = directCode.replaceAll(RegExp(r'[^A-Za-z]'), '');
      if (normalized.length >= 2) {
        return normalized.substring(0, 2).toUpperCase();
      }
    }

    final countryName = _countryNameFromAny(value);
    if (countryName.isEmpty) {
      return '';
    }

    const overrides = {
      'indonesia': 'ID',
      'philippines': 'PH',
      'thailand': 'TH',
      'vietnam': 'VN',
      'japan': 'JP',
      'united states': 'US',
      'usa': 'US',
      'united kingdom': 'GB',
      'great britain': 'GB',
      'canada': 'CA',
      'singapore': 'SG',
      'malaysia': 'MY',
    };

    final normalizedCountry = countryName.trim().toLowerCase();
    final override = overrides[normalizedCountry];
    if (override != null) {
      return override;
    }

    final letters = normalizedCountry.replaceAll(RegExp(r'[^a-z]'), '');
    if (letters.length >= 2) {
      return letters.substring(0, 2).toUpperCase();
    }
    return '';
  }

  static _ChatParticipant? _resolveCounterpartParticipant(
    Map<String, dynamic> session,
  ) {
    final role = _currentRole();
    final directParticipant =
        _participantFromAny(session['counterpart']) ??
        _participantFromAny(session['participant']) ??
        _participantFromAny(session['peer']);
    if (directParticipant != null) {
      return directParticipant;
    }

    final roleSpecificParticipant = role == 'talent'
        ? _participantFromAny(session['user'])
        : _participantFromAny(session['talent']);
    if (roleSpecificParticipant != null) {
      return roleSpecificParticipant;
    }

    final fallbackParticipant = role == 'talent'
        ? _participantFromAny({
            'name': _firstNonEmpty([
              session['user_call_name'],
              session['user_name'],
              session['customer_name'],
            ]),
            'avatar_url': _firstNonEmpty([
              session['user_avatar_url'],
              session['customer_avatar_url'],
            ]),
            'account_id': _firstNonEmpty([
              session['user_account_id'],
              session['customer_account_id'],
            ]),
            'country': _firstNonEmpty([
              session['user_country'],
              session['customer_country'],
            ]),
            'country_code': _firstNonEmpty([
              session['user_country_code'],
              session['customer_country_code'],
            ]),
            'phone_country_code': _firstNonEmpty([
              session['user_phone_country_code'],
              session['customer_phone_country_code'],
            ]),
            'role': 'user',
          })
        : _participantFromAny({
            'stage_name': _firstNonEmpty([
              session['talent_stage_name'],
              session['talent_name'],
            ]),
            'avatar_url': _firstNonEmpty([
              session['talent_avatar_url'],
              session['avatar_url'],
            ]),
            'account_id': _firstNonEmpty([
              session['talent_account_id'],
              session['account_id'],
            ]),
            'role': 'talent',
          });

    if (fallbackParticipant != null &&
        (fallbackParticipant.accountId.isNotEmpty ||
            fallbackParticipant.name != 'Chat User')) {
      return fallbackParticipant;
    }

    return _participantFromAny(session['user']) ??
        _participantFromAny(session['talent']);
  }

  static dynamic _nestedValue(dynamic parent, String key) {
    if (parent is Map<String, dynamic>) {
      return parent[key];
    }
    return null;
  }

  static String _normalizeChannelType(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'telephone':
      case 'voice_call':
      case 'call':
      case 'voice':
        return 'voice';
      case 'video_call':
      case 'video':
        return 'video';
      case 'meet':
      case 'offline_meet':
        return 'meet';
      default:
        return 'chat';
    }
  }

  static String _normalizeSenderRole(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'talent' ||
        normalized == 'host' ||
        normalized == 'creator' ||
        normalized == 'streamer') {
      return 'talent';
    }
    if (normalized == 'user' ||
        normalized == 'customer' ||
        normalized == 'member' ||
        normalized == 'client') {
      return 'user';
    }

    if (_currentRole() == 'talent' &&
        (normalized.contains('talent') || normalized.contains('host'))) {
      return 'talent';
    }

    return 'user';
  }

  static bool isMessageFromCurrentActor(
    ChatMessageData message, {
    required String counterpartAccountId,
  }) {
    final senderAccountId = message.senderAccountId.trim();
    final currentAccountId = AuthSession.instance.accountId.trim();
    if (senderAccountId.isNotEmpty && currentAccountId.isNotEmpty) {
      return senderAccountId == currentAccountId;
    }

    final trimmedCounterpartAccountId = counterpartAccountId.trim();
    if (senderAccountId.isNotEmpty && trimmedCounterpartAccountId.isNotEmpty) {
      return senderAccountId != trimmedCounterpartAccountId;
    }

    final normalizedRole = _normalizeSenderRole(message.senderRole);
    return normalizedRole == _currentRole();
  }

  static String _currentRole() {
    final role = AuthSession.instance.role?.trim().toLowerCase();
    return role == 'talent' ? 'talent' : 'user';
  }

  static DateTime _dateTimeFromAny(String value) {
    if (value.isEmpty) {
      return DateTime.now();
    }
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }

  static String _timeLabel(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static String _stringValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return '';
  }

  static String _firstNonEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final normalized = _stringValue(value);
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return fallback;
  }

  static String _extractMessage(
    dynamic response, {
    required String fallbackPrefix,
  }) {
    try {
      if (response.body is String && (response.body as String).isNotEmpty) {
        final decoded = jsonDecode(response.body as String);
        if (decoded is Map<String, dynamic>) {
          final messageCandidates = [
            decoded['message'],
            decoded['error'],
            _nestedValue(decoded['data'], 'message'),
            _nestedValue(decoded['data'], 'code'),
            _nestedValue(decoded['data'], 'error'),
          ];

          for (final candidate in messageCandidates) {
            if (candidate is String && candidate.trim().isNotEmpty) {
              return candidate.trim();
            }
          }
        }
      }
    } catch (_) {}

    final statusCode = response.statusCode;
    return '$fallbackPrefix. Server mengembalikan status $statusCode.';
  }
}

class ChatRealtimeClient {
  ChatRealtimeClient._();

  static final ChatRealtimeClient instance = ChatRealtimeClient._();

  io.Socket? _chatSocket;
  io.Socket? _notificationSocket;
  String _chatSocketToken = '';
  String _notificationSocketToken = '';
  final StreamController<ChatMessageData> _messageController =
      StreamController<ChatMessageData>.broadcast();
    final StreamController<ChatReadReceiptData> _readReceiptController =
      StreamController<ChatReadReceiptData>.broadcast();
  final StreamController<void> _sessionController =
      StreamController<void>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
    final Map<String, _PendingOutgoingMessage> _pendingOutgoingMessages =
      <String, _PendingOutgoingMessage>{};
  final Set<String> _joinedRooms = <String>{};
  bool _notificationsSubscribed = false;

  void _logSocketEvent(String event, [Object? payload]) {
    final role = AuthSession.instance.role?.trim().toLowerCase() ?? 'unknown';
    final accountId = AuthSession.instance.accountId.trim();
    final suffix = payload == null ? '' : ' payload=${_stringifyPayload(payload)}';
    final message = '[chat-socket][$role][$accountId] $event$suffix';
    developer.log(
      message,
      name: 'ChatRealtimeClient',
    );
    print(message);
  }

  String _stringifyPayload(Object payload) {
    try {
      return jsonEncode(payload);
    } catch (_) {
      return payload.toString();
    }
  }

  Stream<ChatMessageData> get messageStream => _messageController.stream;
    Stream<ChatReadReceiptData> get readReceiptStream =>
      _readReceiptController.stream;
  Stream<void> get sessionStream => _sessionController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isConnected => _chatSocket?.connected ?? false;

  Future<void> connect() async {
    await _connectChat();
    unawaited(
      _connectNotifications().catchError((Object error, StackTrace stackTrace) {
        _errorController.add('Koneksi notifikasi gagal: $error');
      }),
    );
  }

  Future<void> _connectChat() async {
    final token = AuthSession.instance.accessToken ?? '';
    final socketUrl = '${ApiConfig.socketBaseUrl}/chat';

    if (_chatSocket != null && _chatSocketToken != token) {
      _chatSocket?.dispose();
      _chatSocket = null;
      _chatSocketToken = '';
    }

    if (_chatSocket != null) {
      await _waitForSocketConnection(
        _chatSocket!,
        label: 'chat',
        url: socketUrl,
      );
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

    _chatSocket = socket;
    _chatSocketToken = token;
    _bindChatEvents(socket);
    await _waitForSocketConnection(socket, label: 'chat', url: socketUrl);
  }

  Future<void> _connectNotifications() async {
    final token = AuthSession.instance.accessToken ?? '';
    final socketUrl = '${ApiConfig.socketBaseUrl}/notifications';

    if (_notificationSocket != null && _notificationSocketToken != token) {
      _notificationSocket?.dispose();
      _notificationSocket = null;
      _notificationSocketToken = '';
    }

    if (_notificationSocket != null) {
      await _waitForSocketConnection(
        _notificationSocket!,
        label: 'notifications',
        url: socketUrl,
      );
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

    _notificationSocket = socket;
    _notificationSocketToken = token;
    _bindNotificationEvents(socket);
    await _waitForSocketConnection(
      socket,
      label: 'notifications',
      url: socketUrl,
    );
  }

  void disconnect() {
    for (final pending in _pendingOutgoingMessages.values) {
      pending.timeout.cancel();
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(
          const AuthServiceException('Koneksi realtime chat ditutup.'),
        );
      }
    }
    _pendingOutgoingMessages.clear();
    _joinedRooms.clear();
    _notificationsSubscribed = false;
    _chatSocket?.dispose();
    _notificationSocket?.dispose();
    _chatSocket = null;
    _notificationSocket = null;
    _chatSocketToken = '';
    _notificationSocketToken = '';
  }

  Future<void> ensureRoomSubscription(String roomId) async {
    final trimmedRoomId = roomId.trim();
    if (trimmedRoomId.isEmpty) {
      return;
    }

    await connect();
    final isNewRoom = _joinedRooms.add(trimmedRoomId);
    if (!isNewRoom && !isConnected) {
      return;
    }

    _emitJoinRoom(trimmedRoomId);
  }

  Future<void> markRoomRead(String roomId) async {
    final trimmedRoomId = roomId.trim();
    if (trimmedRoomId.isEmpty) {
      return;
    }

    await connect();
    _subscribeNotifications();
    final socket = _notificationSocket;
    if (socket == null || !socket.connected) {
      throw const AuthServiceException('Koneksi notifikasi belum siap.');
    }

    final completer = Completer<void>();
    socket.emitWithAck(
      'mark_room_read',
      {'room_id': trimmedRoomId},
      ack: (dynamic ack) {
        final ackError = _parseAckError(ack);
        if (ackError.isNotEmpty) {
          if (!completer.isCompleted) {
            completer.completeError(AuthServiceException(ackError));
          }
          return;
        }

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () => throw const AuthServiceException(
        'Server tidak mengirim ack mark_room_read.',
      ),
    );
  }

  Future<ChatMessageData> sendMessage(
    String roomId,
    String content, {
    String? clientMessageId,
  }) async {
    await ensureRoomSubscription(roomId);
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw const AuthServiceException('Message content must not be empty');
    }

    if (!isConnected) {
      throw const AuthServiceException('Koneksi realtime chat belum siap.');
    }

    final resolvedClientMessageId =
        clientMessageId?.trim().isNotEmpty == true
        ? clientMessageId!.trim()
        : 'local-${DateTime.now().microsecondsSinceEpoch}';
    final payload = {
      'room_id': roomId,
      'content': trimmedContent,
      'message_type': 'text',
      'client_message_id': resolvedClientMessageId,
    };
    _logSocketEvent('emit send_message', payload);

    final ackCompleter = Completer<ChatMessageData>();
    final ackTimeout = Timer(const Duration(seconds: 6), () {
      final pending = _pendingOutgoingMessages.remove(resolvedClientMessageId);
      if (pending != null) {
        pending.timeout.cancel();
      }
      if (!ackCompleter.isCompleted) {
        ackCompleter.completeError(
          const AuthServiceException(
            'Server tidak mengirim ack atau echo chat_message ke pengirim.',
          ),
        );
      }
    });
    _pendingOutgoingMessages[resolvedClientMessageId] = _PendingOutgoingMessage(
      clientMessageId: resolvedClientMessageId,
      roomId: roomId,
      content: trimmedContent,
      senderRole: ChatService._currentRole(),
      senderAccountId: AuthSession.instance.accountId.trim(),
      createdAt: DateTime.now(),
      completer: ackCompleter,
      timeout: ackTimeout,
    );

    _chatSocket?.emitWithAck(
      'send_message',
      payload,
      ack: (dynamic ack) {
        _logSocketEvent('ack send_message', ack);
        if (ackCompleter.isCompleted) {
          return;
        }

        final parsedAck = _parseAckMessage(ack);
        if (parsedAck != null) {
          _completePendingOutgoingMessage(
            resolvedClientMessageId,
            parsedAck,
          );
          return;
        }

        final ackError = _parseAckError(ack);
        if (ackError.isNotEmpty) {
          _failPendingOutgoingMessage(
            resolvedClientMessageId,
            AuthServiceException(ackError),
          );
          return;
        }
      },
    );

    try {
      return await ackCompleter.future;
    } finally {
      final pending = _pendingOutgoingMessages.remove(resolvedClientMessageId);
      pending?.timeout.cancel();
    }
  }

  void _emitJoinRoom(String roomId) {
    if (!isConnected) {
      return;
    }

    final payload = {'room_id': roomId};
    _logSocketEvent('emit join_room', payload);
    _chatSocket?.emitWithAck(
      'join_room',
      payload,
      ack: (dynamic ack) {
        _logSocketEvent('ack join_room', ack);
        final ackError = _parseAckError(ack);
        if (ackError.isNotEmpty) {
          _errorController.add(ackError);
          _sessionController.add(null);
        }
      },
    );
  }

  Future<void> _waitForSocketConnection(
    io.Socket socket, {
    required String label,
    required String url,
  }) async {
    if (socket.connected) {
      return;
    }

    final completer = Completer<void>();

    void handleConnect(dynamic _) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    void handleError(dynamic error) {
      if (!completer.isCompleted) {
        final detail = error == null ? 'unknown error' : error.toString();
        completer.completeError(
          AuthServiceException(
            'Koneksi realtime $label gagal ke $url: $detail',
          ),
        );
      }
    }

    socket.on('connect', handleConnect);
    socket.on('connect_error', handleError);
    socket.on('error', handleError);
    socket.connect();

    try {
      await completer.future.timeout(
        const Duration(seconds: 6),
        onTimeout: () => throw AuthServiceException(
          'Koneksi realtime $label timeout ke $url.',
        ),
      );
    } finally {
      socket.off('connect', handleConnect);
      socket.off('connect_error', handleError);
      socket.off('error', handleError);
    }
  }

  void _bindChatEvents(io.Socket socket) {
    socket.onConnect((_) {
      _logSocketEvent('connect chat');
      for (final roomId in _joinedRooms) {
        _emitJoinRoom(roomId);
      }
      _sessionController.add(null);
    });

    socket.on('connect_error', (dynamic payload) {
      _logSocketEvent('connect_error chat', payload ?? '');
      final message = payload?.toString().trim();
      if (message != null && message.isNotEmpty) {
        _errorController.add(message);
      }
    });

    socket.on('chat_error', (dynamic payload) {
      _logSocketEvent('event chat_error', payload ?? '');
      final message = _parseAckError(payload);
      if (message.isNotEmpty) {
        _errorController.add(message);
      }
    });

    void handleMessage(dynamic payload) {
      _logSocketEvent('event chat_message raw', payload ?? '');
      final parsed = ChatService._parseMessageFromAny(payload);
      if (parsed != null) {
        final resolvedMessage = _resolvePendingOutgoingMessage(parsed);
        _logSocketEvent('event chat_message parsed', {
          'id': resolvedMessage.id,
          'room_id': resolvedMessage.roomId,
          'sender_role': resolvedMessage.senderRole,
          'sender_account_id': resolvedMessage.senderAccountId,
          'client_message_id': resolvedMessage.clientMessageId,
          'text': resolvedMessage.text,
        });
        _messageController.add(resolvedMessage);
        _sessionController.add(null);
      }
    }

    void handleSession(dynamic payload) {
      _logSocketEvent('event room_joined', payload ?? '');
      _sessionController.add(null);
      final parsedMessage = ChatService._parseMessageFromAny(payload);
      if (parsedMessage != null) {
        _messageController.add(parsedMessage);
      }
    }

    void handleReadReceipt(dynamic payload) {
      final parsed = _parseReadReceiptFromAny(payload);
      if (parsed != null) {
        _readReceiptController.add(parsed);
      }
    }

    for (final event in const ['chat_message']) {
      socket.on(event, handleMessage);
    }

    for (final event in const ['message_read']) {
      socket.on(event, handleReadReceipt);
    }

    for (final event in const ['room_joined']) {
      socket.on(event, handleSession);
    }
  }

  ChatMessageData _resolvePendingOutgoingMessage(ChatMessageData message) {
    if (message.clientMessageId.isNotEmpty) {
      _logSocketEvent('resolve pending by client_message_id', {
        'client_message_id': message.clientMessageId,
        'sender_role': message.senderRole,
        'sender_account_id': message.senderAccountId,
      });
      return _completePendingOutgoingMessage(message.clientMessageId, message);
    }

    final now = DateTime.now();
    for (final pending in _pendingOutgoingMessages.values) {
      final isSameRoom = pending.roomId == message.roomId;
      final isSameSenderRole = pending.senderRole == message.senderRole;
      final isSameContent = pending.content == message.text.trim();
      final isRecent = now.difference(pending.createdAt) <=
          const Duration(seconds: 10);
      if (isSameRoom && isSameSenderRole && isSameContent && isRecent) {
        _logSocketEvent('resolve pending by heuristic', {
          'pending_client_message_id': pending.clientMessageId,
          'sender_role': message.senderRole,
          'sender_account_id': message.senderAccountId,
          'text': message.text,
        });
        return _completePendingOutgoingMessage(
          pending.clientMessageId,
          message,
        );
      }
    }

    return message;
  }

  ChatMessageData _completePendingOutgoingMessage(
    String clientMessageId,
    ChatMessageData message,
  ) {
    final pending = _pendingOutgoingMessages.remove(clientMessageId);
    if (pending == null) {
      _logSocketEvent('complete pending miss', {
        'client_message_id': clientMessageId,
        'sender_role': message.senderRole,
        'sender_account_id': message.senderAccountId,
      });
      return message;
    }

    final resolvedMessage = ChatMessageData(
      id: message.id,
      roomId: message.roomId,
      text: message.text,
      senderRole: pending.senderRole,
      senderAccountId: message.senderAccountId.trim().isNotEmpty
          ? message.senderAccountId
          : pending.senderAccountId,
      timestampLabel: message.timestampLabel,
      createdAt: message.createdAt,
      roomStatus: message.roomStatus,
      clientMessageId: message.clientMessageId,
    );

    pending.timeout.cancel();
    if (!pending.completer.isCompleted) {
      pending.completer.complete(resolvedMessage);
    }

    _logSocketEvent('complete pending hit', {
      'client_message_id': clientMessageId,
      'resolved_sender_role': resolvedMessage.senderRole,
      'resolved_sender_account_id': resolvedMessage.senderAccountId,
      'text': resolvedMessage.text,
    });

    return resolvedMessage;
  }

  void _failPendingOutgoingMessage(
    String clientMessageId,
    Object error,
  ) {
    final pending = _pendingOutgoingMessages.remove(clientMessageId);
    if (pending == null) {
      return;
    }

    pending.timeout.cancel();
    if (!pending.completer.isCompleted) {
      pending.completer.completeError(error);
    }
  }

  void _bindNotificationEvents(io.Socket socket) {
    socket.onConnect((_) {
      _subscribeNotifications();
      _sessionController.add(null);
    });

    socket.on('connect_error', (dynamic payload) {
      final message = payload?.toString().trim();
      if (message != null && message.isNotEmpty) {
        _errorController.add(message);
      }
    });

    for (final event in const [
      'notification_activity',
      'notification_unread_summary',
    ]) {
      socket.on(event, (_) {
        _sessionController.add(null);
      });
    }
  }

  void _subscribeNotifications() {
    if (_notificationsSubscribed || !(_notificationSocket?.connected ?? false)) {
      return;
    }

    _notificationSocket?.emitWithAck(
      'subscribe_notifications',
      const {'scope': 'chat'},
      ack: (_) {},
    );
    _notificationsSubscribed = true;
  }

  ChatMessageData? _parseAckMessage(dynamic ack) {
    if (ack is! Map<String, dynamic>) {
      return null;
    }


    final success = ack['success'];
    if (success is bool && !success) {
      return null;
    }

    return ChatService._parseMessageFromAny(ack['data'] ?? ack);
  }

  String _parseAckError(dynamic ack) {
    if (ack is Map<String, dynamic>) {
      final success = ack['success'];
      if (success is bool && success) {
        return '';
      }

      final message = ChatService._firstNonEmpty([
        ChatService._nestedValue(ack['data'], 'message'),
        ChatService._nestedValue(ack['data'], 'code'),
        ack['message'],
        ack['error'],
      ]);
      return message;
    }

    if (ack is String && ack.trim().isNotEmpty) {
      return ack.trim();
    }

    return '';
  }

  ChatReadReceiptData? _parseReadReceiptFromAny(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final source = value['data'] is Map<String, dynamic>
        ? value['data'] as Map<String, dynamic>
        : value;
    final roomId = ChatService._firstNonEmpty([source['room_id']]);
    final lastReadMessageId = ChatService._firstNonEmpty([
      source['last_read_message_id'],
    ]);
    final rawReadAt = ChatService._stringValue(source['read_at']);
    if (roomId.isEmpty && lastReadMessageId.isEmpty && rawReadAt.isEmpty) {
      return null;
    }

    return ChatReadReceiptData(
      roomId: roomId,
      readerAccountId: ChatService._firstNonEmpty([source['reader_account_id']]),
      readerRole: ChatService._normalizeSenderRole(
        ChatService._firstNonEmpty([source['reader_role']], fallback: 'user'),
      ),
      lastReadMessageId: lastReadMessageId,
      readAt: ChatService._dateTimeFromAny(rawReadAt),
    );
  }
}

class ChatSessionSummary {
  const ChatSessionSummary({
    required this.roomId,
    required this.counterpartName,
    required this.counterpartAvatarUrl,
    required this.counterpartAccountId,
    required this.counterpartCountry,
    required this.counterpartCountryCode,
    required this.counterpartRole,
    required this.channelType,
    required this.lastMessageText,
    required this.lastMessageTimeLabel,
    required this.isActiveNow,
    required this.status,
    required this.unreadCount,
  });

  final String roomId;
  final String counterpartName;
  final String counterpartAvatarUrl;
  final String counterpartAccountId;
  final String counterpartCountry;
  final String counterpartCountryCode;
  final String counterpartRole;
  final String channelType;
  final String lastMessageText;
  final String lastMessageTimeLabel;
  final bool isActiveNow;
  final String status;
  final int unreadCount;
}

class ChatMessageData {
  const ChatMessageData({
    required this.id,
    required this.roomId,
    required this.text,
    required this.senderRole,
    required this.senderAccountId,
    required this.timestampLabel,
    required this.createdAt,
    required this.roomStatus,
    required this.clientMessageId,
  });

  final String id;
  final String roomId;
  final String text;
  final String senderRole;
  final String senderAccountId;
  final String timestampLabel;
  final DateTime createdAt;
  final String roomStatus;
  final String clientMessageId;
}

class ChatReadReceiptData {
  const ChatReadReceiptData({
    required this.roomId,
    required this.readerAccountId,
    required this.readerRole,
    required this.lastReadMessageId,
    required this.readAt,
  });

  final String roomId;
  final String readerAccountId;
  final String readerRole;
  final String lastReadMessageId;
  final DateTime readAt;
}

class _ChatParticipant {
  const _ChatParticipant({
    required this.name,
    required this.avatarUrl,
    required this.accountId,
    required this.country,
    required this.countryCode,
    required this.role,
  });

  final String name;
  final String avatarUrl;
  final String accountId;
  final String country;
  final String countryCode;
  final String role;
}

class _PendingOutgoingMessage {
  const _PendingOutgoingMessage({
    required this.clientMessageId,
    required this.roomId,
    required this.content,
    required this.senderRole,
    required this.senderAccountId,
    required this.createdAt,
    required this.completer,
    required this.timeout,
  });

  final String clientMessageId;
  final String roomId;
  final String content;
  final String senderRole;
  final String senderAccountId;
  final DateTime createdAt;
  final Completer<ChatMessageData> completer;
  final Timer timeout;
}
