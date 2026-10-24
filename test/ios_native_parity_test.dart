// SPDX-License-Identifier: GPL-3.0-only
// SPDX-FileCopyrightText: Copyright (c) 2026 XPeta Lab
//
// Regresión de los dos huecos de iOS que encontró la revisión de v1.3.0:
//
//  1. El centro de notificaciones nunca recibía un delegate, así que en iOS
//     las notificaciones en primer plano no se mostraban y el toque no
//     llegaba a Dart. Ni el motor ni flutter_local_notifications lo asignan:
//     lo tiene que hacer la app (README del plugin).
//  2. El botón "Abrir ajustes" del scanner solo llamaba al canal de Android,
//     de modo que en iOS el control visible no hacía absolutamente nada.
//
// Las dos pruebas leen el AppDelegate de iOS como texto porque el
// comportamiento nativo (UIKit) no se puede ejercitar desde Linux; la
// parte que sí es Dart (el opener de ajustes) se prueba de verdad.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/platform/app_settings.dart';

const _appDelegatePath = 'ios/Runner/AppDelegate.swift';

String _appDelegate() => File(_appDelegatePath).readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('iOS notification centre delegate', () {
    test('AppDelegate assigns itself as the notification centre delegate', () {
      final swift = _appDelegate();
      expect(
        swift,
        contains('UNUserNotificationCenter.current().delegate = self'),
        reason:
            'the notification centre delegate must be set at launch, otherwise '
            'iOS never routes willPresentNotification / '
            'didReceiveNotificationResponse to flutter_local_notifications',
      );
    });

    test('the delegate is assigned inside the launch callback', () {
      final swift = _appDelegate();
      final assign = swift.indexOf(
        'UNUserNotificationCenter.current().delegate = self',
      );
      expect(assign, greaterThan(-1));
      // The assignment lives in the launch callback, so a cold start
      // triggered by a notification tap is not missed.
      final callback = swift.indexOf(
        'didFinishLaunchingWithOptions launchOptions',
      );
      expect(callback, greaterThan(-1));
      expect(assign, greaterThan(callback));
      // ...and it is inside that callback, not after it.
      expect(
        assign,
        lessThan(swift.indexOf('\n  }\n', callback)),
        reason: 'the delegate assignment must live in the launch callback',
      );
    });

    test('UserNotifications is imported so the delegate API is available', () {
      expect(_appDelegate(), contains('import UserNotifications'));
    });
  });

  group('camera-denied "open settings" on iOS', () {
    test('iOS registers an app_settings channel that uses the UIKit URL', () {
      final swift = _appDelegate();
      expect(
        swift,
        contains('hermes/app_settings'),
        reason: 'iOS needs its own channel to open the app settings page',
      );
      expect(
        swift,
        contains('UIApplication.openSettingsURLString'),
        reason:
            'the settings URL must come from UIKit rather than a hand-written '
            'scheme that could drift',
      );
      expect(swift, contains('openAppSettings'));
    });

    test('the Android channel is still wired for Android', () {
      final kotlin = File(
        'android/app/src/main/kotlin/com/hermesagent/hermes_android/MainActivity.kt',
      ).readAsStringSync();
      expect(kotlin, contains('"openAppSettings"'));
    });

    test('the scanner no longer calls the Android-only channel directly', () {
      final scanner = File(
        'lib/core/screens/onboarding/onboarding_scanner.dart',
      ).readAsStringSync();
      expect(
        scanner,
        isNot(contains("MethodChannel(\n        'hermes/android_apps'")),
        reason: 'the scanner must go through AppSettingsOpener, which routes '
            'per platform',
      );
      expect(scanner, contains('AppSettingsOpener'));
    });
  });

  group('AppSettingsOpener routing', () {
    const androidChannel = MethodChannel('hermes/android_apps');
    const iosChannel = MethodChannel('hermes/app_settings');
    final calls = <MethodCall>[];

    void mock(MethodChannel channel, Object? result) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return result;
          });
    }

    tearDown(() {
      for (final channel in [androidChannel, iosChannel]) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      }
      calls.clear();
    });

    test('on iOS it opens the native app_settings channel', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      mock(iosChannel, true);

      expect(await const AppSettingsOpener().open(), isTrue);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'openAppSettings');
    });

    test('on Android it keeps using the native android_apps channel', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      mock(androidChannel, true);

      expect(await const AppSettingsOpener().open(), isTrue);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'openAppSettings');
    });

    test('a failing platform channel is reported as false, not thrown', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, (call) async {
            throw PlatformException(code: 'unavailable');
          });

      expect(await const AppSettingsOpener().open(), isFalse);
    });

    test('a missing platform channel is reported as false, not thrown', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, (call) async {
            throw MissingPluginException();
          });

      expect(await const AppSettingsOpener().open(), isFalse);
    });
  });
}
