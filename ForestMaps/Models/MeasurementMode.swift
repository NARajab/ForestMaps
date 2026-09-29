import Foundation

enum MeasurementMode: String, CaseIterable, Identifiable {
    case none
    case distance
    case area

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: return "Selesai"
        case .distance: return "Jarak"
        case .area: return "Luas"
        }
    }

    var systemImage: String {
        switch self {
        case .none: return "xmark"
        case .distance: return "ruler"
        case .area: return "square.dashed"
        }
    }
}
