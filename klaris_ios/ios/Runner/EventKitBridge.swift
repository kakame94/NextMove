// Klaris — EventKit MethodChannel bridge
//
// Wire from AppDelegate.swift:
//
//   import Flutter
//   import UIKit
//
//   @main
//   @objc class AppDelegate: FlutterAppDelegate {
//     override func application(
//       _ application: UIApplication,
//       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {
//       let controller = window?.rootViewController as! FlutterViewController
//       EventKitBridge.register(with: controller)
//       GeneratedPluginRegistrant.register(with: self)
//       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }
//   }

import Flutter
import EventKit
import UIKit

class EventKitBridge: NSObject {
  private static let channelName = "ai.klarisapp.klaris_ios/eventkit"
  private let store = EKEventStore()

  static func register(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    let bridge = EventKitBridge()
    channel.setMethodCallHandler { call, result in
      bridge.handle(call: call, result: result)
    }
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestAccess":
      requestAccess(result: result)
    case "createEvent":
      guard let args = call.arguments as? [String: Any],
            let title = args["title"] as? String,
            let startTs = args["startTs"] as? Int,
            let endTs = args["endTs"] as? Int else {
        result(FlutterError(code: "BAD_ARGS", message: "title/startTs/endTs required", details: nil))
        return
      }
      let notes = args["notes"] as? String
      let location = args["location"] as? String
      createEvent(title: title, notes: notes, location: location, startTs: startTs, endTs: endTs, result: result)
    case "removeEvent":
      guard let args = call.arguments as? [String: Any],
            let id = args["eventId"] as? String else {
        result(FlutterError(code: "BAD_ARGS", message: "eventId required", details: nil))
        return
      }
      removeEvent(id: id, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestAccess(result: @escaping FlutterResult) {
    if #available(iOS 17.0, *) {
      store.requestWriteOnlyAccessToEvents { granted, _ in
        DispatchQueue.main.async { result(granted) }
      }
    } else {
      store.requestAccess(to: .event) { granted, _ in
        DispatchQueue.main.async { result(granted) }
      }
    }
  }

  private func createEvent(title: String, notes: String?, location: String?, startTs: Int, endTs: Int, result: @escaping FlutterResult) {
    let event = EKEvent(eventStore: store)
    event.title = title
    event.notes = notes
    event.location = location
    event.startDate = Date(timeIntervalSince1970: TimeInterval(startTs))
    event.endDate = Date(timeIntervalSince1970: TimeInterval(endTs))
    event.calendar = store.defaultCalendarForNewEvents
    event.alarms = [EKAlarm(relativeOffset: -900)]  // 15 min before

    do {
      try store.save(event, span: .thisEvent, commit: true)
      result(event.eventIdentifier)
    } catch {
      result(FlutterError(code: "SAVE_FAILED", message: error.localizedDescription, details: nil))
    }
  }

  private func removeEvent(id: String, result: @escaping FlutterResult) {
    guard let event = store.event(withIdentifier: id) else {
      result(false)
      return
    }
    do {
      try store.remove(event, span: .thisEvent, commit: true)
      result(true)
    } catch {
      result(FlutterError(code: "REMOVE_FAILED", message: error.localizedDescription, details: nil))
    }
  }
}
