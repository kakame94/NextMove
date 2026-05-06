// Klaris — Geocoding MethodChannel bridge
// Wires CLGeocoder to Flutter via the channel "ai.klarisapp.klaris_ios/geocoding".
//
// AppDelegate.swift:
//   GeocodingBridge.register(with: controller)

import CoreLocation
import Flutter

class GeocodingBridge: NSObject {
  private static let channelName = "ai.klarisapp.klaris_ios/geocoding"
  private let geocoder = CLGeocoder()

  static func register(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    let bridge = GeocodingBridge()
    channel.setMethodCallHandler { call, result in
      bridge.handle(call: call, result: result)
    }
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "forward",
          let args = call.arguments as? [String: Any],
          let address = args["address"] as? String else {
      result(FlutterMethodNotImplemented)
      return
    }
    geocoder.geocodeAddressString(address) { placemarks, error in
      if let coord = placemarks?.first?.location?.coordinate {
        result(["lat": coord.latitude, "lng": coord.longitude])
      } else {
        result(nil)
      }
    }
  }
}
