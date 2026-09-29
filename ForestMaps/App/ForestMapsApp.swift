import SwiftUI

@main
struct ForestMapsApp: App {
    @StateObject private var mapStore = MapStore()
    @StateObject private var waypointStore = WaypointStore()
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(mapStore)
                .environmentObject(waypointStore)
                .environmentObject(locationService)
                .preferredColorScheme(.dark)
        }
    }
}
