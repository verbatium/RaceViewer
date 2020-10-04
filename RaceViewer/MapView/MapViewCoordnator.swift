import MapKit

final class MapViewCoordnator: NSObject, MKMapViewDelegate {
  var tileRenderer: MKOverlayRenderer
  var trackRenderer: MKOverlayRenderer
  var boatRenderer: MKOverlayRenderer

  init(tileRenderer: MKOverlayRenderer, trackRenderer: MKOverlayRenderer, boatRenderer: MKOverlayRenderer) {
    self.tileRenderer = tileRenderer
    self.trackRenderer = trackRenderer
    self.boatRenderer = boatRenderer
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay.isEqual(boatRenderer.overlay) {
      return boatRenderer
    } else if overlay.isEqual(trackRenderer.overlay) {
      return trackRenderer
    } else if overlay is MKTileOverlay {
      return tileRenderer
    } else {
      return MKOverlayRenderer(overlay: overlay)
    }
  }
}
