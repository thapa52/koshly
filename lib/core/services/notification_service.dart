import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Manages all local notifications for Koshly.
///
/// Handles initialization, permission requests,
/// scheduling, and cancellation of notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initializes the notification service.
  /// Must be called before any other method.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // ─── Initialize Timezones ──────────────────────────────
    tz_data.initializeTimeZones();

    // ─── Android Settings ──────────────────────────────────
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // ─── iOS Settings ──────────────────────────────────────
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Requests notification permission from the user.
  /// Returns true if permission was granted.
  Future<bool> requestPermission() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Checks if notification permission is granted.
  Future<bool> hasPermission() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.areNotificationsEnabled();
      return granted ?? false;
    }

    return false;
  }

  /// Shows an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'koshly_general',
      'General Notifications',
      channelDescription: 'General Koshly notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedules a bill reminder notification.
  Future<void> scheduleBillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'koshly_bill_reminders',
      'Bill Reminders',
      channelDescription: 'Reminders for upcoming bills and payments',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF6C63FF),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancels a specific notification by ID.
  Future<void> cancelNotification(int id) async {
    _ensureInitialized();
    await _notifications.cancel(id);
  }

  /// Cancels all scheduled and shown notifications.
  Future<void> cancelAllNotifications() async {
    _ensureInitialized();
    await _notifications.cancelAll();
  }

  /// Returns a list of all pending notifications.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    _ensureInitialized();
    return _notifications.pendingNotificationRequests();
  }

  /// Handles notification tap events.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Ensures the service is initialized before use.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'NotificationService is not initialized. Call initialize() first.',
      );
    }
  }
}
