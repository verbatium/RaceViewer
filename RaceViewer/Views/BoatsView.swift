import SwiftUI
import Firebase
import Combine

class BoatsViewModel: ObservableObject {
  var dataService: DataService
  var subscribers: [AnyCancellable] = []
  @Published var selectedBoat: Boat?
  @Published var boatNames: [String: String] = [:]

  init(dataService: DataService) {
    self.dataService = dataService
    dataService
      .$boatNames
      .assign(to: \.boatNames, on: self)
      .store(in: &subscribers)
  }

  func createBoat() {
    dataService.createBoat()
  }
}

struct BoatDetails: View {
  var boat: Boat

  init(boat: Boat) {
    self.boat = boat
  }

  var body: some View {
    Text(boat.name)
  }
}

struct BoatsView: View {
  @ObservedObject var model: BoatsViewModel

  var body: some View {
    VStack {
      Button("Create boat", action: model.createBoat)
      Form {
        List {
          ForEach(model.boatNames.sorted(by: >), id: \.key) { key, value in
            NavigationLink(value, destination: BoatDetails(boat: Boat(id: key, owner: "", name: value, crew: nil, races: nil)))
          }
        }
      }
    }
  }
}

struct BoatsView_Previews: PreviewProvider {
  static var previews: some View {
    BoatsView(model: BoatsViewModel(dataService: DataService(ref: DatabaseReference())))
  }
}
