// Klaris — Home Screen Widget (WidgetKit)
//
// Shows broker's top 3 hot prospects + count. Refreshed every 15 min.
// Reads from a shared App Group container so the Flutter app can push fresh
// data via [WidgetDataService].
//
// Add a widget extension target in Xcode named "KlarisWidget", set the App
// Group `group.ai.klarisapp.klaris_ios` on both targets, then drop these
// files into the extension folder.

import SwiftUI
import WidgetKit

struct HotLead: Codable, Identifiable {
  let id: String
  let nom: String?
  let score: Int
  let secteur: String?
}

struct WidgetSnapshot: Codable {
  let generatedAt: Date
  let total: Int
  let hot: Int
  let leads: [HotLead]

  static let placeholder = WidgetSnapshot(
    generatedAt: Date(),
    total: 12,
    hot: 3,
    leads: [
      HotLead(id: "1", nom: "Marie Tremblay",  score: 9, secteur: "Verdun"),
      HotLead(id: "2", nom: "Sébastien Côté",  score: 8, secteur: "Plateau"),
      HotLead(id: "3", nom: "Nadia Lemieux",   score: 7, secteur: "Laval"),
    ]
  )
}

struct KlarisProvider: TimelineProvider {
  static let appGroup = "group.ai.klarisapp.klaris_ios"
  static let key = "klaris.widget.snapshot"

  func placeholder(in context: Context) -> KlarisEntry {
    KlarisEntry(date: Date(), snapshot: WidgetSnapshot.placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (KlarisEntry) -> Void) {
    completion(KlarisEntry(date: Date(), snapshot: load() ?? .placeholder))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<KlarisEntry>) -> Void) {
    let entry = KlarisEntry(date: Date(), snapshot: load() ?? .placeholder)
    let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
    completion(Timeline(entries: [entry], policy: .after(next)))
  }

  private func load() -> WidgetSnapshot? {
    guard let defaults = UserDefaults(suiteName: KlarisProvider.appGroup),
          let data = defaults.data(forKey: KlarisProvider.key) else { return nil }
    return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
  }
}

struct KlarisEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
}

struct KlarisWidgetView: View {
  let entry: KlarisEntry
  @Environment(\.widgetFamily) var family

  // Klaris brand
  static let primary = Color(red: 0.760, green: 0.353, blue: 0.212)        // oklch(0.55 0.18 30)
  static let bg = Color(red: 0.060, green: 0.067, blue: 0.090)             // dark sci-fi
  static let mutedFg = Color(red: 0.600, green: 0.620, blue: 0.652)
  static let success = Color(red: 0.314, green: 0.627, blue: 0.294)
  static let heatHot = Color(red: 0.839, green: 0.298, blue: 0.180)

  var body: some View {
    switch family {
    case .systemSmall: small
    case .systemMedium: medium
    default: medium
    }
  }

  // 2x2
  var small: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text("KLARIS").font(.system(size: 9, weight: .heavy)).tracking(1.2).foregroundColor(KlarisWidgetView.mutedFg)
        Spacer()
        Circle().fill(KlarisWidgetView.success).frame(width: 6, height: 6)
      }
      Spacer()
      Text("\(entry.snapshot.hot)")
        .font(.system(size: 44, weight: .black, design: .monospaced))
        .foregroundColor(KlarisWidgetView.heatHot)
      Text("CHAUDS 🔥")
        .font(.system(size: 9, weight: .heavy)).tracking(1.0)
        .foregroundColor(KlarisWidgetView.mutedFg)
      Text("\(entry.snapshot.total) total")
        .font(.system(size: 11, design: .monospaced))
        .foregroundColor(KlarisWidgetView.mutedFg)
    }
    .padding(14)
    .containerBackground(KlarisWidgetView.bg, for: .widget)
  }

  // 4x2
  var medium: some View {
    HStack(spacing: 14) {
      VStack(alignment: .leading, spacing: 4) {
        Text("KLARIS").font(.system(size: 9, weight: .heavy)).tracking(1.2).foregroundColor(KlarisWidgetView.mutedFg)
        Spacer()
        Text("\(entry.snapshot.hot)")
          .font(.system(size: 36, weight: .black, design: .monospaced))
          .foregroundColor(KlarisWidgetView.heatHot)
        Text("CHAUDS 🔥")
          .font(.system(size: 9, weight: .heavy)).tracking(1.0)
          .foregroundColor(KlarisWidgetView.mutedFg)
      }
      .frame(width: 80)
      VStack(alignment: .leading, spacing: 4) {
        ForEach(entry.snapshot.leads.prefix(3)) { l in
          HStack(spacing: 8) {
            Circle().fill(scoreColor(l.score)).frame(width: 7, height: 7)
            Text(l.nom ?? "—")
              .font(.system(size: 13, weight: .semibold))
              .foregroundColor(.white)
              .lineLimit(1)
            Spacer()
            Text("\(l.score)")
              .font(.system(size: 11, weight: .heavy, design: .monospaced))
              .foregroundColor(scoreColor(l.score))
          }
        }
        Spacer()
      }
    }
    .padding(14)
    .containerBackground(KlarisWidgetView.bg, for: .widget)
  }

  private func scoreColor(_ s: Int) -> Color {
    if s >= 7 { return KlarisWidgetView.heatHot }
    if s >= 4 { return Color(red: 0.878, green: 0.659, blue: 0.212) }
    return Color(red: 0.435, green: 0.631, blue: 0.847)
  }
}

@main
struct KlarisWidget: Widget {
  let kind = "KlarisWidget"
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: KlarisProvider()) { entry in
      KlarisWidgetView(entry: entry)
    }
    .configurationDisplayName("Klaris")
    .description("Tes prospects chauds, en un coup d'œil.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
