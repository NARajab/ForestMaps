import SwiftUI
import CoreLocation

struct GeoPDFMapView: View {
    @EnvironmentObject private var store: MapStore
    @EnvironmentObject private var waypointStore: WaypointStore
    @EnvironmentObject private var locationService: LocationService
    let map: OfflineMap

    @State private var geo: GeoReference?
    @State private var parseError: String?
    @State private var recenterToken = 0
    @State private var showingAddWaypoint = false
    @State private var showingWaypointPicker = false
    @State private var selectedWaypoint: Waypoint?

    private var mapURL: URL { store.url(for: map) }

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitMapRepresentable(
                url: mapURL,
                geoReference: geo,
                location: locationService.location,
                waypoints: waypointStore.waypoints,
                selectedWaypoint: selectedWaypoint,
                recenterToken: recenterToken
            )
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
                Button { if locationService.location != nil { showingAddWaypoint = true } } label: { Image(systemName: "mappin.and.ellipse") }
                    .disabled(locationService.location == nil)
                Button { showingWaypointPicker = true } label: { Image(systemName: "location.north.line.fill") }
            }
        }
        .task { loadGeoReference(); locationService.requestAndStart() }
        .onDisappear { locationService.stop() }
        .sheet(isPresented: $showingAddWaypoint) {
            if let coordinate = locationService.location?.coordinate {
                AddWaypointView(coordinate: coordinate)
                    .environmentObject(waypointStore)
            }
        }
        .sheet(isPresented: $showingWaypointPicker) {
            WaypointPickerView(currentLocation: locationService.location, selected: selectedWaypoint) { waypoint in
                selectedWaypoint = waypoint
            }
            .environmentObject(waypointStore)
        }
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

                if let selectedWaypoint {
                    Divider()
                    navigationRow(current: loc.coordinate, target: selectedWaypoint)
                }
            } else {
                Text("Aktifkan GPS untuk menampilkan posisi dan menyimpan waypoint.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func navigationRow(current: CLLocationCoordinate2D, target: Waypoint) -> some View {
        let distance = NavigationMath.distanceMeters(from: current, to: target.coordinate)
        let bearing = NavigationMath.bearingDegrees(from: current, to: target.coordinate)
        let heading = locationService.heading?.trueHeading ?? locationService.heading?.magneticHeading ?? 0
        let relative = bearing - heading
        return HStack(spacing: 12) {
            Image(systemName: "location.north.fill")
                .font(.title2)
                .rotationEffect(.degrees(relative))
                .frame(width: 34, height: 34)
                .background(.orange.opacity(0.18), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Menuju \(target.name)").font(.caption.bold())
                Text(distance >= 1000 ? String(format: "%.2f km • %.0f° %@", distance / 1000, bearing, NavigationMath.cardinal(bearing)) : String(format: "%.0f m • %.0f° %@", distance, bearing, NavigationMath.cardinal(bearing)))
                    .font(.caption.monospacedDigit())
            }
            Spacer()
            Button("Stop") { selectedWaypoint = nil }
                .font(.caption.bold())
        }
    }

    private func loadGeoReference() {
        do { geo = try GeoPDFParser().parse(url: mapURL) }
        catch { parseError = error.localizedDescription }
    }
}
