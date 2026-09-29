import SwiftUI
import CoreLocation

struct WaypointsListView: View {
    @EnvironmentObject private var waypointStore: WaypointStore
    @EnvironmentObject private var locationService: LocationService

    var body: some View {
        NavigationStack {
            List {
                if waypointStore.waypoints.isEmpty {
                    ContentUnavailableView("Belum Ada Waypoint", systemImage: "mappin.and.ellipse", description: Text("Buka peta, aktifkan GPS, lalu tekan tombol tambah waypoint."))
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button { locationService.requestAndStart() } label: { Image(systemName: "location.fill") }
                }
            }
        }
    }
}
