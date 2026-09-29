import SwiftUI
import CoreLocation

struct WaypointPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var waypointStore: WaypointStore
    let currentLocation: CLLocation?
    let selected: Waypoint?
    let onSelect: (Waypoint?) -> Void

    var body: some View {
        NavigationStack {
            List {
                if let selected {
                    Section {
                        Button(role: .destructive) {
                            onSelect(nil)
                            dismiss()
                        } label: {
                            Label("Hentikan navigasi ke \(selected.name)", systemImage: "xmark.circle")
                        }
                    }
                }

                Section("Waypoint Offline") {
                    if waypointStore.waypoints.isEmpty {
                        Text("Belum ada waypoint. Simpan posisi GPS dari halaman peta.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(waypointStore.waypoints) { waypoint in
                        Button {
                            onSelect(waypoint)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(waypoint.name).font(.headline)
                                    if !waypoint.petak.isEmpty || !waypoint.plot.isEmpty {
                                        Text("Petak \(waypoint.petak) • Plot \(waypoint.plot)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(String(format: "%.6f, %.6f", waypoint.latitude, waypoint.longitude))
                                        .font(.caption2.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if let currentLocation {
                                    let d = NavigationMath.distanceMeters(from: currentLocation.coordinate, to: waypoint.coordinate)
                                    Text(d >= 1000 ? String(format: "%.2f km", d / 1000) : String(format: "%.0f m", d))
                                        .font(.caption.bold())
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Pilih Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
}
