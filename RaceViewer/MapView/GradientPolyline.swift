import Foundation
import MapKit

class GradientPolyline: TrackOverlay {
  var hues: [CGFloat] = []

  let maxSpeed: Double = 5.0
  let minSpeed = 0.0
  let hMax = 0.3, hMin = 0.03

  func getHue(from index: Int) -> CGColor {
    guard hues.count > index else { return CGColor(red: 1, green: 1, blue: 1, alpha: 1) }
    return NSColor(deviceHue: hues[index], saturation: 1, brightness: 1, alpha: 1).cgColor
  }

  func addPoint(point: MKMapPoint, speed: Double) {
    hues.append(calcHue(velocity: speed))
    super.addPoint(point: point)
  }
}

extension GradientPolyline {
  convenience init(trackPoints: [MKMapPoint], speeds: [Double]) {
    self.init(trackPoints: trackPoints)
    hues = speeds.map(calcHue)
  }

  func calcHue(velocity: Double) -> CGFloat {
    if velocity > maxSpeed {
      return CGFloat(hMax)
    }

    if minSpeed <= velocity && velocity <= maxSpeed {
      return CGFloat((hMax + ((velocity - minSpeed) * (hMax - hMin)) / (maxSpeed - minSpeed)))
    }

    if velocity < minSpeed {
      return CGFloat(hMin)
    }

    return CGFloat(velocity)
  }
}
