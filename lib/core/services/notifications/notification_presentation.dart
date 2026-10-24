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

  /// Aviso audible pero sin heads-up en primer plano: suena y aparece en la
  /// lista. Es lo que expresa `importance: defaultImportance` (ejecuciones).
  sound,

  /// Aviso silencioso: no suena ni interrumpe, ni en primer plano ni en
  /// segundo plano. Aparece solo en el centro de notificaciones. Es lo que
  /// expresan `importance: low` con `playSound: false` (transferencias,
  /// operaciones, la sesión de voz).
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
///
/// Alcance de cada flag (es importante no prometer más de lo que se cumple):
///
/// - `presentSound` / `presentBanner` / `presentList` / `presentAlert` deciden
///   la presentación EN PRIMER PLANO (la app abierta). En segundo plano, iOS
///   decide con `interruptionLevel` y con el sonido que lleva el contenido.
/// - `interruptionLevel` es lo que gobierna el segundo plano:
///   `active` enciende la pantalla y suena; `passive` deja la notificación
///   en el centro sin encender pantalla ni sonar.
///
/// Por eso una notificación "silenciosa" necesita `passive`: con
/// `presentSound: false` a secas seguiría haciendo banner en segundo plano.
DarwinNotificationDetails darwinDetailsFor(NotifPresentation presentation) {
  switch (presentation) {
    case NotifPresentation.alert:
      return const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        interruptionLevel: InterruptionLevel.active,
      );
    case NotifPresentation.sound:
      return const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: false,
        presentList: true,
        interruptionLevel: InterruptionLevel.active,
      );
    case NotifPresentation.silent:
      // `passive` es lo que impide que la notificación interrumpa aunque la
      // app esté en segundo plano: iOS la deja en el centro de notificaciones
      // sin encender pantalla ni sonar. Los otros flags (presentSound,
      // presentBanner) solo deciden la presentación EN PRIMER PLANO, así que
      // sin `passive` una notificación "silenciosa" seguiría haciendo banner
      // en segundo plano.
      return const DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
        presentBanner: false,
        presentList: true,
        interruptionLevel: InterruptionLevel.passive,
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
