import SwiftUI

@main
struct ForestMapsApp: App {
    @StateObject private var mapStore = MapStore()
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            MapsHomeView()
                .environmentObject(mapStore)
                .environmentObject(locationService)
                .preferredColorScheme(.dark)
        }
    }
}
