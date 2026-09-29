import SwiftUI

struct StartTrackView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var petak = ""
    @State private var plot = ""
    @State private var kegiatan = "Survey"
    @State private var notes = ""

    let onStart: (String, TrackSurveyMetadata) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Track") {
                    TextField("Nama track", text: $name)
                    TextField("Kegiatan", text: $kegiatan)
                }

                Section("Atribut Survey") {
                    TextField("Petak, contoh 34195", text: $petak)
                    TextField("Plot, contoh Plot 03", text: $plot)
                    TextField("Catatan", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section {
                    Label("Track dapat tetap direkam saat Forest Maps berada di background atau layar iPhone dikunci.", systemImage: "lock.iphone")
                    Text("Untuk hasil terbaik, izinkan akses lokasi 'Always' saat iOS meminta izin. Memaksa menutup aplikasi dari app switcher dapat menghentikan tracking background.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Mulai Track Survey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Mulai") {
                        let metadata = TrackSurveyMetadata(
                            petak: petak.trimmingCharacters(in: .whitespacesAndNewlines),
                            plot: plot.trimmingCharacters(in: .whitespacesAndNewlines),
                            kegiatan: kegiatan.trimmingCharacters(in: .whitespacesAndNewlines),
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        onStart(name, metadata)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
