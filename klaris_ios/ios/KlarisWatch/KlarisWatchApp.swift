// Klaris — Apple Watch companion app (watchOS 10+)
//
// Surface: today's appointments + hot leads count + dictation-to-memo CTA.
// Companion-only (no standalone install). Pulls fresh data from iPhone via
// WatchConnectivity session.
//
// Add a Watch App target in Xcode named "KlarisWatch", paired to "Runner",
// supportedOS = watchOS 10+, then drop these files in.

import SwiftUI
import WatchConnectivity

@main
struct KlarisWatchApp: App {
  @StateObject private var session = WatchSession.shared
  var body: some Scene {
    WindowGroup {
      RootView().environmentObject(session)
    }
  }
}

struct RootView: View {
  @EnvironmentObject var session: WatchSession
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 14) {
          KpiCard(value: session.hotCount, label: "CHAUDS", color: .orange)
          KpiCard(value: session.todayAppointments.count, label: "RDV AUJOURD'HUI", color: .blue)

          if !session.todayAppointments.isEmpty {
            Text("AGENDA").font(.system(size: 9, weight: .heavy)).tracking(1.2).foregroundColor(.gray)
            ForEach(session.todayAppointments) { a in AppointmentRow(a: a) }
          }

          NavigationLink(destination: MemoView()) {
            HStack {
              Image(systemName: "mic.circle.fill").foregroundColor(.orange)
              Text("Note vocale").font(.system(size: 13, weight: .semibold))
              Spacer()
            }
            .padding(8)
            .background(Color.orange.opacity(0.15))
            .cornerRadius(10)
          }
          .buttonStyle(.plain)
        }
        .padding(8)
      }
      .navigationTitle("Klaris")
    }
  }
}

struct KpiCard: View {
  let value: Int
  let label: String
  let color: Color
  var body: some View {
    HStack {
      Text("\(value)").font(.system(size: 30, weight: .black, design: .monospaced)).foregroundColor(color)
      Spacer()
      Text(label).font(.system(size: 9, weight: .heavy)).tracking(1.2).foregroundColor(.gray)
    }
    .padding(10)
    .background(Color.white.opacity(0.05))
    .cornerRadius(10)
  }
}

struct AppointmentRow: View {
  let a: WatchAppointment
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(a.title).font(.system(size: 13, weight: .semibold)).lineLimit(1)
      Text("\(a.time) · \(a.prospectName ?? "—")").font(.system(size: 10)).foregroundColor(.gray)
    }
    .padding(.vertical, 4)
  }
}

struct MemoView: View {
  @State private var transcript = ""
  var body: some View {
    VStack {
      Text("Dicte ta note").font(.system(size: 14, weight: .semibold))
      Spacer()
      TextField("Tap pour dicter", text: $transcript).textFieldStyle(.plain).multilineTextAlignment(.center)
      Spacer()
      Button("Envoyer") {
        WatchSession.shared.send(memo: transcript)
      }
      .buttonStyle(.borderedProminent).tint(.orange)
      .disabled(transcript.isEmpty)
    }
    .padding()
    .navigationTitle("Mémo")
  }
}
