import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../auth/auth_session.dart';
import '../../main.dart';
import 'chat_service.dart';

class ChatNotificationService {
  ChatNotificationService._();

  static final ChatNotificationService instance = ChatNotificationService._();

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
        'chat_messages',
        'Chat Messages',
        description: 'Notifikasi untuk pesan chat masuk.',
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<ChatMessageData>? _messageSubscription;
  String _activeRoomId = '';
  bool _initialized = false;
  int _notificationId = 0;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_chatChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _messageSubscription = ChatService.realtime.messageStream.listen(
      _handleIncomingMessage,
    );
    _initialized = true;
  }

  void setActiveRoom(String roomId) {
    _activeRoomId = roomId.trim();
  }

  void clearActiveRoom(String roomId) {
    if (_activeRoomId == roomId.trim()) {
      _activeRoomId = '';
    }
  }

  void dispose() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _initialized = false;
  }

  Future<void> _handleIncomingMessage(ChatMessageData message) async {
    final roomId = message.roomId.trim();
    if (roomId.isEmpty || roomId == _activeRoomId) {
      return;
    }

    if (ChatService.isMessageFromCurrentActor(
      message,
      counterpartAccountId: '',
    )) {
      return;
    }

    final role = AuthSession.instance.role?.trim().toLowerCase();
    final title = role == 'talent' ? 'Pesan baru dari user' : 'Pesan baru';
    final routeName = role == 'talent' ? '/talent-messages' : '/messages';

    await _localNotifications.show(
      _notificationId++,
      title,
      message.text,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chatChannel.id,
          _chatChannel.name,
          channelDescription: _chatChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: '$routeName|$roomId',
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload?.trim() ?? '';
    if (payload.isEmpty) {
      return;
    }

    final separatorIndex = payload.indexOf('|');
    final routeName = separatorIndex >= 0
        ? payload.substring(0, separatorIndex)
        : payload;
    final navigator = MyApp.navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushNamed(routeName);
  }
}