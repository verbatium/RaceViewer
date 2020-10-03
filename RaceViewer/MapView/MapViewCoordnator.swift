import MapKit

final class MapViewCoordnator: NSObject, MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polyline = overlay as? MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: polyline)
      polylineRenderer.strokeColor = .red
      polylineRenderer.lineWidth = 3
      return polylineRenderer
    }
    return MKOverlayRenderer(overlay: overlay)
  }
}
