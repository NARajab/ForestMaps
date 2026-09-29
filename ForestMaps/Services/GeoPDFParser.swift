import Foundation

struct GeoPDFParser {
    enum ParseError: LocalizedError {
        case unreadable
        case missingGeoReference

        var errorDescription: String? {
            switch self {
            case .unreadable: return "File PDF tidak dapat dibaca."
            case .missingGeoReference: return "Georeferensi GeoPDF tidak ditemukan. Export ulang dari GIS dengan georeference aktif."
            }
        }
    }

    func parse(url: URL) throws -> GeoReference {
        let data = try Data(contentsOf: url)
        guard let raw = String(data: data, encoding: .isoLatin1) else { throw ParseError.unreadable }

        guard let gpts = captureNumbers(pattern: #"/GPTS\s*\[([^\]]+)\]"#, in: raw), gpts.count >= 8,
              let bbox = captureNumbers(pattern: #"/BBox\s*\[([^\]]+)\]"#, in: raw), bbox.count >= 4 else {
            throw ParseError.missingGeoReference
        }

        let wkt = captureString(pattern: #"/WKT\s*\((.*?)\)\s*>>"#, in: raw)

        return GeoReference(
            topLeft: .init(latitude: gpts[0], longitude: gpts[1]),
            bottomLeft: .init(latitude: gpts[2], longitude: gpts[3]),
            bottomRight: .init(latitude: gpts[4], longitude: gpts[5]),
            topRight: .init(latitude: gpts[6], longitude: gpts[7]),
            viewport: .init(xLeft: bbox[0], yTop: bbox[1], xRight: bbox[2], yBottom: bbox[3]),
            coordinateSystemWKT: wkt
        )
    }

    private func captureNumbers(pattern: String, in text: String) -> [Double]? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else { return nil }

        let content = String(text[range])
        let numberRegex = try! NSRegularExpression(pattern: #"[-+]?\d*\.?\d+(?:[Ee][-+]?\d+)?"#)
        let nsRange = NSRange(content.startIndex..., in: content)
        return numberRegex.matches(in: content, range: nsRange).compactMap { m in
            guard let r = Range(m.range, in: content) else { return nil }
            return Double(content[r])
        }
    }

    private func captureString(pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else { return nil }
        return String(text[range])
    }
}
