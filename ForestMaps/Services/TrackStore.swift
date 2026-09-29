import Foundation
import CoreLocation

@MainActor
final class TrackStore: ObservableObject {
    @Published private(set) var tracks: [GPSTrack] = []
    @Published private(set) var activeTrack: GPSTrack?
    @Published private(set) var recoveredActiveTrack = false
    @Published var isRecording = false

    private let fileURL: URL
    private let activeFileURL: URL
    private var lastAcceptedLocation: CLLocation?

    init() {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = base.appendingPathComponent("gps-tracks.json")
        activeFileURL = base.appendingPathComponent("active-gps-track.json")
        load()
        restoreActiveTrack()
    }

    func start(name: String? = nil, survey: TrackSurveyMetadata = .init()) {
        guard !isRecording else { return }
        let fallback = "Track \(Date().formatted(date: .abbreviated, time: .shortened))"
        let cleanName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        activeTrack = GPSTrack(name: cleanName.isEmpty ? fallback : cleanName, survey: survey)
        lastAcceptedLocation = nil
        recoveredActiveTrack = false
        isRecording = true
        persistActive()
    }

    func append(_ location: CLLocation) {
        guard isRecording, var track = activeTrack else { return }
        guard location.horizontalAccuracy >= 0, location.horizontalAccuracy <= 50 else { return }

        if let last = lastAcceptedLocation {
            let moved = location.distance(from: last)
            let elapsed = location.timestamp.timeIntervalSince(last.timestamp)
            if moved < 2 && elapsed < 5 { return }
        }

        track.points.append(TrackPoint(location: location))
        activeTrack = track
        lastAcceptedLocation = location
        persistActive()
    }

    func stop(save: Bool = true, name: String? = nil) {
        guard var track = activeTrack else { return }
        track.endedAt = Date()
        if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            track.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if save, track.points.count >= 2 {
            tracks.insert(track, at: 0)
            persist()
        }
        activeTrack = nil
        lastAcceptedLocation = nil
        recoveredActiveTrack = false
        isRecording = false
        try? FileManager.default.removeItem(at: activeFileURL)
    }

    func discardActive() {
        activeTrack = nil
        lastAcceptedLocation = nil
        recoveredActiveTrack = false
        isRecording = false
        try? FileManager.default.removeItem(at: activeFileURL)
    }

    func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        persist()
    }

    func rename(_ track: GPSTrack, to newName: String) {
        guard let idx = tracks.firstIndex(where: { $0.id == track.id }) else { return }
        let clean = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        tracks[idx].name = clean
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([GPSTrack].self, from: data) else { return }
        tracks = decoded
    }

    private func restoreActiveTrack() {
        guard let data = try? Data(contentsOf: activeFileURL),
              let decoded = try? JSONDecoder().decode(GPSTrack.self, from: data) else { return }
        activeTrack = decoded
        isRecording = true
        recoveredActiveTrack = true
        if let last = decoded.points.last {
            lastAcceptedLocation = CLLocation(
                coordinate: last.coordinate,
                altitude: last.altitude,
                horizontalAccuracy: last.horizontalAccuracy,
                verticalAccuracy: -1,
                timestamp: last.timestamp
            )
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(tracks) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }

    private func persistActive() {
        guard let activeTrack,
              let data = try? JSONEncoder().encode(activeTrack) else { return }
        try? data.write(to: activeFileURL, options: [.atomic])
    }
}
