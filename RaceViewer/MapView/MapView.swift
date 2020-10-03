import SwiftUI
import MapKit
import Combine

struct MapView {
  var viewModel: MapViewViewModel
}

extension MapView: NSViewRepresentable {
  func makeNSView(context: Context) -> MKMapView {
    let view = MKMapView(frame: .zero)
    view.delegate = context.coordinator
    viewModel.view = view
    return view
  }
  
  func updateNSView(_ nsView: MKMapView, context: NSViewRepresentableContext<MapView>) {
    viewModel.setRegion(view: nsView)
  }
  
  func makeCoordinator() -> MapViewCoordnator {
    MapViewCoordnator()
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(viewModel: MapViewViewModel())
  }
}
