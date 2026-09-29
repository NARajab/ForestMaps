import Foundation
import CoreLocation

struct TrackPoint: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let horizontalAccuracy: Double
    let timestamp: Date

    init(location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        altitude = location.altitude
        horizontalAccuracy = location.horizontalAccuracy
        timestamp = location.timestamp
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct GPSTrack: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    let startedAt: Date
    var endedAt: Date?
    var points: [TrackPoint]

    init(id: UUID = UUID(), name: String, startedAt: Date = Date(), endedAt: Date? = nil, points: [TrackPoint] = []) {
        self.id = id
        self.name = name
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.points = points
    }

    var duration: TimeInterval {
        (endedAt ?? Date()).timeIntervalSince(startedAt)
    }

    var distanceMeters: Double {
        guard points.count > 1 else { return 0 }
        var total: Double = 0
        for pair in zip(points, points.dropFirst()) {
            let a = CLLocation(latitude: pair.0.latitude, longitude: pair.0.longitude)
            let b = CLLocation(latitude: pair.1.latitude, longitude: pair.1.longitude)
            total += a.distance(from: b)
        }
        return total
    }
}
