// SPDX-License-Identifier: GPL-3.0-only
// SPDX-FileCopyrightText: Copyright (c) 2026 XPeta Lab
//
// Lo que la app envía de verdad al plugin.
//
// Los tests de notification_presentation.dart comprueban el traductor; este
// comprueba que el `show` real lleva las opciones de iOS. Un test que solo
// mira el traductor pasaría aunque nadie lo usara.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_android/core/services/notifications/notification_presentation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    // The plugin resolves its platform implementation from a global; without
    // registering the iOS one there is nothing to call.
    IOSFlutterLocalNotificationsPlugin.registerWith();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (call) async {
            calls.add(call);
            return call.method == 'initialize' ? true : null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          null,
        );
    debugDefaultTargetPlatformOverride = null;
  });

  Map<String, Object?> platformSpecificsOf(MethodCall call) {
    final args = call.arguments as Map<Object?, Object?>;
    final specifics = args['platformSpecifics'] as Map<Object?, Object?>?;
    return specifics == null
        ? const {}
        : specifics.map((k, v) => MapEntry(k.toString(), v));
  }

  test('the show call carries the iOS presentation alongside Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    final plugin = FlutterLocalNotificationsPlugin();

    await plugin.show(
      1,
      'title',
      'body',
      notificationDetailsFor(
        android: AndroidNotificationDetails(
          'hermes_background_operations',
          'Operations',
          importance: Importance.low,
        ),
        presentation: NotifPresentation.silent,
      ),
    );

    final show = calls.firstWhere((c) => c.method == 'show');
    final specifics = platformSpecificsOf(show);

    expect(
      specifics,
      isNotEmpty,
      reason: 'without platformSpecifics the plugin uses its own defaults, '
          'which always play the sound',
    );
    expect(specifics['presentSound'], isFalse);
    expect(specifics['presentBanner'], isFalse);
  });

  test('an alert notification carries the sound and the banner', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    final plugin = FlutterLocalNotificationsPlugin();

    await plugin.show(
      2,
      'title',
      'body',
      notificationDetailsFor(
        android: AndroidNotificationDetails(
          'hermes_approvals',
          'Approvals',
          importance: Importance.high,
        ),
        presentation: NotifPresentation.alert,
      ),
    );

    final show = calls.firstWhere((c) => c.method == 'show');
    final specifics = platformSpecificsOf(show);

    expect(specifics['presentSound'], isTrue);
    expect(specifics['presentBanner'], isTrue);
  });

  test('a notification without iOS details would have sounded', () async {
    // The regression this whole change exists for: no iOS details means the
    // plugin's defaults, and those include the sound.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    final plugin = FlutterLocalNotificationsPlugin();

    await plugin.show(
      3,
      'title',
      'body',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'hermes_background_operations',
          'Operations',
          importance: Importance.low,
        ),
      ),
    );

    final show = calls.firstWhere((c) => c.method == 'show');
    expect(platformSpecificsOf(show), isEmpty);
  });
}
