import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_session.dart';
import '../../main.dart';
import 'api_client.dart';
import 'chat_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase config might not be present yet in local development.
  }
}

class ChatNotificationService {
  ChatNotificationService._();

  static final ChatNotificationService instance = ChatNotificationService._();
  static const _pushTokenKey = 'push.fcm_token';
  static const _deviceIdKey = 'push.device_id';

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
  StreamSubscription<String>? _pushTokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _pushOpenSubscription;
  String _activeRoomId = '';
  bool _initialized = false;
  bool _pushInitialized = false;
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

    await _initializePushNotifications();
    _initialized = true;
  }

  Future<void> refreshPushRegistration() async {
    if (!_pushInitialized || !AuthSession.instance.isAuthenticated) {
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.trim().isEmpty) {
        return;
      }

      await _storePushToken(token);
      await _registerPushToken(token);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to refresh push token registration',
        name: 'chat-push',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> revokePushRegistration() async {
    final storedToken = await _readStoredPushToken();
    if (storedToken.isEmpty) {
      return;
    }

    try {
      final deviceId = await _deviceId();
      await ApiClient.postJson(
        '/devices/token/revoke',
        body: {'token': storedToken, 'device_id': deviceId},
        authorized: true,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Failed to revoke push token registration',
        name: 'chat-push',
        error: error,
        stackTrace: stackTrace,
      );
    }
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
    _pushTokenRefreshSubscription?.cancel();
    _pushOpenSubscription?.cancel();
    _messageSubscription = null;
    _pushTokenRefreshSubscription = null;
    _pushOpenSubscription = null;
    _initialized = false;
    _pushInitialized = false;
  }

  Future<void> _initializePushNotifications() async {
    if (Platform.isIOS || Platform.isMacOS) {
      developer.log(
        'Apple push notifications are temporarily disabled for local signing.',
        name: 'chat-push',
      );
      return;
    }

    try {
      await Firebase.initializeApp();
    } catch (error, stackTrace) {
      developer.log(
        'Firebase push initialization skipped',
        name: 'chat-push',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      developer.log(
        'Push notification permission denied',
        name: 'chat-push',
      );
    }

    if (Platform.isIOS || Platform.isMacOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );
    }

    _pushTokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((String token) async {
          await _storePushToken(token);
          if (!AuthSession.instance.isAuthenticated) {
            return;
          }
          await _registerPushToken(token);
        });

    _pushOpenSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessageOpened,
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessageOpened(initialMessage);
    }

    _pushInitialized = true;
    await refreshPushRegistration();
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

  Future<void> _registerPushToken(String token) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty || !AuthSession.instance.isAuthenticated) {
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final deviceId = await _deviceId();
    await ApiClient.postJson(
      '/devices/token',
      body: {
        'token': trimmedToken,
        'platform': _platformName(),
        'device_id': deviceId,
        'app_version': '${packageInfo.version}+${packageInfo.buildNumber}',
        'provider': 'fcm',
      },
      authorized: true,
    );
  }

  Future<void> _storePushToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pushTokenKey, token.trim());
  }

  Future<String> _readStoredPushToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_pushTokenKey)?.trim() ?? '';
  }

  Future<String> _deviceId() async {
    final preferences = await SharedPreferences.getInstance();
    final existingDeviceId = preferences.getString(_deviceIdKey)?.trim() ?? '';
    if (existingDeviceId.isNotEmpty) {
      return existingDeviceId;
    }

    final random = Random.secure();
    final generatedDeviceId = [
      Platform.operatingSystem,
      DateTime.now().millisecondsSinceEpoch.toString(),
      random.nextInt(1 << 32).toRadixString(16),
    ].join('-');

    await preferences.setString(_deviceIdKey, generatedDeviceId);
    return generatedDeviceId;
  }

  String _platformName() {
    if (Platform.isAndroid) {
      return 'android';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    if (Platform.isMacOS) {
      return 'macos';
    }
    return Platform.operatingSystem;
  }

  void _handleRemoteMessageOpened(RemoteMessage message) {
    final roomId = message.data['room_id']?.toString().trim() ?? '';
    final role = AuthSession.instance.role?.trim().toLowerCase();
    final routeName = role == 'talent' ? '/talent-messages' : '/messages';
    _navigateToRoute(routeName, roomId: roomId);
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
    final roomId = separatorIndex >= 0
        ? payload.substring(separatorIndex + 1).trim()
        : '';
    _navigateToRoute(routeName, roomId: roomId);
  }

  void _navigateToRoute(String routeName, {String roomId = ''}) {
    final navigator = MyApp.navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushNamed(routeName);
  }
}