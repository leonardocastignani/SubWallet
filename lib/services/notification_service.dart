import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      debugPrint("Impossibile recuperare il fuso orario: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleRenewalReminder({
    required String serviceName,
    required double price,
    required DateTime renewalDate,
    required int reminderDays,
    required String currency,
  }) async {
    final DateTime scheduledDate = renewalDate.subtract(Duration(days: reminderDays));
    
    var tzScheduledDate = tz.TZDateTime.from(
      DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, 10, 0),
      tz.local,
    );

    if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint("Data notifica già passata, ignoro.");
      return;
    }

    final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'subwallet_reminders',
      'Promemoria Rinnovi',
      channelDescription: 'Notifiche per i rinnovi in scadenza',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF007AFF),
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    final String bodyText = reminderDays == 1 
        ? 'Domani si rinnoverà $serviceName ($currency${price.toStringAsFixed(2)}).' 
        : 'Tra $reminderDays giorni si rinnoverà $serviceName ($currency${price.toStringAsFixed(2)}).';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Rinnovo in arrivo! 💳',
      body: bodyText,
      scheduledDate: tzScheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint("Notifica programmata per $serviceName il $tzScheduledDate");
  }
}