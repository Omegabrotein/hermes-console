import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

/// Loads the bundled Mobile Bridge script.
///
/// iOS builds ship it gzipped (`.py.gz`): Apple's upload validator sniffs
/// bundled files and rejects plain Python text as "unsigned code".
/// Android keeps the plain `.py` asset.
Future<String> loadBundledBridgeSource({AssetBundle? bundle}) async {
  final b = bundle ?? rootBundle;
  try {
    final data = await b.load('assets/bridge/hermes_bridge.py.gz');
    return utf8.decode(gzip.decode(data.buffer.asUint8List()));
  } on FlutterError {
    return b.loadString('assets/bridge/hermes_bridge.py');
  }
}
