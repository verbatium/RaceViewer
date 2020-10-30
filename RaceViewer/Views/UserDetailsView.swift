import SwiftUI
import Firebase
import Combine

class UserDetailsViewModel: ObservableObject {
  @Published var firstName: String = ""
  @Published var lastName: String = ""

  var dataService: DataService
  var subscribers: [AnyCancellable] = []

  init(dataService: DataService) {
    self.dataService = dataService
    dataService.$userDetails.sink { [weak self] userDetails in
      self?.firstName = userDetails?.firstName ?? ""
      self?.lastName = userDetails?.lastName ?? ""
    }.store(in: &subscribers)
  }

  func save() {
    dataService.save(userDetails: UserDetails(firstName: firstName, lastName: lastName))
  }
}

struct UserDetailsView: View {
  @ObservedObject var model: UserDetailsViewModel

  var body: some View {
    VStack {
      Text("User details")
      TextField("First name", text: $model.firstName)
      TextField("Last name", text: $model.lastName)
      Button("Save", action: model.save)
    }
  }
}

struct UserDetailsView_Previews: PreviewProvider {
  static var previews: some View {

    UserDetailsView(model: UserDetailsViewModel(dataService: DataService(ref: DatabaseReference())))
  }
}
