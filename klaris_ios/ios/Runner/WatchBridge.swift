// Klaris — iPhone-side watch bridge
//
// Pushes hot count + today's appointments to the paired Watch via
// WatchConnectivity application-context (idempotent, low-bandwidth).
// Receives dictated memos and forwards them to Flutter via MethodChannel.

import Flutter
import Foundation
import WatchConnectivity

class WatchBridge: NSObject, WCSessionDelegate {
  private static let channelName = "ai.klarisapp.klaris_ios/watch"
  private var channel: FlutterMethodChannel?

  static let shared = WatchBridge()

  static func register(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    shared.channel = channel
    channel.setMethodCallHandler { call, result in shared.handle(call: call, result: result) }
    if WCSession.isSupported() {
      WCSession.default.delegate = shared
      WCSession.default.activate()
    }
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "pushSnapshot":
      guard let args = call.arguments as? [String: Any],
            let hot = args["hot"] as? Int,
            let appointmentsJson = args["appointmentsJson"] as? String,
            let data = appointmentsJson.data(using: .utf8) else {
        result(false); return
      }
      do {
        try WCSession.default.updateApplicationContext(["hot": hot, "appointments": data])
        result(true)
      } catch {
        result(FlutterError(code: "WC_FAIL", message: error.localizedDescription, details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - WCSessionDelegate (iOS)

  func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    if let type = message["type"] as? String, type == "memo",
       let text = message["text"] as? String {
      DispatchQueue.main.async {
        self.channel?.invokeMethod("watchMemo", arguments: ["text": text])
      }
    }
  }
}
