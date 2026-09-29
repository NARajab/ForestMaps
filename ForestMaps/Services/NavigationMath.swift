import Foundation
import CoreLocation

enum NavigationMath {
    static func distanceMeters(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: from.latitude, longitude: from.longitude)
            .distance(from: CLLocation(latitude: to.latitude, longitude: to.longitude))
    }

    static func bearingDegrees(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let degrees = atan2(y, x) * 180 / .pi
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }

    static func cardinal(_ bearing: Double) -> String {
        let names = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((bearing + 22.5) / 45.0) % 8
        return names[index]
    }
}

extension NavigationMath {
    static func polylineDistanceMeters(_ coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count >= 2 else { return 0 }
        return zip(coordinates, coordinates.dropFirst()).reduce(0) { partial, pair in
            partial + distanceMeters(from: pair.0, to: pair.1)
        }
    }

    /// Area on a local tangent plane. Accurate enough for field polygons spanning a few kilometres.
    static func polygonAreaSquareMeters(_ coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count >= 3 else { return 0 }

        let earthRadius = 6_378_137.0
        let originLat = coordinates.map(\.latitude).reduce(0, +) / Double(coordinates.count)
        let originLon = coordinates.map(\.longitude).reduce(0, +) / Double(coordinates.count)
        let lat0 = originLat * .pi / 180

        let points: [(x: Double, y: Double)] = coordinates.map { coordinate in
            let x = (coordinate.longitude - originLon) * .pi / 180 * earthRadius * cos(lat0)
            let y = (coordinate.latitude - originLat) * .pi / 180 * earthRadius
            return (x, y)
        }

        var twiceArea = 0.0
        for i in points.indices {
            let j = (i + 1) % points.count
            twiceArea += points[i].x * points[j].y - points[j].x * points[i].y
        }
        return abs(twiceArea) / 2
    }
}
