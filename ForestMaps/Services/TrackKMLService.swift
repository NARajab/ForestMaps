import Foundation

struct TrackKMLService {
    static func exportKML(track: GPSTrack) throws -> URL {
        let safeName = track.name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).kml")
        let coords = track.points.map { point in
            "\(point.longitude),\(point.latitude),\(point.altitude)"
        }.joined(separator: " ")
        let escapedName = xmlEscape(track.name)
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(escapedName)</name>
            <Placemark>
              <name>\(escapedName)</name>
              <LineString>
                <tessellate>1</tessellate>
                <altitudeMode>clampToGround</altitudeMode>
                <coordinates>\(coords)</coordinates>
              </LineString>
            </Placemark>
          </Document>
        </kml>
        """
        try xml.data(using: .utf8)?.write(to: url, options: [.atomic])
        return url
    }

    private static func xmlEscape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
