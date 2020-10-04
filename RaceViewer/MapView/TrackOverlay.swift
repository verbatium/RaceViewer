import Combine
import Foundation
import MapKit

class TrackOverlay: MKPolyline, ObservableObject {

  var trackPoints: [MKMapPoint]
  @Published var refreshBBox: MKMapRect = MKMapRect()

  var boundsMapRect: MKMapRect = .world

  init(trackPoints: [MKMapPoint]) {
    self.trackPoints = trackPoints
  }

  func addPoint(point last: MKMapPoint) {
    let lastPoints = self.trackPoints.suffix(5)
    let delta = 30.0
    if let first = lastPoints.first {
      self.refreshBBox = MKMapRect(
        x: first.x - delta,
        y: first.y - delta,
        width: last.x - first.x + delta * 2,
        height: last.y - first.y + delta * 2)
    }
    trackPoints.append(last)
  }

  func replacePoints(points: [MKMapPoint]) {
    let newBBox = bbox(points)
    let refreshBBox = boundsMapRect.union(newBBox)
    self.trackPoints = points
    self.refreshBBox = refreshBBox
  }

  override var boundingMapRect: MKMapRect {
    boundsMapRect
  }

  override var pointCount: Int { trackPoints.count }

  func path(points: [CGPoint]) -> CGMutablePath {
    let path = CGMutablePath()
    if let origin = points.first {
      path.move(to: origin)
      points.dropFirst().forEach { point in
        path.addLine(to: point)
      }
    }
    return path
  }

  func bbox(_ points: [MKMapPoint]) -> MKMapRect {
    let delta = 30.0
    let minX = points.map { $0.x }.min() ?? 0
    let maxX = points.map { $0.x }.max() ?? 0
    let minY = points.map { $0.y }.min() ?? 0
    let maxY = points.map { $0.y }.max() ?? 0
    let width = maxX - minX
    let height = maxY - minY

    return MKMapRect(x: minX - delta, y: minY - delta, width: width + delta * 2, height: height + delta * 2)
  }

}
