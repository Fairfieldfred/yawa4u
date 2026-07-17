import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: present rest-timer notifications while
    // the app is in the foreground.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Rest-timer Live Activity. Registered here rather than in the live_card
    // package because the widget extension must compile the shared
    // ActivityAttributes struct, which it cannot import across a pod module
    // boundary.
    LiveCardPlugin.register(
      with: engineBridge.pluginRegistry.registrar(forPlugin: "LiveCardPlugin")!
    )
  }
}
