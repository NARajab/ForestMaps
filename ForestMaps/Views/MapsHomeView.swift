import SwiftUI
import UniformTypeIdentifiers

struct MapsHomeView: View {
    @EnvironmentObject private var store: MapStore
    @State private var showingImporter = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, Color(red: 0.06, green: 0.14, blue: 0.10)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                if store.maps.isEmpty {
                    ContentUnavailableView {
                        Label("Belum Ada Peta", systemImage: "map")
                    } description: {
                        Text("Import GeoPDF dari Files atau buka sample peta perusahaan yang sudah disertakan.")
                    } actions: {
                        VStack(spacing: 12) {
                            Button("Import GeoPDF") { showingImporter = true }
                                .buttonStyle(.borderedProminent)
                            Button("Pasang Sample Agustus 2026") { installSample() }
                                .buttonStyle(.bordered)
                        }
                    }
                } else {
                    List {
                        Section("MY MAPS — OFFLINE") {
                            ForEach(store.maps) { map in
                                NavigationLink(value: map) {
                                    HStack(spacing: 14) {
                                        Image(systemName: "map.fill")
                                            .font(.title2)
                                            .frame(width: 42, height: 42)
                                            .background(.green.opacity(0.16), in: RoundedRectangle(cornerRadius: 10))
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(map.name).font(.headline)
                                            Text("Tersimpan offline • \(map.importedAt.formatted(date: .abbreviated, time: .shortened))")
                                                .font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .swipeActions {
                                    Button(role: .destructive) { store.delete(map) } label: { Label("Hapus", systemImage: "trash") }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Forest Maps")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingImporter = true } label: { Image(systemName: "plus") }
                }
            }
            .navigationDestination(for: OfflineMap.self) { map in
                GeoPDFMapView(map: map)
            }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    do { try store.importPDF(from: url) }
                    catch { message = error.localizedDescription }
                case .failure(let error): message = error.localizedDescription
                }
            }
            .alert("Forest Maps", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
                Button("OK", role: .cancel) { message = nil }
            } message: { Text(message ?? "") }
        }
    }

    private func installSample() {
        do { try store.importBundledSample() }
        catch { message = error.localizedDescription }
    }
}
