// Apertura de los ajustes del sistema para conceder permisos.
//
// Android usa el canal nativo "hermes/android_apps" (openAppSettings); iOS
// usa "hermes/app_settings", que abre la URL que da la propia UIKit.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Abre la pantalla de ajustes de la app en el sistema operativo.
class AppSettingsOpener {
  static const MethodChannel _androidChannel = MethodChannel(
    'hermes/android_apps',
  );
  static const MethodChannel _iosChannel = MethodChannel('hermes/app_settings');

  const AppSettingsOpener();

  /// Devuelve true si el sistema abrió los ajustes.
  Future<bool> open() async {
    final channel = defaultTargetPlatform == TargetPlatform.iOS
        ? _iosChannel
        : _androidChannel;
    try {
      final ok = await channel.invokeMethod<bool>('openAppSettings');
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
