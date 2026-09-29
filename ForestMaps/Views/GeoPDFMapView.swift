import SwiftUI
import CoreLocation

struct GeoPDFMapView: View {
    @EnvironmentObject private var store: MapStore
    @EnvironmentObject private var locationService: LocationService
    let map: OfflineMap

    @State private var geo: GeoReference?
    @State private var parseError: String?
    @State private var recenterToken = 0

    private var mapURL: URL { store.url(for: map) }

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitMapRepresentable(url: mapURL, geoReference: geo, location: locationService.location, recenterToken: recenterToken)
                .ignoresSafeArea(edges: .bottom)

            statusCard
                .padding()
        }
        .navigationTitle(map.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { locationService.requestAndStart() } label: { Image(systemName: "location.fill") }
                Button { recenterToken += 1 } label: { Image(systemName: "scope") }
            }
        }
        .task { loadGeoReference() }
        .onDisappear { locationService.stop() }
        .alert("GeoPDF", isPresented: Binding(get: { parseError != nil }, set: { if !$0 { parseError = nil } })) {
            Button("OK", role: .cancel) { parseError = nil }
        } message: { Text(parseError ?? "") }
    }

    @ViewBuilder
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(geo == nil ? "Membaca GeoPDF…" : "GeoPDF aktif", systemImage: geo == nil ? "hourglass" : "checkmark.seal.fill")
                Spacer()
                Text("OFFLINE").font(.caption.bold()).foregroundStyle(.green)
            }

            if let loc = locationService.location {
                HStack(spacing: 16) {
                    Text(String(format: "Lat %.6f", loc.coordinate.latitude))
                    Text(String(format: "Lon %.6f", loc.coordinate.longitude))
                }.font(.caption.monospacedDigit())

                HStack {
                    Text(String(format: "Akurasi ±%.0f m", max(0, loc.horizontalAccuracy)))
                    Spacer()
                    if let geo {
                        Text(geo.contains(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude) ? "Di dalam peta" : "Di luar cakupan peta")
                    }
                }.font(.caption2).foregroundStyle(.secondary)
            } else {
                Text("Tekan tombol lokasi untuk menampilkan GPS di atas peta.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func loadGeoReference() {
        do { geo = try GeoPDFParser().parse(url: mapURL) }
        catch { parseError = error.localizedDescription }
    }
}
