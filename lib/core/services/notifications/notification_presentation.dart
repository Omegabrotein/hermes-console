// Presentación de las notificaciones en iOS.
//
// En Android, el canal describe cómo suena una notificación y la importancia
// de la notificación queda ACOTADA por la del canal (API 26+). En iOS no hay
// canales: cada notificación lleva sus propias opciones de presentación, y si
// no las lleva el plugin usa sus valores por defecto (presentAlert/Sound/
// Banner/List = true). Eso hacía que en iOS sonara TODO, incluidas las
// notificaciones que en Android son silenciosas (transferencias, operaciones,
// la sesión de voz).
//
// Aquí se traduce la importancia del canal de Android a las opciones de iOS,
// para que las dos plataformas se comporten igual.
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Cómo debe sonar y mostrarse una notificación.
enum NotifPresentation {
  /// Aviso que interrumpe: heads-up con sonido. Equivale a un canal de
  /// Android con `importance: high` (aprobaciones, respuestas).
  alert,

  /// Aviso audible pero sin heads-up: suena y aparece en la lista, sin
  /// banner. Equivale a `importance: defaultImportance` (ejecuciones).
  sound,

  /// Aviso silencioso: sin sonido y sin banner. Aparece en el centro de
  /// notificaciones pero no interrumpe. Equivale a `importance: low` con
  /// `playSound: false` (transferencias, operaciones, la sesión de voz).
  silent,
}

/// Traduce la importancia de un canal de Android a la presentación de iOS.
///
/// Android acota la importancia de la notificación a la del canal, así que
/// la del canal es la que manda: es la que refleja de verdad cómo suena.
NotifPresentation presentationForImportance(Importance importance) {
  switch (importance) {
    case Importance.high:
    case Importance.max:
      return NotifPresentation.alert;
    case Importance.defaultImportance:
      return NotifPresentation.sound;
    default:
      return NotifPresentation.silent;
  }
}

/// Opciones de presentación de iOS para una notificación.
DarwinNotificationDetails darwinDetailsFor(NotifPresentation presentation) {
  switch (presentation) {
    case NotifPresentation.alert:
      return const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      );
    case NotifPresentation.sound:
      return const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: false,
        presentList: true,
      );
    case NotifPresentation.silent:
      return const DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
        presentBanner: false,
        presentList: true,
      );
  }
}

/// `NotificationDetails` con Android e iOS a la vez.
///
/// En Android manda [android]; en iOS, [presentation]. Los detalles de iOS no
/// pueden quedar a null: el plugin usaría sus valores por defecto (sonido
/// siempre) en lugar de la intención que expresa el canal de Android.
NotificationDetails notificationDetailsFor({
  required AndroidNotificationDetails android,
  required NotifPresentation presentation,
}) => NotificationDetails(
  android: android,
  iOS: darwinDetailsFor(presentation),
);
