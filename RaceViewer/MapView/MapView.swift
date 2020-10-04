import Combine
import MapKit
import SwiftUI

struct MapView {
  var viewModel: MapViewViewModel
  var tileOverlay: MKTileOverlay
  var trackOverlay: TrackOverlay
  var boatOverlay: TrackOverlay
  var renderer: MKOverlayRenderer
  var boatRenderer: MKOverlayRenderer
  var trackRenderer: MKOverlayRenderer

  init(viewModel: MapViewViewModel) {
    self.viewModel = viewModel
    self.tileOverlay = viewModel.wmsOverlay()
    self.trackOverlay = viewModel.trackOverlay
    self.boatOverlay = viewModel.boatOverlay
    self.renderer = MKTileOverlayRenderer(tileOverlay: tileOverlay)
    let renderer = TrackOverlayRenderer(overlay: viewModel.trackOverlay)
    renderer.lineWidth = 3
    renderer.strokeColor = .yellow
    self.trackRenderer = renderer
    let boatRenderer = TrackOverlayRenderer(overlay: viewModel.boatOverlay)
    boatRenderer.fillColor = .white
    self.boatRenderer = boatRenderer
  }
}

extension MapView: NSViewRepresentable {
  func makeNSView(context: Context) -> MKMapView {
    let view = MKMapView(frame: .zero)
    view.delegate = context.coordinator
    //view.addOverlay(tileOverlay)
    view.addOverlay(trackOverlay)
    view.addOverlay(boatOverlay)
    viewModel.view = view
    return view
  }

  func updateNSView(_ nsView: MKMapView, context: NSViewRepresentableContext<MapView>) {
    viewModel.setRegion(view: nsView)
  }

  func makeCoordinator() -> MapViewCoordnator {
    MapViewCoordnator(tileRenderer: renderer, trackRenderer: trackRenderer, boatRenderer: boatRenderer)
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(viewModel: MapViewViewModel())
  }
}
