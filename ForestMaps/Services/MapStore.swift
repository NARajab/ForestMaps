import Foundation

@MainActor
final class MapStore: ObservableObject {
    @Published private(set) var maps: [OfflineMap] = []
    @Published var lastError: String?

    private let fm = FileManager.default
    private let indexFileName = "maps-index.json"

    init() {
        try? fm.createDirectory(at: mapsDirectory, withIntermediateDirectories: true)
        loadIndex()
    }

    var mapsDirectory: URL {
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("OfflineMaps", isDirectory: true)
    }

    func url(for map: OfflineMap) -> URL {
        mapsDirectory.appendingPathComponent(map.fileName)
    }

    func importPDF(from sourceURL: URL) throws {
        let didAccess = sourceURL.startAccessingSecurityScopedResource()
        defer { if didAccess { sourceURL.stopAccessingSecurityScopedResource() } }

        let base = sourceURL.deletingPathExtension().lastPathComponent
        let storedName = uniqueFileName(base: base, ext: "pdf")
        let destination = mapsDirectory.appendingPathComponent(storedName)
        try fm.copyItem(at: sourceURL, to: destination)

        // Validate before registering it as a map.
        _ = try GeoPDFParser().parse(url: destination)

        maps.insert(OfflineMap(name: base, fileName: storedName), at: 0)
        saveIndex()
    }

    func importBundledSample() throws {
        guard let url = Bundle.main.url(forResource: "Peta Upd Agustus 2026", withExtension: "pdf", subdirectory: "SampleData")
                ?? Bundle.main.url(forResource: "Peta Upd Agustus 2026", withExtension: "pdf") else {
            throw NSError(domain: "ForestMaps", code: 404, userInfo: [NSLocalizedDescriptionKey: "Sample GeoPDF tidak ditemukan di bundle aplikasi."])
        }
        try importPDF(from: url)
    }

    func delete(_ map: OfflineMap) {
        try? fm.removeItem(at: url(for: map))
        maps.removeAll { $0.id == map.id }
        saveIndex()
    }

    private func uniqueFileName(base: String, ext: String) -> String {
        let clean = base.replacingOccurrences(of: "/", with: "-")
        var candidate = "\(clean).\(ext)"
        var n = 2
        while fm.fileExists(atPath: mapsDirectory.appendingPathComponent(candidate).path) {
            candidate = "\(clean)-\(n).\(ext)"
            n += 1
        }
        return candidate
    }

    private func indexURL() -> URL { mapsDirectory.appendingPathComponent(indexFileName) }

    private func loadIndex() {
        guard let data = try? Data(contentsOf: indexURL()),
              let decoded = try? JSONDecoder().decode([OfflineMap].self, from: data) else { return }
        maps = decoded.filter { fm.fileExists(atPath: url(for: $0).path) }
    }

    private func saveIndex() {
        guard let data = try? JSONEncoder().encode(maps) else { return }
        try? data.write(to: indexURL(), options: .atomic)
    }
}
