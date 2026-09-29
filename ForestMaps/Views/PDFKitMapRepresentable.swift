import SwiftUI
import PDFKit
import CoreLocation

struct PDFKitMapRepresentable: UIViewRepresentable {
    let url: URL
    let geoReference: GeoReference?
    let location: CLLocation?
    let waypoints: [Waypoint]
    let selectedWaypoint: Waypoint?
    let recenterToken: Int
    let onWaypointTapped: (Waypoint) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onWaypointTapped: onWaypointTapped)
    }

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .black
        view.document = PDFDocument(url: url)
        view.usePageViewController(false)
        context.coordinator.pdfView = view
        context.coordinator.installLocationMarker(on: view)
        return view
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        context.coordinator.onWaypointTapped = onWaypointTapped
        context.coordinator.updateLocationMarker(location: location, geo: geoReference)
        context.coordinator.updateWaypointMarkers(waypoints: waypoints, selected: selectedWaypoint, geo: geoReference)
        if context.coordinator.lastRecenterToken != recenterToken {
            context.coordinator.lastRecenterToken = recenterToken
            context.coordinator.centerOnLocationIfPossible()
        }
    }

    final class Coordinator: NSObject {
        weak var pdfView: PDFView?
        private let locationMarker = UIView()
        private var waypointMarkers: [UUID: WaypointMarkerButton] = [:]
        private var locationPointInView: CGPoint?
        var lastRecenterToken = 0
        var onWaypointTapped: (Waypoint) -> Void

        init(onWaypointTapped: @escaping (Waypoint) -> Void) {
            self.onWaypointTapped = onWaypointTapped
        }

        func installLocationMarker(on view: PDFView) {
            locationMarker.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
            locationMarker.layer.cornerRadius = 11
            locationMarker.backgroundColor = .systemBlue
            locationMarker.layer.borderWidth = 4
            locationMarker.layer.borderColor = UIColor.white.cgColor
            locationMarker.layer.shadowColor = UIColor.black.cgColor
            locationMarker.layer.shadowOpacity = 0.4
            locationMarker.layer.shadowRadius = 5
            locationMarker.isHidden = true
            view.addSubview(locationMarker)
        }

        func updateLocationMarker(location: CLLocation?, geo: GeoReference?) {
            guard let pdfView, let page = pdfView.document?.page(at: 0), let location, let geo else {
                locationMarker.isHidden = true
                return
            }
            let c = location.coordinate
            guard geo.contains(latitude: c.latitude, longitude: c.longitude) else {
                locationMarker.isHidden = true
                return
            }
            let pdfPoint = geo.pdfPoint(latitude: c.latitude, longitude: c.longitude)
            let viewPoint = pdfView.convert(pdfPoint, from: page)
            locationMarker.center = viewPoint
            locationPointInView = viewPoint
            locationMarker.isHidden = false
            pdfView.bringSubviewToFront(locationMarker)
        }

        func updateWaypointMarkers(waypoints: [Waypoint], selected: Waypoint?, geo: GeoReference?) {
            guard let pdfView, let page = pdfView.document?.page(at: 0), let geo else {
                waypointMarkers.values.forEach { $0.removeFromSuperview() }
                waypointMarkers.removeAll()
                return
            }

            let activeIDs = Set(waypoints.map(\.id))
            let staleIDs = waypointMarkers.keys.filter { !activeIDs.contains($0) }
            for id in staleIDs {
                waypointMarkers[id]?.removeFromSuperview()
                waypointMarkers.removeValue(forKey: id)
            }

            for waypoint in waypoints {
                guard geo.contains(latitude: waypoint.latitude, longitude: waypoint.longitude) else {
                    waypointMarkers[waypoint.id]?.isHidden = true
                    continue
                }

                let marker = waypointMarkers[waypoint.id] ?? makeWaypointMarker(for: waypoint, on: pdfView)
                marker.waypoint = waypoint
                marker.accessibilityLabel = waypointAccessibilityLabel(waypoint)

                let pdfPoint = geo.pdfPoint(latitude: waypoint.latitude, longitude: waypoint.longitude)
                marker.center = pdfView.convert(pdfPoint, from: page)
                marker.isHidden = false

                let isSelected = selected?.id == waypoint.id
                marker.backgroundColor = isSelected ? .systemOrange : .systemRed
                marker.layer.borderWidth = isSelected ? 3 : 2
                marker.transform = isSelected ? CGAffineTransform(scaleX: 1.18, y: 1.18) : .identity
                pdfView.bringSubviewToFront(marker)
            }
            pdfView.bringSubviewToFront(locationMarker)
        }

        private func makeWaypointMarker(for waypoint: Waypoint, on view: PDFView) -> WaypointMarkerButton {
            let marker = WaypointMarkerButton(type: .custom)
            marker.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            marker.waypoint = waypoint
            marker.setTitle("●", for: .normal)
            marker.setTitleColor(.white, for: .normal)
            marker.titleLabel?.font = .boldSystemFont(ofSize: 14)
            marker.backgroundColor = .systemRed
            marker.layer.cornerRadius = 17
            marker.layer.borderColor = UIColor.white.cgColor
            marker.layer.borderWidth = 2
            marker.layer.shadowColor = UIColor.black.cgColor
            marker.layer.shadowOpacity = 0.45
            marker.layer.shadowRadius = 4
            marker.layer.shadowOffset = CGSize(width: 0, height: 2)
            marker.accessibilityTraits = .button
            marker.accessibilityHint = "Buka detail waypoint dan pilihan navigasi"
            marker.addTarget(self, action: #selector(markerTapped(_:)), for: .touchUpInside)
            view.addSubview(marker)
            waypointMarkers[waypoint.id] = marker
            return marker
        }

        @objc private func markerTapped(_ sender: WaypointMarkerButton) {
            guard let waypoint = sender.waypoint else { return }
            onWaypointTapped(waypoint)
        }

        private func waypointAccessibilityLabel(_ waypoint: Waypoint) -> String {
            var parts = [waypoint.name]
            if !waypoint.petak.isEmpty { parts.append("Petak \(waypoint.petak)") }
            if !waypoint.plot.isEmpty { parts.append("Plot \(waypoint.plot)") }
            return parts.joined(separator: ", ")
        }

        func centerOnLocationIfPossible() {
            guard let pdfView, let p = locationPointInView else { return }
            let scroll = pdfView.subviews.compactMap { $0 as? UIScrollView }.first
            let target = CGPoint(
                x: max(0, p.x - pdfView.bounds.width / 2),
                y: max(0, p.y - pdfView.bounds.height / 2)
            )
            scroll?.setContentOffset(target, animated: true)
        }
    }
}

private final class WaypointMarkerButton: UIButton {
    var waypoint: Waypoint?
}
