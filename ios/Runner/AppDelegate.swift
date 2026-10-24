import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications never installs the notification centre
    // delegate itself, and without it iOS drops foreground notifications and
    // taps. FlutterAppDelegate already forwards both callbacks to the
    // registered plugins, so it is enough to point the centre at it. Set
    // here, in the launch callback, so a cold start triggered by a tap is not
    // missed either.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "HermesDeviceMemory") {
      FlutterMethodChannel(name: "hermes/device_memory", binaryMessenger: registrar.messenger())
        .setMethodCallHandler { call, result in
          if call.method == "physicalMemory" {
            result(Int64(ProcessInfo.processInfo.physicalMemory))
          } else {
            result(FlutterMethodNotImplemented)
          }
        }
    }
    // The iOS counterpart of the Android openAppSettings channel: opens this
    // app's page in the system settings, where the camera permission lives.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "HermesAppSettings") {
      FlutterMethodChannel(name: "hermes/app_settings", binaryMessenger: registrar.messenger())
        .setMethodCallHandler { call, result in
          if call.method == "openAppSettings" {
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
              result(false)
              return
            }
            UIApplication.shared.open(url, options: [:]) { opened in
              result(opened)
            }
          } else {
            result(FlutterMethodNotImplemented)
          }
        }
    }
  }
}
