import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            MapsHomeView()
                .tabItem { Label("Peta", systemImage: "map.fill") }
            WaypointsListView()
                .tabItem { Label("Waypoint", systemImage: "mappin.and.ellipse") }
        }
    }
}
