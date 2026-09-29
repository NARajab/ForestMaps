import SwiftUI
import CoreLocation
import UniformTypeIdentifiers

struct WaypointsListView: View {
    @EnvironmentObject private var waypointStore: WaypointStore
    @EnvironmentObject private var locationService: LocationService

    @State private var showImporter = false
    @State private var showKMLExporter = false
    @State private var kmlDocument = KMLDocument(data: Data())
    @State private var statusMessage: String?
    @State private var exportKMZURL: URL?
    @State private var showKMZShare = false

    var body: some View {
        NavigationStack {
            List {
                if let statusMessage {
                    Section {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if waypointStore.waypoints.isEmpty {
                    ContentUnavailableView("Belum Ada Waypoint", systemImage: "mappin.and.ellipse", description: Text("Tambahkan waypoint dari GPS atau import KML/KMZ dari QGIS."))
                } else {
                    ForEach(waypointStore.waypoints) { waypoint in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(waypoint.name).font(.headline)
                            if !waypoint.petak.isEmpty || !waypoint.plot.isEmpty {
                                Text("Petak \(waypoint.petak) • Plot \(waypoint.plot)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(String(format: "%.6f, %.6f", waypoint.latitude, waypoint.longitude))
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.secondary)
                            if let location = locationService.location {
                                let d = NavigationMath.distanceMeters(from: location.coordinate, to: waypoint.coordinate)
                                Text(d >= 1000 ? String(format: "Jarak %.2f km", d / 1000) : String(format: "Jarak %.0f m", d))
                                    .font(.caption.bold())
                            }
                        }
                        .padding(.vertical, 3)
                        .swipeActions {
                            Button(role: .destructive) { waypointStore.delete(waypoint) } label: {
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Waypoints")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showImporter = true
                        } label: {
                            Label("Import KML / KMZ", systemImage: "square.and.arrow.down")
                        }

                        Button {
                            kmlDocument = KMLDocument(data: KMLService.exportKML(waypoints: waypointStore.waypoints))
                            showKMLExporter = true
                        } label: {
                            Label("Export KML", systemImage: "doc.badge.arrow.up")
                        }
                        .disabled(waypointStore.waypoints.isEmpty)

                        Button {
                            do {
                                exportKMZURL = try KMLService.exportKMZ(waypoints: waypointStore.waypoints)
                                showKMZShare = exportKMZURL != nil
                            } catch {
                                statusMessage = "Export KMZ gagal: \(error.localizedDescription)"
                            }
                        } label: {
                            Label("Export KMZ", systemImage: "archivebox")
                        }
                        .disabled(waypointStore.waypoints.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                    Button { locationService.requestAndStart() } label: { Image(systemName: "location.fill") }
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.kml, .kmz], allowsMultipleSelection: false) { result in
                do {
                    guard let url = try result.get().first else { return }
                    let accessed = url.startAccessingSecurityScopedResource()
                    defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                    let imported = try KMLService.importWaypoints(from: url)
                    waypointStore.addMany(imported)
                    statusMessage = "Berhasil import \(imported.count) waypoint dari \(url.lastPathComponent)."
                } catch {
                    statusMessage = "Import gagal: \(error.localizedDescription)"
                }
            }
            .fileExporter(isPresented: $showKMLExporter, document: kmlDocument, contentType: .kml, defaultFilename: "ForestMaps-Waypoints.kml") { result in
                switch result {
                case .success:
                    statusMessage = "KML berhasil diekspor."
                case .failure(let error):
                    statusMessage = "Export KML gagal: \(error.localizedDescription)"
                }
            }
            .sheet(isPresented: $showKMZShare) {
                if let exportKMZURL {
                    ShareSheet(items: [exportKMZURL])
                }
            }
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
