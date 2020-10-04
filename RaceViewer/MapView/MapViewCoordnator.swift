import MapKit

final class MapViewCoordnator: NSObject, MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polyline = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(overlay: polyline)
      renderer.strokeColor = .red
      renderer.lineWidth = 1
      return renderer
    } else if let polygon = overlay as? MKPolygon {
      let renderer = MKPolygonRenderer(overlay: polygon)
      renderer.fillColor = .white
      renderer.strokeColor = .black
      renderer.lineWidth = 1
      return renderer
    } else if let overlay = overlay as? MKTileOverlay {
      return MKTileOverlayRenderer(tileOverlay: overlay)
    } else {
      return MKOverlayRenderer(overlay: overlay)
    }
  }
}
