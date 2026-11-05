import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/admin_integrations_copy.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/l10n/app_localizations_en.dart';
import 'package:hermes_android/l10n/app_localizations_vi.dart';
import 'package:hermes_android/main.dart' show AppLocales;

void main() {
  test('Vietnamese catalog retains its original message count and English gap fallback', () {
    // Source catalog is intentionally incomplete, never padded with English.
    final vi =
        jsonDecode(File('lib/l10n/app_vi.arb').readAsStringSync()) as Map;
    expect(
      vi.keys.where((key) => !(key as String).startsWith('@')).length,
      4424,
    );
    expect(StringsVi().qrSettingsFailed, 'Không thể mở cài đặt hệ thống');
    expect(
      StringsVi().i18n131RecoveredTurnActive,
      StringsEn().i18n131RecoveredTurnActive,
    );
    expect(StringsVi().connDiagTimeout(7), StringsEn().connDiagTimeout(7));
    expect(
      AppLocales.resolve(const Locale('vi', 'VN'), Strings.supportedLocales),
      const Locale('vi'),
    );
  });

  testWidgets(
    'upstream localized copy in vi falls back to English, not Spanish',
    (tester) async {
      String? title;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: Strings.localizationsDelegates,
          supportedLocales: Strings.supportedLocales,
          home: Builder(
            builder: (context) {
              title = AdminIntegrationsCopy.of(context).screenTitle;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(title, StringsEn().i18n131AiScreenTitle);
    },
  );
}
