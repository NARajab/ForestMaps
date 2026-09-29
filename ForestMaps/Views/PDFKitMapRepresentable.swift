import SwiftUI
import PDFKit
import CoreLocation

struct PDFKitMapRepresentable: UIViewRepresentable {
    let url: URL
    let geoReference: GeoReference?
    let location: CLLocation?
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
        context.coordinator.installMarker(on: view)
        return view
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        context.coordinator.updateMarker(location: location, geo: geoReference)
        if context.coordinator.lastRecenterToken != recenterToken {
            context.coordinator.lastRecenterToken = recenterToken
            context.coordinator.centerOnMarkerIfPossible()
        }
    }

    final class Coordinator {
        weak var pdfView: PDFView?
        private let marker = UIView()
        private var markerPointInView: CGPoint?
        var lastRecenterToken = 0

        func installMarker(on view: PDFView) {
            marker.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
            marker.layer.cornerRadius = 11
            marker.backgroundColor = .systemBlue
            marker.layer.borderWidth = 4
            marker.layer.borderColor = UIColor.white.cgColor
            marker.layer.shadowColor = UIColor.black.cgColor
            marker.layer.shadowOpacity = 0.4
            marker.layer.shadowRadius = 5
            marker.isHidden = true
            view.addSubview(marker)
        }

        func updateMarker(location: CLLocation?, geo: GeoReference?) {
            guard let pdfView, let page = pdfView.document?.page(at: 0), let location, let geo else {
                marker.isHidden = true
                return
            }
            let c = location.coordinate
            guard geo.contains(latitude: c.latitude, longitude: c.longitude) else {
                marker.isHidden = true
                return
            }
            let pdfPoint = geo.pdfPoint(latitude: c.latitude, longitude: c.longitude)
            let viewPoint = pdfView.convert(pdfPoint, from: page)
            marker.center = viewPoint
            markerPointInView = viewPoint
            marker.isHidden = false
        }

        func centerOnMarkerIfPossible() {
            guard let pdfView, let p = markerPointInView else { return }
            let scroll = pdfView.subviews.compactMap { $0 as? UIScrollView }.first
            let target = CGPoint(x: max(0, p.x - pdfView.bounds.width / 2), y: max(0, p.y - pdfView.bounds.height / 2))
            scroll?.setContentOffset(target, animated: true)
        }
    }
}
