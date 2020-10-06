import Combine
import Foundation
import MapKit

class GradientPolylineRenderer: MKPolylineRenderer {

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
    if self.path == nil {
      return
    }
    let boundingBox = self.path.boundingBox
    let mapRectCG = rect(for: mapRect)

    if !mapRectCG.intersects(boundingBox) { return }

    var prevColor: CGColor?
    var currentColor: CGColor?

    guard let polyLine = self.polyline as? GradientPolyline else { return }

    for index in 0...polyLine.trackPoints.count - 1 {
      let point = self.point(for: polyLine.trackPoints[index])
      let path = CGMutablePath()

      currentColor = polyLine.getHue(from: index)

      if index == 0 {
        path.move(to: point)
      } else {
        let prevPoint = self.point(for: polyLine.trackPoints[index - 1])
        path.move(to: prevPoint)
        path.addLine(to: point)

        let colors = [prevColor!, currentColor!] as CFArray
        let baseWidth = self.lineWidth / zoomScale * contentScaleFactor
        context.saveGState()
        context.addPath(path)
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: [0, 1])
        context.setLineWidth(baseWidth)
        context.replacePathWithStrokedPath()
        context.clip()
        context.setLineWidth(baseWidth)
        context.drawLinearGradient(gradient!, start: prevPoint, end: point, options: [])
        context.restoreGState()
      }
      prevColor = currentColor
    }
  }
}
