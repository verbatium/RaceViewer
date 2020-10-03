import Combine
import MapKit
import SwiftUI

class MapViewViewModel: ObservableObject {
  var currentSegmentOverlay: MKPolyline = MKPolyline()
  var boatOverlay: MKPolygon = MKPolygon()
  var currentLayers: [MKOverlay] = []
  var previousLayers: [MKOverlay] = []
  let scaleBoat: AffineTransform = AffineTransform(scaleByX: 3.64, byY: 10.66)
  var boatPoints = [
    NSPoint(x: -0.5, y: -0.5), NSPoint(x: 0.5, y: -0.5),
    NSPoint(x: 0.5, y: 0),
    NSPoint(x: 0, y: 0.5),
    NSPoint(x: -0.5, y: 0),
  ]

  var coords: [CLLocationCoordinate2D] = []
  var coordinate = CurrentValueSubject<CLLocationCoordinate2D, Never>(CLLocationCoordinate2D(latitude: 59.45, longitude: 24.75))
  var subscribers = [AnyCancellable]()
  var view: MKMapView?

  init() {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    DataLoader().flatData
      .publisher
      .zip(timer)
      .dropFirst()
      .map { data, _ in data }
      .receive(on: RunLoop.main)
      .sink {
        self.coordinate.send($0.location)
        self.addPointToCurrentTrackSegmentAtLocation($0.location)
        self.displayShip(at: $0.location, with: $0.heading)
        self.updateOverlaysOnMap()
      }
      .store(in: &subscribers)

  }

  func updateOverlaysOnMap() {
    view?.addOverlays(currentLayers)
    view?.removeOverlays(previousLayers)
    previousLayers = currentLayers
    currentLayers = []
  }

  func addPointToCurrentTrackSegmentAtLocation(_ coordinate: CLLocationCoordinate2D) {
    coords.append(coordinate)

    let overlay = MKPolyline(coordinates: &coords, count: coords.count)
    currentLayers.append(overlay)
  }

  func displayShip(at location: CLLocationCoordinate2D, with heading: Decimal) {
    let angle = Angle(radians: heading.doubleValue)
    let currentLocation = MKMapPoint(location)
    let scaleFactor = MKMapPointsPerMeterAtLatitude(location.latitude)
    let rotation: AffineTransform = AffineTransform(rotationByDegrees: angle.degrees.cgFloat + 180)
    let scalePoints = AffineTransform(scale: scaleFactor.cgFloat)
    let newOverlay = MKPolygon(
      points:
        boatPoints
        .map { scaleBoat.transform($0) }
        .map { scalePoints.transform($0) }
        .map { rotation.transform($0).mapPoint }
        .map { $0 + currentLocation }, count: boatPoints.count)

    currentLayers.append(newOverlay)

  }

  func setRegion(view: MKMapView) {
    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    let region = MKCoordinateRegion(center: coordinate.value, span: span)

    view.setCenter(coordinate.value, animated: true)
    view.setRegion(region, animated: true)
  }
}

extension MKMapPoint {
  static func + (lhs: MKMapPoint, rhs: MKMapPoint) -> MKMapPoint {
    MKMapPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  static func / (lhs: MKMapPoint, rhs: Double) -> MKMapPoint {
    MKMapPoint(x: lhs.x / rhs, y: lhs.y / rhs)
  }

  static func * (lhs: MKMapPoint, rhs: Double) -> MKMapPoint {
    MKMapPoint(x: lhs.x * rhs, y: lhs.y * rhs)
  }
}

extension NSPoint {
  var mapPoint: MKMapPoint {
    MKMapPoint(x: Double(self.x), y: Double(self.y))
  }
}

extension Decimal {
  var cgFloat: CGFloat { (self as NSDecimalNumber).doubleValue.cgFloat }
}

extension Double {
  var cgFloat: CGFloat { CGFloat(self) }
}
