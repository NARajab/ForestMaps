import SwiftUI
import CoreLocation

struct WaypointDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let waypoint: Waypoint
    let currentLocation: CLLocation?
    let onNavigate: (Waypoint) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Waypoint") {
                    LabeledContent("Nama", value: waypoint.name)
                    if !waypoint.petak.isEmpty {
                        LabeledContent("Petak", value: waypoint.petak)
                    }
                    if !waypoint.plot.isEmpty {
                        LabeledContent("Plot", value: waypoint.plot)
                    }
                    if !waypoint.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Catatan")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(waypoint.notes)
                        }
                    }
                }

                Section("Koordinat") {
                    LabeledContent("Latitude", value: String(format: "%.7f", waypoint.latitude))
                    LabeledContent("Longitude", value: String(format: "%.7f", waypoint.longitude))
                }

                if let currentLocation {
                    let distance = NavigationMath.distanceMeters(from: currentLocation.coordinate, to: waypoint.coordinate)
                    let bearing = NavigationMath.bearingDegrees(from: currentLocation.coordinate, to: waypoint.coordinate)
                    Section("Dari Posisi Saya") {
                        LabeledContent("Jarak", value: distanceText(distance))
                        LabeledContent("Bearing", value: String(format: "%.0f° %@", bearing, NavigationMath.cardinal(bearing)))
                    }
                }

                Section {
                    Button {
                        onNavigate(waypoint)
                        dismiss()
                    } label: {
                        Label("Navigasi ke Titik", systemImage: "location.north.line.fill")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Detail Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }

    private func distanceText(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000)
        }
        return String(format: "%.0f m", meters)
    }
}
