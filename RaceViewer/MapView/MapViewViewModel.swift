import Combine
import MapKit

class MapViewViewModel: ObservableObject {
  var currentSegmentOverlay: MKPolyline = MKPolyline()
  var coords: [CLLocationCoordinate2D] = []
  var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 59.45, longitude: 24.75)

  var timer: AnyCancellable?
  var view: MKMapView?

  init() {
    self.timer = Timer.publish(every: 0.1, on: .main, in: .common)
      .autoconnect()
      .sink { _ in
        let coordinate = CLLocationCoordinate2D(
          latitude: self.coordinate.latitude + 0.0001, longitude: self.coordinate.longitude)
        self.addPointToCurrentTrackSegmentAtLocation(coordinate)
        self.coordinate = coordinate
      }
  }

  func addPointToCurrentTrackSegmentAtLocation(_ coordinate: CLLocationCoordinate2D) {
    coords.append(coordinate)

    let overlay = MKPolyline(coordinates: &coords, count: coords.count)
    view?.addOverlay(overlay)
    view?.removeOverlay(currentSegmentOverlay)
    currentSegmentOverlay = overlay
  }

  func setRegion(view: MKMapView) {
    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    let region = MKCoordinateRegion(center: coordinate, span: span)

    view.setCenter(coordinate, animated: true)
    view.setRegion(region, animated: true)
  }
}
