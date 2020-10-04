import Combine
import MapKit
import SwiftUI

struct MapView {
  var viewModel: MapViewViewModel
  var tileOverlay: MKTileOverlay
  var renderer: MKTileOverlayRenderer

  init(viewModel: MapViewViewModel) {
    self.viewModel = viewModel
    self.tileOverlay = viewModel.wmsOverlay()
    self.renderer = MKTileOverlayRenderer(tileOverlay: tileOverlay)
  }
}

extension MapView: NSViewRepresentable {
  func makeNSView(context: Context) -> MKMapView {
    let view = MKMapView(frame: .zero)
    view.delegate = context.coordinator
    view.addOverlay(tileOverlay)
    viewModel.view = view
    return view
  }

  func updateNSView(_ nsView: MKMapView, context: NSViewRepresentableContext<MapView>) {
    viewModel.setRegion(view: nsView)
  }

  func makeCoordinator() -> MapViewCoordnator {
    MapViewCoordnator(tileRenderer: renderer)
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(viewModel: MapViewViewModel())
  }
}
