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

    func makeCoordinator() -> Coordinator { Coordinator() }

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
        context.coordinator.updateLocationMarker(location: location, geo: geoReference)
        context.coordinator.updateWaypointMarkers(waypoints: waypoints, selected: selectedWaypoint, geo: geoReference)
        if context.coordinator.lastRecenterToken != recenterToken {
            context.coordinator.lastRecenterToken = recenterToken
            context.coordinator.centerOnLocationIfPossible()
        }
    }

    final class Coordinator {
        weak var pdfView: PDFView?
        private let locationMarker = UIView()
        private var waypointMarkers: [UUID: UILabel] = [:]
        private var locationPointInView: CGPoint?
        var lastRecenterToken = 0

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
                let pdfPoint = geo.pdfPoint(latitude: waypoint.latitude, longitude: waypoint.longitude)
                let point = pdfView.convert(pdfPoint, from: page)
                marker.center = point
                marker.isHidden = false
                let isSelected = selected?.id == waypoint.id
                marker.backgroundColor = isSelected ? .systemOrange : .systemRed
                marker.layer.borderWidth = isSelected ? 3 : 2
                marker.transform = isSelected ? CGAffineTransform(scaleX: 1.18, y: 1.18) : .identity
            }
            pdfView.bringSubviewToFront(locationMarker)
        }

        private func makeWaypointMarker(for waypoint: Waypoint, on view: PDFView) -> UILabel {
            let marker = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            marker.text = "●"
            marker.textAlignment = .center
            marker.textColor = .white
            marker.font = .boldSystemFont(ofSize: 13)
            marker.backgroundColor = .systemRed
            marker.layer.cornerRadius = 15
            marker.layer.masksToBounds = false
            marker.layer.borderColor = UIColor.white.cgColor
            marker.layer.borderWidth = 2
            marker.layer.shadowColor = UIColor.black.cgColor
            marker.layer.shadowOpacity = 0.45
            marker.layer.shadowRadius = 4
            view.addSubview(marker)
            waypointMarkers[waypoint.id] = marker
            return marker
        }

        func centerOnLocationIfPossible() {
            guard let pdfView, let p = locationPointInView else { return }
            let scroll = pdfView.subviews.compactMap { $0 as? UIScrollView }.first
            let target = CGPoint(x: max(0, p.x - pdfView.bounds.width / 2), y: max(0, p.y - pdfView.bounds.height / 2))
            scroll?.setContentOffset(target, animated: true)
        }
    }
}
