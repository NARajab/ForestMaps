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

struct TrackSurveyMetadata: Codable, Hashable {
    var petak: String = ""
    var plot: String = ""
    var kegiatan: String = ""
    var notes: String = ""

    var isEmpty: Bool {
        [petak, plot, kegiatan, notes].allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}

struct GPSTrack: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    let startedAt: Date
    var endedAt: Date?
    var points: [TrackPoint]
    var survey: TrackSurveyMetadata

    init(
        id: UUID = UUID(),
        name: String,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        points: [TrackPoint] = [],
        survey: TrackSurveyMetadata = .init()
    ) {
        self.id = id
        self.name = name
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.points = points
        self.survey = survey
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, startedAt, endedAt, points, survey
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        endedAt = try container.decodeIfPresent(Date.self, forKey: .endedAt)
        points = try container.decodeIfPresent([TrackPoint].self, forKey: .points) ?? []
        survey = try container.decodeIfPresent(TrackSurveyMetadata.self, forKey: .survey) ?? .init()
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
