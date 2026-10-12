// Paridad de claves ARB: app_vi.arb debe traducir exactamente las claves de
// app_en.arb (sin faltantes ni sobrantes) y conservar los placeholders.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

Set<String> _placeholders(String s) =>
    RegExp(r'\{(\w+)[,}]').allMatches(s).map((m) => m.group(1)!).toSet();

void main() {
  test('app_vi.arb tiene exactamente las claves de app_en.arb', () {
    final en = _arb('app_en.arb');
    final vi = _arb('app_vi.arb');
    expect(vi['@@locale'], 'vi');
    expect(_keys(en).difference(_keys(vi)), isEmpty, reason: 'faltan en vi');
    expect(_keys(vi).difference(_keys(en)), isEmpty, reason: 'sobran en vi');
  });

  test('app_vi.arb conserva los placeholders de app_en.arb', () {
    final en = _arb('app_en.arb');
    final vi = _arb('app_vi.arb');
    final bad = [
      for (final k in _keys(en))
        if (!_placeholders(
          vi[k] as String,
        ).containsAll(_placeholders(en[k] as String)))
          k,
    ];
    expect(bad, isEmpty);
  });
}
