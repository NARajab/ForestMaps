import SwiftUI
import UIKit

struct TracksListView: View {
    @EnvironmentObject private var trackStore: TrackStore
    @State private var shareURL: URL?

    var body: some View {
        NavigationStack {
            Group {
                if trackStore.tracks.isEmpty {
                    ContentUnavailableView(
                        "Belum Ada Track",
                        systemImage: "figure.walk",
                        description: Text("Mulai merekam track dari layar peta. Track disimpan offline di iPhone.")
                    )
                } else {
                    List {
                        ForEach(trackStore.tracks) { track in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(track.name).font(.headline)
                                HStack(spacing: 12) {
                                    Label(formatDistance(track.distanceMeters), systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                                    Label(formatDuration(track.duration), systemImage: "clock")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                HStack {
                                    Text(track.startedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Button {
                                        shareURL = try? TrackKMLService.exportKML(track: track)
                                    } label: {
                                        Label("KML", systemImage: "square.and.arrow.up")
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.caption.bold())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: trackStore.delete)
                    }
                }
            }
            .navigationTitle("Track GPS")
            .sheet(item: Binding(
                get: { shareURL.map(ShareFile.init) },
                set: { if $0 == nil { shareURL = nil } }
            )) { file in
                ShareSheet(items: [file.url])
            }
        }
    }

    private func formatDistance(_ meters: Double) -> String {
        meters >= 1000 ? String(format: "%.2f km", meters / 1000) : String(format: "%.0f m", meters)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }
}

private struct ShareFile: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
