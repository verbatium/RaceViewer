import SwiftUI

struct MainView: View {
  @EnvironmentObject var applicationState: ApplicationState
  var body: some View {
  NavigationView {
    List(Menu.allCases, id: \.self, selection: $applicationState.selection) { menuItem in
      Text(menuItem.rawValue)
        .focusable()
        .id(menuItem)
        .tag(menuItem)
    }
    .listStyle(SidebarListStyle())
    .frame(minWidth: 100)
    userDetailsView.frameFullScreen()
  }
}

  var userDetailsView: AnyView {
    switch applicationState.selection {
    case .userDetails:
      return UserDetailsView(model: applicationState.userDetailsViewModel)
        .eraseToAnyView()
    case .map:
      return MapView(viewModel: applicationState.mapViewModel)
        .eraseToAnyView()
    default:
      return Text(applicationState.selection?.rawValue ?? "")
        .font(.largeTitle)
        .eraseToAnyView()
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .environmentObject(ApplicationState())
  }
}
