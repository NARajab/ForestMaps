import Foundation

struct OfflineMap: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var fileName: String
    var importedAt: Date

    init(id: UUID = UUID(), name: String, fileName: String, importedAt: Date = .now) {
        self.id = id
        self.name = name
        self.fileName = fileName
        self.importedAt = importedAt
    }
}
