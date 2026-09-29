import Foundation
import UniformTypeIdentifiers
import ZIPFoundation

extension UTType {
    static let kml = UTType(importedAs: "com.google.earth.kml")
    static let kmz = UTType(importedAs: "com.google.earth.kmz")
}

enum KMLServiceError: LocalizedError {
    case noKMLInKMZ
    case invalidKML
    case unsupportedFile

    var errorDescription: String? {
        switch self {
        case .noKMLInKMZ: return "File KMZ tidak berisi file KML."
        case .invalidKML: return "KML tidak dapat dibaca atau tidak memiliki waypoint Point yang valid."
        case .unsupportedFile: return "Format file belum didukung. Gunakan KML atau KMZ."
        }
    }
}

struct KMLService {
    static func importWaypoints(from url: URL) throws -> [Waypoint] {
        let ext = url.pathExtension.lowercased()
        let data: Data

        switch ext {
        case "kml":
            data = try Data(contentsOf: url)
        case "kmz":
            data = try kmlDataFromKMZ(url)
        default:
            throw KMLServiceError.unsupportedFile
        }

        let parser = WaypointKMLParser(data: data)
        let items = parser.parse()
        guard !items.isEmpty else { throw KMLServiceError.invalidKML }
        return items
    }

    static func exportKML(waypoints: [Waypoint]) -> Data {
        func esc(_ s: String) -> String {
            s.replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
                .replacingOccurrences(of: "\"", with: "&quot;")
                .replacingOccurrences(of: "'", with: "&apos;")
        }

        let placemarks = waypoints.map { w in
            """
            <Placemark>
              <name>\(esc(w.name))</name>
              <description>\(esc(w.notes))</description>
              <ExtendedData>
                <Data name="petak"><value>\(esc(w.petak))</value></Data>
                <Data name="plot"><value>\(esc(w.plot))</value></Data>
                <Data name="notes"><value>\(esc(w.notes))</value></Data>
              </ExtendedData>
              <Point><coordinates>\(w.longitude),\(w.latitude),0</coordinates></Point>
            </Placemark>
            """
        }.joined(separator: "\n")

        let text = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>Forest Maps Waypoints</name>
            \(placemarks)
          </Document>
        </kml>
        """
        return Data(text.utf8)
    }

    static func exportKMZ(waypoints: [Waypoint]) throws -> URL {
        let fm = FileManager.default
        let folder = fm.temporaryDirectory.appendingPathComponent("ForestMaps-KMZ-\(UUID().uuidString)", isDirectory: true)
        try fm.createDirectory(at: folder, withIntermediateDirectories: true)
        let kmlURL = folder.appendingPathComponent("doc.kml")
        try exportKML(waypoints: waypoints).write(to: kmlURL, options: .atomic)

        let output = fm.temporaryDirectory.appendingPathComponent("ForestMaps-Waypoints-\(UUID().uuidString).kmz")
        let archive = try Archive(url: output, accessMode: .create)
        try archive.addEntry(with: "doc.kml", relativeTo: folder)
        return output
    }

    private static func kmlDataFromKMZ(_ url: URL) throws -> Data {
        let archive = try Archive(url: url, accessMode: .read)
        guard let entry = archive.first(where: { $0.path.lowercased().hasSuffix(".kml") }) else {
            throw KMLServiceError.noKMLInKMZ
        }

        var data = Data()
        _ = try archive.extract(entry) { chunk in
            data.append(chunk)
        }
        return data
    }
}

private final class WaypointKMLParser: NSObject, XMLParserDelegate {
    private let data: Data
    private var results: [Waypoint] = []
    private var currentElement = ""
    private var text = ""
    private var inPlacemark = false
    private var currentName = ""
    private var currentDescription = ""
    private var currentCoordinates = ""
    private var currentDataName: String?
    private var extendedValues: [String: String] = [:]

    init(data: Data) { self.data = data }

    func parse() -> [Waypoint] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return results
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        text = ""
        if elementName == "Placemark" {
            inPlacemark = true
            currentName = ""
            currentDescription = ""
            currentCoordinates = ""
            extendedValues = [:]
        }
        if elementName == "Data" {
            currentDataName = attributeDict["name"]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard inPlacemark else { return }
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)

        switch elementName {
        case "name":
            if currentName.isEmpty { currentName = value }
        case "description":
            currentDescription = value
        case "coordinates":
            currentCoordinates = value
        case "value":
            if let key = currentDataName { extendedValues[key] = value }
        case "Data":
            currentDataName = nil
        case "Placemark":
            if let point = Self.parsePoint(currentCoordinates) {
                results.append(Waypoint(
                    name: currentName.isEmpty ? "Imported Point" : currentName,
                    petak: extendedValues["petak"] ?? "",
                    plot: extendedValues["plot"] ?? "",
                    notes: extendedValues["notes"] ?? currentDescription,
                    latitude: point.latitude,
                    longitude: point.longitude
                ))
            }
            inPlacemark = false
        default:
            break
        }
        text = ""
    }

    private static func parsePoint(_ coordinateText: String) -> (latitude: Double, longitude: Double)? {
        guard let token = coordinateText
            .split(whereSeparator: { $0.isWhitespace })
            .first else { return nil }
        let parts = token.split(separator: ",")
        guard parts.count >= 2,
              let lon = Double(parts[0]),
              let lat = Double(parts[1]),
              (-180...180).contains(lon),
              (-90...90).contains(lat) else { return nil }
        return (lat, lon)
    }
}
