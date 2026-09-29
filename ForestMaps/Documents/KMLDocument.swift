import SwiftUI
import UniformTypeIdentifiers

struct KMLDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.kml] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
