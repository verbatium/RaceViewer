import Combine
import MapKit
import SwiftUI

class MapViewViewModel: ObservableObject {
  var currentSegmentOverlay: MKPolyline = MKPolyline()
  var boatOverlay: MKPolygon = MKPolygon()
  var boatPoints = [
    NSPoint(x: -1, y: -1),
    NSPoint(x: 1, y: -1),
    NSPoint(x: 1, y: 2),
    NSPoint(x: 0, y: 3),
    NSPoint(x: -1, y: 2),
  ]
  var coords: [CLLocationCoordinate2D] = []
  var coordinate = CurrentValueSubject<CLLocationCoordinate2D, Never>(CLLocationCoordinate2D(latitude: 59.45, longitude: 24.75))
  var subscribers = [AnyCancellable]()
  var view: MKMapView?

  init() {
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

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
      }
      .store(in: &subscribers)

  }

  func addPointToCurrentTrackSegmentAtLocation(_ coordinate: CLLocationCoordinate2D) {
    coords.append(coordinate)

    let overlay = MKPolyline(coordinates: &coords, count: coords.count)
    view?.addOverlay(overlay)
    view?.removeOverlay(currentSegmentOverlay)
    currentSegmentOverlay = overlay
  }

  func displayShip(at location: CLLocationCoordinate2D, with heading: Decimal) {
    let angle = Angle(radians: heading.doubleValue)
    let currentLocation = MKMapPoint(location)
    let scale = MKMapPointsPerMeterAtLatitude(location.latitude)
    let rotation: AffineTransform = AffineTransform(rotationByDegrees: angle.degrees.cgFloat + 180)
    let newOverlay = MKPolygon(
      points:
        boatPoints
        .map { rotation.transform($0).mapPoint }
        .map { $0 * scale }
        .map { $0 + currentLocation }, count: boatPoints.count)
    view?.addOverlay(newOverlay)
    view?.removeOverlay(boatOverlay)
    boatOverlay = newOverlay

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
