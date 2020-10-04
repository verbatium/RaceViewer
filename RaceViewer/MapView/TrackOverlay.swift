import Combine
import Foundation
import MapKit

class TrackOverlay: MKPolyline, ObservableObject {

  @Published var trackPoints: [MKMapPoint]

  var boundsMapRect: MKMapRect = .world

  init(trackPoints: [MKMapPoint]) {
    self.trackPoints = trackPoints
  }

  func addPoint(point: MKMapPoint) {
    trackPoints.append(point)
  }

  override var boundingMapRect: MKMapRect {
    boundsMapRect
  }

  override var pointCount: Int { trackPoints.count }

  func path(points: [CGPoint]) -> CGMutablePath {
    let path = CGMutablePath()
    if let origin = points.first {
      path.move(to: origin)
    }
    points.dropFirst().forEach { point in
      path.addLine(to: point)
    }

    return path
  }
}
