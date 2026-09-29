import Foundation
import CoreLocation

struct Waypoint: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var petak: String
    var plot: String
    var notes: String
    var latitude: Double
    var longitude: Double
    var createdAt: Date

    init(id: UUID = UUID(), name: String, petak: String = "", plot: String = "", notes: String = "", latitude: Double, longitude: Double, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.petak = petak
        self.plot = plot
        self.notes = notes
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
