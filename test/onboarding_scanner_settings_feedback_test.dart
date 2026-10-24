// SPDX-License-Identifier: GPL-3.0-only
// SPDX-FileCopyrightText: Copyright (c) 2026 XPeta Lab
//
// El scanner perdía el fallo al abrir los ajustes: la llamada al canal
// nativo se tragaba el error y el usuario no veía nada. Este test ejercita
// el camino real (cámara denegada -> "Abrir ajustes" -> el canal falla) y
// comprueba que aparece un aviso en pantalla.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/onboarding/onboarding_scanner.dart';
import 'package:hermes_android/core/screens/qr_scan_screen.dart';
import 'package:hermes_android/l10n/app_localizations.dart';

import 'support/onboarding_fakes.dart';

ValueChanged<bool>? _permission;

Widget _camera(ValueChanged<String> _, ValueChanged<bool> permission) {
  _permission = permission;
  return const SizedBox();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const androidChannel = MethodChannel('hermes/android_apps');
  const iosChannel = MethodChannel('hermes/app_settings');

  tearDown(() {
    for (final channel in [androidChannel, iosChannel]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    }
    _permission = null;
  });

  Future<Strings> pumpScanner(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      onboardingHost(
        const QrScanScreen(cameraBuilder: _camera),
        language: 'en',
      ),
    );
    await tester.pumpAndSettle();
    final s = Strings.of(tester.element(find.byType(QrScanView)));
    // Deniega la cámara para que aparezca el panel de recuperación.
    _permission!(false);
    await tester.pumpAndSettle();
    return s;
  }

  testWidgets('a failing settings open shows a visible error', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(iosChannel, (call) async {
          throw PlatformException(code: 'unavailable');
        });

    final s = await pumpScanner(tester);
    expect(find.text(s.qrCameraError), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('qr-open-settings')));
    await tester.pumpAndSettle();

    expect(
      find.text(s.qrSettingsFailed),
      findsOneWidget,
      reason: 'a failed settings open must be visible to the user',
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('a successful settings open shows no error', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(iosChannel, (call) async => true);

    final s = await pumpScanner(tester);

    await tester.tap(find.byKey(const ValueKey('qr-open-settings')));
    await tester.pumpAndSettle();

    expect(find.text(s.qrSettingsFailed), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('on Android the settings open still uses the native channel', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidChannel, (call) async {
          calls.add(call);
          return true;
        });

    final s = await pumpScanner(tester);

    await tester.tap(find.byKey(const ValueKey('qr-open-settings')));
    await tester.pumpAndSettle();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'openAppSettings');
    expect(find.text(s.qrSettingsFailed), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('a missing plugin is reported, not swallowed silently', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(iosChannel, (call) async {
          throw MissingPluginException();
        });

    final s = await pumpScanner(tester);

    await tester.tap(find.byKey(const ValueKey('qr-open-settings')));
    await tester.pumpAndSettle();

    expect(find.text(s.qrSettingsFailed), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
