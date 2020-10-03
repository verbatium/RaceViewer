import Combine
import MapKit

class MapViewViewModel: ObservableObject {
  var currentSegmentOverlay: MKPolyline = MKPolyline()
  var coords: [CLLocationCoordinate2D] = []
  var coordinate = CurrentValueSubject<CLLocationCoordinate2D, Never>(CLLocationCoordinate2D(latitude: 59.45, longitude: 24.75))
  var subscribers = [AnyCancellable]()
  var view: MKMapView?

  init() {
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    DataLoader().flatData
      .publisher
      .zip(timer)
      .map { data, _ in data.location }
      .receive(on: RunLoop.main)
      .assign(to: \.value, on: self.coordinate)
      .store(in: &subscribers)

    coordinate
      .dropFirst()
      .sink { self.addPointToCurrentTrackSegmentAtLocation($0) }
      .store(in: &subscribers)

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
    let region = MKCoordinateRegion(center: coordinate.value, span: span)

    view.setCenter(coordinate.value, animated: true)
    view.setRegion(region, animated: true)
  }
}
