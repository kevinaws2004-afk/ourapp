import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Which kind of notification something is: each is its own Android
/// channel, so people can mute one kind in the system settings.
enum NotificationChannel {
  reminders('reminders', 'Reminders', 'Before the things you plan'),
  timer('timer', 'Timer', 'While a timer runs, and when its time is up'),
  daily('daily', 'Daily nudges', 'Morning plan and evening review'),
  goals('goals', 'Goals', 'Keep your goal streaks going');

  const NotificationChannel(this.id, this.label, this.description);

  final String id;
  final String label;
  final String description;
}

/// One notification to schedule.
@immutable
class ScheduledNote {
  const ScheduledNote({
    required this.key,
    required this.at,
    required this.title,
    required this.body,
    required this.channel,
    required this.payload,
  });

  /// Stable identity (`plan:ID`, `morning:2026-10-12`).
  final String key;

  /// When, as a UTC instant.
  final DateTime at;
  final String title;
  final String body;
  final NotificationChannel channel;

  /// What a tap opens (`plan:ID`, `today`, `focus`).
  final String payload;

  int get id => notificationId(key);

  @override
  bool operator ==(Object other) =>
      other is ScheduledNote &&
      other.key == key &&
      other.at == at &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(key, at, title, body);
}

/// A positive 31-bit id for [key], stable across launches.
int notificationId(String key) {
  var hash = 0;
  for (final unit in key.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash == ongoingTimerId ? hash + 1 : hash;
}

/// The ongoing "timer running" notification.
const ongoingTimerId = 7;

/// Local notifications (no server): scheduling, the ongoing timer, taps.
/// [NotificationService.disabled] does nothing (tests, unsupported
/// platforms, or when the plugin failed to start).
class NotificationService {
  NotificationService._(this._plugin);

  /// Does nothing.
  NotificationService.disabled() : _plugin = null;

  final FlutterLocalNotificationsPlugin? _plugin;
  final _taps = StreamController<String>.broadcast();
  String? _launchPayload;

  bool get isEnabled => _plugin != null;

  /// Payloads of notifications tapped while the app runs.
  Stream<String> get taps => _taps.stream;

  /// The payload of the notification that launched the app, once.
  String? takeLaunchPayload() {
    final p = _launchPayload;
    _launchPayload = null;
    return p;
  }

  /// Starts the plugin and the time zone database. Never throws: on
  /// failure returns a disabled service.
  static Future<NotificationService> start() async {
    if (kIsWeb ||
        !(defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      return NotificationService.disabled();
    }
    try {
      tzdata.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Falls back to UTC; instants still land at the right moment.
    }
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      final service = NotificationService._(plugin);
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          if (response.payload case final p?) service._taps.add(p);
        },
      );
      final launch = await plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        service._launchPayload = launch!.notificationResponse?.payload;
      }
      return service;
    } catch (_) {
      return NotificationService.disabled();
    }
  }

  /// Asks the system for permission to notify (Android 13+, iOS). True when
  /// allowed.
  Future<bool> requestPermission() async {
    final plugin = _plugin;
    if (plugin == null) return false;
    try {
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Whether notifications are allowed (Android; iOS reports true).
  Future<bool> isPermitted() async {
    final plugin = _plugin;
    if (plugin == null) return false;
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? true;
  }

  final Map<int, ScheduledNote> _scheduled = {};

  /// Makes the scheduled notifications exactly [notes]: cancels the ones no
  /// longer wanted or changed, schedules new ones. Past times are skipped.
  Future<void> apply(
    List<ScheduledNote> notes, {
    required DateTime nowUtc,
  }) async {
    final plugin = _plugin;
    if (plugin == null) return;
    final wanted = {
      for (final n in notes)
        if (n.at.isAfter(nowUtc)) n.id: n,
    };
    for (final id in [..._scheduled.keys]) {
      if (wanted[id] != _scheduled[id]) {
        await plugin.cancel(id: id);
        _scheduled.remove(id);
      }
    }
    for (final note in wanted.values) {
      if (_scheduled[note.id] == note) continue;
      try {
        await plugin.zonedSchedule(
          id: note.id,
          scheduledDate: tz.TZDateTime.from(note.at, tz.local),
          notificationDetails: _details(note.channel),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: note.title,
          body: note.body,
          payload: note.payload,
        );
        _scheduled[note.id] = note;
      } catch (_) {
        // A single failure (e.g. too many alarms) shouldn't stop the rest.
      }
    }
  }

  /// Clears everything scheduled from earlier launches (call once at start,
  /// before the first [apply]).
  Future<void> resetScheduled() async {
    await _plugin?.cancelAllPendingNotifications();
    _scheduled.clear();
  }

  /// The ongoing "timer running" notification, or none.
  Future<void> showOngoingTimer({
    required String? title,
    required String body,
    required DateTime startedAt,
  }) async {
    final plugin = _plugin;
    if (plugin == null) return;
    if (title == null) {
      await plugin.cancel(id: ongoingTimerId);
      return;
    }
    await plugin.show(
      id: ongoingTimerId,
      title: title,
      body: body,
      payload: 'focus',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannel.timer.id,
          NotificationChannel.timer.label,
          channelDescription: NotificationChannel.timer.description,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: true,
          usesChronometer: true,
          when: startedAt.millisecondsSinceEpoch,
          icon: 'ic_notification',
          color: _accent,
        ),
        iOS: const DarwinNotificationDetails(presentSound: false),
      ),
    );
  }

  static const _accent = Color(0xFF7C5CFC);

  NotificationDetails _details(NotificationChannel channel) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.label,
          channelDescription: channel.description,
          importance:
              channel == NotificationChannel.reminders ||
                  channel == NotificationChannel.timer
              ? Importance.high
              : Importance.defaultImportance,
          priority: Priority.high,
          icon: 'ic_notification',
          color: _accent,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(),
      );
}
