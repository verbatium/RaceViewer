import Combine
import Foundation
import MapKit

class TrackOverlayRenderer: MKOverlayPathRenderer {

  private let lineOverlay: TrackOverlay

  var subscribers = [AnyCancellable]()

  init(overlay lineOverlay: TrackOverlay) {
    self.lineOverlay = lineOverlay
    super.init(overlay: lineOverlay)
    lineOverlay.$refreshBBox
      .sink { box in
        self.setNeedsDisplay(box)
      }
      .store(in: &subscribers)
  }

  override public func createPath() {
    let points = lineOverlay.trackPoints.map { point(for: $0) }
    path = lineOverlay.path(points: points)
    lineOverlay.boundsMapRect = mapRect(for: path.boundingBox)
  }

  override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
    self.createPath()
    super.draw(mapRect, zoomScale: zoomScale, in: context)
  }
}
