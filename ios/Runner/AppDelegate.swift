import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerProximityChannel(engineBridge.pluginRegistry)
  }

  /// `com.minttalk.app/proximity` — `setEnabled(Bool)` turns on proximity
  /// monitoring so the screen blanks while the phone is held to the ear
  /// during an earpiece call. Method calls arrive on the main thread.
  private func registerProximityChannel(_ registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "MintTalkProximity") else { return }
    let channel = FlutterMethodChannel(
      name: "com.minttalk.app/proximity",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setEnabled" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let device = UIDevice.current
      device.isProximityMonitoringEnabled = (call.arguments as? Bool) ?? false
      // Stays false on devices without a sensor (e.g. iPad).
      result(device.isProximityMonitoringEnabled)
    }
  }
}
