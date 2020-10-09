import SwiftUI

struct ContentView: View {
  @EnvironmentObject var applicationState: ApplicationState
  var body: some View {
    GeometryReader { proxy in
      MapView(viewModel: MapViewViewModel()).background(Color.clear)
        .sheet(isPresented: $applicationState.displayLogin) {
          LoginView()
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            .environmentObject(applicationState)
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
