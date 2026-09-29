import Foundation

struct TrackKMLService {
    static func exportKML(track: GPSTrack) throws -> URL {
        let safeName = track.name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).kml")
        let coords = track.points.map { point in
            "\(point.longitude),\(point.latitude),\(point.altitude)"
        }.joined(separator: " ")
        let escapedName = xmlEscape(track.name)
        let survey = track.survey
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(escapedName)</name>
            <Placemark>
              <name>\(escapedName)</name>
              <ExtendedData>
                <Data name="Petak"><value>\(xmlEscape(survey.petak))</value></Data>
                <Data name="Plot"><value>\(xmlEscape(survey.plot))</value></Data>
                <Data name="Kegiatan"><value>\(xmlEscape(survey.kegiatan))</value></Data>
                <Data name="Catatan"><value>\(xmlEscape(survey.notes))</value></Data>
                <Data name="Mulai"><value>\(track.startedAt.ISO8601Format())</value></Data>
                <Data name="Selesai"><value>\((track.endedAt ?? Date()).ISO8601Format())</value></Data>
                <Data name="JarakMeter"><value>\(String(format: "%.2f", track.distanceMeters))</value></Data>
              </ExtendedData>
              <LineString>
                <tessellate>1</tessellate>
                <altitudeMode>clampToGround</altitudeMode>
                <coordinates>\(coords)</coordinates>
              </LineString>
            </Placemark>
          </Document>
        </kml>
        """
        guard let data = xml.data(using: .utf8) else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }
        try data.write(to: url, options: [.atomic])
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
