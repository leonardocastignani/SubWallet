import 'dart:typed_data';
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

  static const int _monthlyReportId = 888888; 

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
  }

  Future<void> requestPermission() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
    try {
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint("Permessi già richiesti o in corso.");
    }
  }

  Future<void> scheduleMonthlyReport({required bool enable}) async {
    if (!enable) {
      await flutterLocalNotificationsPlugin.cancel(id: _monthlyReportId);
      debugPrint("Report mensile disattivato. Allarme cancellato.");
      return;
    }

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, 1, 10, 0);
    
    if (scheduledDate.isBefore(now)) {
      int nextMonth = now.month + 1;
      int year = now.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        year++;
      }
      scheduledDate = tz.TZDateTime(tz.local, year, nextMonth, 1, 10, 0);
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'subwallet_report_channel',
      'Report Mensile',
      channelDescription: 'Riepilogo delle spese all\'inizio del mese',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', 
      color: Color(0xFF007AFF),
      enableLights: true,
      ledColor: Color(0xFF007AFF),
      ledOnMs: 1000,
      ledOffMs: 500,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentSound: true, presentBadge: true, presentAlert: true),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: _monthlyReportId,
      title: '📊 Il tuo Report è pronto!',
      body: 'È iniziato un nuovo mese. Apri SubWallet per controllare le tue spese imminenti.',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );

    debugPrint("Report mensile ATTIVATO: prima esecuzione -> $scheduledDate");
  }

  Future<void> scheduleRenewalReminder({
    required String serviceName,
    required double price,
    required DateTime renewalDate,
    required int reminderDays,
    required String currency,
  }) async {
    final DateTime targetDate = DateTime(renewalDate.year, renewalDate.month, renewalDate.day - reminderDays);
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final String plainBodyText = reminderDays == 1 
        ? 'Il tuo abbonamento a $serviceName si rinnoverà domani. Verranno addebitati $currency${price.toStringAsFixed(2)}.' 
        : 'Il tuo abbonamento a $serviceName si rinnoverà tra $reminderDays giorni. Verranno addebitati $currency${price.toStringAsFixed(2)}.';

    final String htmlBodyText = reminderDays == 1 
        ? 'Il tuo abbonamento a <b>$serviceName</b> si rinnoverà domani. Verranno addebitati <b>$currency${price.toStringAsFixed(2)}</b>.' 
        : 'Il tuo abbonamento a <b>$serviceName</b> si rinnoverà tra $reminderDays giorni. Verranno addebitati <b>$currency${price.toStringAsFixed(2)}</b>.';

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'subwallet_reminders_v5',
      'Promemoria Rinnovi',
      channelDescription: 'Avvisi eleganti per i pagamenti in uscita',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', 
      color: const Color(0xFF007AFF),
      enableLights: true,
      ledColor: const Color(0xFF007AFF),
      ledOnMs: 1000,
      ledOffMs: 500,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      styleInformation: BigTextStyleInformation(
        htmlBodyText,
        htmlFormatBigText: true,
        contentTitle: '<b>Rinnovo in arrivo! 💳</b>',
        htmlFormatContentTitle: true,
        summaryText: 'Promemoria',
      ),
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(
        presentSound: true,
        presentBadge: true,
        presentAlert: true,
      ),
    );

    final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    if (targetDate.isBefore(today)) {
      debugPrint("Data notifica ($targetDate) passata rispetto ad oggi ($today), ignoro.");
      return;
    }

    if (targetDate.isAtSameMomentAs(today)) {
      final now = DateTime.now();
      if (now.hour >= 10) {
        await flutterLocalNotificationsPlugin.show(
          id: notificationId,
          title: 'Rinnovo in arrivo! 💳',
          body: plainBodyText,
          notificationDetails: platformChannelSpecifics,
        );
        debugPrint("Mostrata istantaneamente! (Il target è oggi, e sono già passate le 10:00)");
        return;
      }
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime(
      tz.local,
      targetDate.year,
      targetDate.month,
      targetDate.day,
      10,
      0,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Rinnovo in arrivo! 💳',
      body: plainBodyText,
      scheduledDate: tzScheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint("Notifica programmata in sottofondo per $serviceName il $tzScheduledDate");
  }
}