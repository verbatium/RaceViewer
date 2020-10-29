import SwiftUI
import Firebase

class UserDetailsViewModel: ObservableObject {
  var user: UserInfo?
  @Published var firstName: String = ""
  @Published var lastName: String = ""
  var ref: DatabaseReference

  init(ref: DatabaseReference) {
    self.ref = ref
  }

  func onAppear() {
    loadData()
  }

  func save() {
    guard let userID = Auth.auth().currentUser?.uid else { return }
    let values = ["firstName": firstName,
                "lastName": lastName]
    self.ref.child("users/\(userID)/details").updateChildValues(values)
  }

  func loadData() {
    guard let userID = Auth.auth().currentUser?.uid else { return }
    print("getting userdetails \(userID)")
    ref.child("users/\(userID)/details")
      .observeSingleEvent(of: .value, with: {[weak self] snapshot in
        print("Got snapshot")
      // Get user value
      let value = snapshot.value as? NSDictionary
      self?.firstName = value?["firstName"] as? String ?? ""
      self?.lastName = value?["lastName"] as? String ?? ""
    }) { (error) in
      print(error.localizedDescription)
    }
  }
}

struct UserDetailsView: View {
  @ObservedObject var model: UserDetailsViewModel

  var body: some View {
    VStack {
      Text("User details")
      TextField("First name", text: $model.firstName)
      TextField("Last name", text: $model.lastName)
      Button("Save") {
        model.save()
      }
    }.onAppear(perform: model.onAppear)
  }
}

struct UserDetailsView_Previews: PreviewProvider {
  static var previews: some View {

    UserDetailsView(model: UserDetailsViewModel(ref: DatabaseReference()))
  }
}
