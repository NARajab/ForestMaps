import SwiftUI
import CoreLocation

struct AddWaypointView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var waypointStore: WaypointStore

    let coordinate: CLLocationCoordinate2D

    @State private var name = ""
    @State private var petak = ""
    @State private var plot = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Identitas") {
                    TextField("Nama titik, mis. Plot 01", text: $name)
                    TextField("Petak, mis. 34195", text: $petak)
                    TextField("Plot, mis. 01", text: $plot)
                }

                Section("Koordinat GPS") {
                    LabeledContent("Latitude", value: String(format: "%.7f", coordinate.latitude))
                    LabeledContent("Longitude", value: String(format: "%.7f", coordinate.longitude))
                }

                Section("Catatan") {
                    TextField("Catatan lapangan", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Simpan Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        waypointStore.add(Waypoint(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            petak: petak.trimmingCharacters(in: .whitespacesAndNewlines),
            plot: plot.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ))
        dismiss()
    }
}
