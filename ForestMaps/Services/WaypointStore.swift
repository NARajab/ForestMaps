import Foundation

@MainActor
final class WaypointStore: ObservableObject {
    @Published private(set) var waypoints: [Waypoint] = []

    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("waypoints.json")
        load()
    }

    func add(_ waypoint: Waypoint) {
        waypoints.append(waypoint)
        waypoints.sort { $0.createdAt > $1.createdAt }
        save()
    }

    func addMany(_ imported: [Waypoint]) {
        guard !imported.isEmpty else { return }
        waypoints.append(contentsOf: imported)
        waypoints.sort { $0.createdAt > $1.createdAt }
        save()
    }

    func update(_ waypoint: Waypoint) {
        guard let index = waypoints.firstIndex(where: { $0.id == waypoint.id }) else { return }
        waypoints[index] = waypoint
        save()
    }

    func delete(_ waypoint: Waypoint) {
        waypoints.removeAll { $0.id == waypoint.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        waypoints.remove(atOffsets: offsets)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([Waypoint].self, from: data) {
            waypoints = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(waypoints) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
