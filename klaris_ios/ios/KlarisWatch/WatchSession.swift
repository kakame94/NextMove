// WatchConnectivity session — receives snapshots from iPhone, sends memos back.
import Foundation
import WatchConnectivity

struct WatchAppointment: Identifiable, Codable {
  let id: String
  let title: String
  let time: String
  let prospectName: String?
}

class WatchSession: NSObject, ObservableObject, WCSessionDelegate {
  static let shared = WatchSession()

  @Published var hotCount: Int = 0
  @Published var todayAppointments: [WatchAppointment] = []

  override init() {
    super.init()
    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }

  // MARK: - WCSessionDelegate (watchOS)

  func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}

  func session(_ session: WCSession, didReceiveApplicationContext appContext: [String: Any]) {
    DispatchQueue.main.async {
      self.hotCount = (appContext["hot"] as? Int) ?? 0
      if let data = appContext["appointments"] as? Data,
         let decoded = try? JSONDecoder().decode([WatchAppointment].self, from: data) {
        self.todayAppointments = decoded
      }
    }
  }

  // MARK: - Send memo back to iPhone

  func send(memo: String) {
    guard WCSession.default.activationState == .activated else { return }
    WCSession.default.sendMessage(["type": "memo", "text": memo], replyHandler: nil) { err in
      print("watch send err: \(err.localizedDescription)")
    }
  }
}
