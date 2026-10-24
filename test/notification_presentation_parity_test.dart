// SPDX-License-Identifier: GPL-3.0-only
// SPDX-FileCopyrightText: Copyright (c) 2026 XPeta Lab
//
// Paridad de presentación entre Android e iOS.
//
// Antes, las notificaciones solo describían su presentación en Android
// (NotificationDetails(android: ...)). En iOS el plugin usaba entonces sus
// valores por defecto (presentAlert/Sound/Banner/List = true), así que en
// iOS sonaba TODO: también las transferencias, las operaciones en segundo
// plano y la sesión de voz, que en Android son silenciosas.
//
// Estos tests comprueban que cada tipo de notificación lleva las opciones de
// iOS que reflejan la intención del canal de Android.
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/notifications/notification_presentation.dart';

void main() {
  group('translation of the Android channel importance', () {
    test('a high-importance channel alerts (heads-up with sound)', () {
      expect(
        presentationForImportance(Importance.high),
        NotifPresentation.alert,
      );
      expect(
        presentationForImportance(Importance.max),
        NotifPresentation.alert,
      );
    });

    test('a normal-importance channel sounds without heads-up', () {
      expect(
        presentationForImportance(Importance.defaultImportance),
        NotifPresentation.sound,
      );
    });

    test('a low-importance channel is silent', () {
      expect(
        presentationForImportance(Importance.low),
        NotifPresentation.silent,
      );
      expect(
        presentationForImportance(Importance.min),
        NotifPresentation.silent,
      );
    });
  });

  group('the iOS options of each presentation', () {
    test('alert: sound and banner', () {
      final d = darwinDetailsFor(NotifPresentation.alert);
      expect(d.presentSound, isTrue);
      expect(d.presentBanner, isTrue);
      expect(d.presentList, isTrue);
    });

    test('sound: sound but no banner', () {
      final d = darwinDetailsFor(NotifPresentation.sound);
      expect(d.presentSound, isTrue);
      expect(d.presentBanner, isFalse);
      expect(d.presentList, isTrue);
    });

    test('silent: no sound and no banner, still listed', () {
      final d = darwinDetailsFor(NotifPresentation.silent);
      expect(d.presentSound, isFalse);
      expect(d.presentBanner, isFalse);
      expect(d.presentAlert, isFalse);
      // It still reaches the notification center; it just does not interrupt.
      expect(d.presentList, isTrue);
    });
  });

  group('notificationDetailsFor', () {
    test('it always carries the iOS details', () {
      final details = notificationDetailsFor(
        android: AndroidNotificationDetails(
          'hermes_voice',
          'Voice',
          importance: Importance.low,
        ),
        presentation: NotifPresentation.silent,
      );
      expect(
        details.iOS,
        isNotNull,
        reason:
            'without iOS details the plugin falls back to its defaults, which '
            'always play the sound',
      );
      expect(details.iOS!.presentSound, isFalse);
      expect(details.android, isNotNull);
    });

    test('a silent notification does not inherit the default sound', () {
      final details = notificationDetailsFor(
        android: AndroidNotificationDetails(
          'hermes_background_operations',
          'Operations',
          importance: Importance.low,
        ),
        presentation: NotifPresentation.silent,
      );
      expect(details.iOS!.presentSound, isFalse);
      expect(details.iOS!.presentBanner, isFalse);
    });
  });
}
