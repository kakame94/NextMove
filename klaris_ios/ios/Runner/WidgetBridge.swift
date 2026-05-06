// Klaris — Widget data bridge
// Writes JSON snapshot to App Group UserDefaults so KlarisWidget extension can read it.
//
// AppDelegate.swift:
//   WidgetBridge.register(with: controller)

import Flutter
import WidgetKit

class WidgetBridge: NSObject {
  private static let channelName = "ai.klarisapp.klaris_ios/widget"
  private static let appGroup = "group.ai.klarisapp.klaris_ios"
  private static let key = "klaris.widget.snapshot"

  static func register(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    let bridge = WidgetBridge()
    channel.setMethodCallHandler { call, result in
      bridge.handle(call: call, result: result)
    }
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "write":
      guard let args = call.arguments as? [String: Any],
            let jsonString = args["json"] as? String,
            let data = jsonString.data(using: .utf8),
            let defaults = UserDefaults(suiteName: WidgetBridge.appGroup) else {
        result(false)
        return
      }
      defaults.set(data, forKey: WidgetBridge.key)
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      result(true)

    case "reload":
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
        result(true)
      } else {
        result(false)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
