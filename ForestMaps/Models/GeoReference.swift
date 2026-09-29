import Foundation
import CoreGraphics

struct GeoReference: Equatable {
    /// GPTS order from ArcGIS GeoPDF: TL, BL, BR, TR as (lat, lon)
    let topLeft: CLLocationCoordinate2DValue
    let bottomLeft: CLLocationCoordinate2DValue
    let bottomRight: CLLocationCoordinate2DValue
    let topRight: CLLocationCoordinate2DValue

    /// PDF viewport coordinates [xLeft, yTop, xRight, yBottom]
    let viewport: CGRectGeoViewport
    let coordinateSystemWKT: String?

    var minLatitude: Double { min(topLeft.latitude, bottomLeft.latitude, bottomRight.latitude, topRight.latitude) }
    var maxLatitude: Double { max(topLeft.latitude, bottomLeft.latitude, bottomRight.latitude, topRight.latitude) }
    var minLongitude: Double { min(topLeft.longitude, bottomLeft.longitude, bottomRight.longitude, topRight.longitude) }
    var maxLongitude: Double { max(topLeft.longitude, bottomLeft.longitude, bottomRight.longitude, topRight.longitude) }

    func contains(latitude: Double, longitude: Double) -> Bool {
        latitude >= minLatitude && latitude <= maxLatitude && longitude >= minLongitude && longitude <= maxLongitude
    }

    /// Suitable for the near-rectangular UTM map frames exported by ArcGIS.
    func pdfPoint(latitude: Double, longitude: Double) -> CGPoint {
        let u = (longitude - minLongitude) / max(0.000000001, maxLongitude - minLongitude)
        let v = (latitude - minLatitude) / max(0.000000001, maxLatitude - minLatitude)

        let x = viewport.xLeft + u * (viewport.xRight - viewport.xLeft)
        let y = viewport.yBottom + v * (viewport.yTop - viewport.yBottom)
        return CGPoint(x: x, y: y)
    }
}

struct CLLocationCoordinate2DValue: Equatable {
    let latitude: Double
    let longitude: Double
}

struct CGRectGeoViewport: Equatable {
    let xLeft: Double
    let yTop: Double
    let xRight: Double
    let yBottom: Double
}
