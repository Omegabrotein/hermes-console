// SPDX-License-Identifier: GPL-3.0-only
// SPDX-FileCopyrightText: Copyright (c) 2026 XPeta Lab
//
// La presentación de iOS, vista desde los llamadores de producción.
//
// Los tests de notification_presentation_call_test.dart construyen su propia
// llamada a plugin.show(), así que pasarían aunque nadie usara el traductor.
// Estos tests conducen el NotificationService real y el controlador de voz
// real contra el canal real del plugin, y comprueban que lo que sale lleva
// las opciones de iOS que tocan.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/notifications/notification_delivery_store.dart';
import 'package:hermes_android/core/services/notifications/notification_service.dart';
import 'package:hermes_android/core/services/notifications/voice_notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  sqflite.databaseFactory = databaseFactoryFfi;

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<MethodCall> calls;
  late String deliveryPath;

  NotificationService testService(SharedPreferences prefs) => NotificationService(
    prefs,
    deliveryStore: NotificationDeliveryStore(
      databaseFactory: databaseFactoryFfi,
      databasePath: deliveryPath,
    ),
  );

  setUp(() async {
    final directory = await Directory.systemTemp.createTemp(
      'ios-presentation-delivery-',
    );
    deliveryPath = '${directory.path}/notification_delivery_v1.db';
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    calls = <MethodCall>[];
    SharedPreferences.setMockInitialValues({
      'app_locale': 'es',
      'notif_perm_requested': true,
      'notif_background_listen': true,
    });
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'areNotificationsEnabled':
          return true;
        case 'checkPermissions':
          // What the iOS plugin answers: notifications are authorised.
          return <String, Object?>{
            'isEnabled': true,
            'isSoundEnabled': true,
            'isAlertEnabled': true,
            'isBadgeEnabled': true,
            'isProvisionalEnabled': false,
            'isCriticalEnabled': false,
          };
        case 'initialize':
          return true;
        case 'getActiveNotifications':
          return <Object?>[];
        default:
          return null;
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  /// The iOS options that travelled with a `show` call.
  Map<String, Object?> iosOptionsOf(MethodCall call) {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    final specifics = args['platformSpecifics'] as Map<Object?, Object?>?;
    if (specifics == null) return const {};
    final out = <String, Object?>{};
    specifics.forEach((k, v) => out[k.toString()] = v);
    return out;
  }

  MethodCall showCall() => calls.firstWhere((c) => c.method == 'show');

  group('the real NotificationService', () {
    test('a transfer in progress is silent on iOS', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = testService(prefs);
      addTearDown(service.closeDelivery);

      await service.transferProgress(
        id: 4242,
        title: 'Transfer',
        body: 'Working',
        progress: 1,
        max: 10,
      );

      final options = iosOptionsOf(showCall());
      expect(
        options,
        isNotEmpty,
        reason: 'without iOS options the plugin uses its defaults and sounds',
      );
      expect(options['presentSound'], isFalse);
      // Passive is what keeps it quiet in the background too.
      expect(options['interruptionLevel'], 0);
    });

    test('a background operation is silent on iOS', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = testService(prefs);
      addTearDown(service.closeDelivery);

      await service.operationProgress(
        id: 4243,
        title: 'Operation',
        body: 'Working',
      );

      final options = iosOptionsOf(showCall());
      expect(options['presentSound'], isFalse);
      expect(options['interruptionLevel'], 0);
    });

    test('a finished transfer that failed stays silent', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = testService(prefs);
      addTearDown(service.closeDelivery);
      service.appInForeground = false;

      await service.transferDone(
        id: 4244,
        title: 'Transfer',
        body: 'Failed',
        ok: false,
      );

      final options = iosOptionsOf(showCall());
      expect(options['presentSound'], isFalse);
      expect(options['interruptionLevel'], 0);
    });

    test('a finished transfer that succeeded sounds', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = testService(prefs);
      addTearDown(service.closeDelivery);
      service.appInForeground = false;

      await service.transferDone(
        id: 4245,
        title: 'Transfer',
        body: 'Done',
        ok: true,
      );

      final options = iosOptionsOf(showCall());
      expect(options['presentSound'], isTrue);
      // The runs channel is normal importance: it sounds without a heads-up.
      expect(options['presentBanner'], isFalse);
      expect(options['interruptionLevel'], 1);
    });

    test('a finished transfer in the foreground stays silent', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = testService(prefs);
      addTearDown(service.closeDelivery);
      service.appInForeground = true;

      await service.transferDone(
        id: 4246,
        title: 'Transfer',
        body: 'Done',
        ok: true,
      );

      final options = iosOptionsOf(showCall());
      expect(options['presentSound'], isFalse);
      expect(options['interruptionLevel'], 0);
    });
  });

  group('the real voice notifier', () {
    test('the voice session notification is silent on iOS', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = testService(prefs);
      addTearDown(service.closeDelivery);
      // The real notifier (the one production uses), not a fake.
      final notifier = VoiceNotificationController.platform(service);

      await notifier.ensureChannel();
      final posted = await notifier.post(
        id: VoiceNotificationController.notifId,
        title: 'Voice',
        body: 'Listening',
      );
      expect(posted, isTrue);

      final options = iosOptionsOf(showCall());
      expect(
        options,
        isNotEmpty,
        reason: 'the voice session must not inherit the default sound',
      );
      expect(options['presentSound'], isFalse);
      expect(options['interruptionLevel'], 0);
    });
  });
}
