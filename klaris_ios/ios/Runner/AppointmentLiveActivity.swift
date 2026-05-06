// Klaris — Live Activity (ActivityKit, iOS 16.1+)
//
// Pinned to Lock Screen + Dynamic Island when an appointment is in progress.
// Shows: prospect name, time remaining, location.
// Bridge: starts/updates/ends from Flutter via MethodChannel.

import ActivityKit
import Flutter
import Foundation

@available(iOS 16.1, *)
struct AppointmentAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var endsAt: Date
    var status: String  // "in_progress" | "ending_soon" | "ended"
  }
  var prospectName: String
  var title: String
  var location: String?
}

class AppointmentLiveActivityBridge: NSObject {
  private static let channelName = "ai.klarisapp.klaris_ios/live_activity"
  // activityId -> Activity
  @available(iOS 16.1, *)
  private var activities: [String: Activity<AppointmentAttributes>] {
    get {
      _activities as? [String: Activity<AppointmentAttributes>] ?? [:]
    }
    set { _activities = newValue }
  }
  private var _activities: Any = [String: Any]()

  static func register(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    let bridge = AppointmentLiveActivityBridge()
    channel.setMethodCallHandler { call, result in
      bridge.handle(call: call, result: result)
    }
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if #available(iOS 16.1, *) {
      switch call.method {
      case "start":
        startActivity(args: call.arguments, result: result)
      case "update":
        updateActivity(args: call.arguments, result: result)
      case "end":
        endActivity(args: call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    } else {
      result(FlutterError(code: "UNSUPPORTED_OS", message: "iOS 16.1+ required", details: nil))
    }
  }

  @available(iOS 16.1, *)
  private func startActivity(args: Any?, result: @escaping FlutterResult) {
    guard let args = args as? [String: Any],
          let appointmentId = args["appointmentId"] as? String,
          let prospectName = args["prospectName"] as? String,
          let title = args["title"] as? String,
          let endsAtTs = args["endsAt"] as? Int else {
      result(FlutterError(code: "BAD_ARGS", message: "args missing", details: nil))
      return
    }
    let location = args["location"] as? String
    let attrs = AppointmentAttributes(prospectName: prospectName, title: title, location: location)
    let state = AppointmentAttributes.ContentState(
      endsAt: Date(timeIntervalSince1970: TimeInterval(endsAtTs)),
      status: "in_progress"
    )
    do {
      let act = try Activity.request(attributes: attrs, content: .init(state: state, staleDate: nil))
      var d = activities; d[appointmentId] = act; _activities = d
      result(act.id)
    } catch {
      result(FlutterError(code: "START_FAIL", message: error.localizedDescription, details: nil))
    }
  }

  @available(iOS 16.1, *)
  private func updateActivity(args: Any?, result: @escaping FlutterResult) {
    guard let args = args as? [String: Any],
          let appointmentId = args["appointmentId"] as? String,
          let act = activities[appointmentId] else {
      result(false); return
    }
    let endsAtTs = (args["endsAt"] as? Int) ?? Int(act.content.state.endsAt.timeIntervalSince1970)
    let status = (args["status"] as? String) ?? act.content.state.status
    let state = AppointmentAttributes.ContentState(endsAt: Date(timeIntervalSince1970: TimeInterval(endsAtTs)), status: status)
    Task {
      await act.update(.init(state: state, staleDate: nil))
      result(true)
    }
  }

  @available(iOS 16.1, *)
  private func endActivity(args: Any?, result: @escaping FlutterResult) {
    guard let args = args as? [String: Any],
          let appointmentId = args["appointmentId"] as? String,
          let act = activities[appointmentId] else {
      result(false); return
    }
    Task {
      await act.end(nil, dismissalPolicy: .immediate)
      var d = activities; d.removeValue(forKey: appointmentId); _activities = d
      result(true)
    }
  }
}
