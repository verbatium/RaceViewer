import FirebaseAuth
import Foundation
import Firebase

class ApplicationState: ObservableObject {
  @Published var authenticated = false
  @Published var displayLogin = true
  @Published var user: User?
  @Published var errorMessage: String?
  @Published var selection: Menu? = .userDetails
  var ref: DatabaseReference

  var mapViewModel = MapViewViewModel()
  var userDetailsViewModel: UserDetailsViewModel
  var boatsViewModel: BoatsViewModel
  var dataService: DataService

  init() {
    ref = Database.database().reference()
    self.userDetailsViewModel = UserDetailsViewModel(ref: ref)
    self.boatsViewModel = BoatsViewModel(ref: ref)
    self.dataService = DataService(ref: ref)
  }

  private var handle = Auth.auth().addStateDidChangeListener { (auth, user) in
    print("auth", auth)
    print("user", user?.displayName ?? "unknown")
  }

  func signIn(email: String, password: String) {
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
      self?.processLogin(authResult: authResult, error: error)
    }
  }

  func signUp(email: String, password: String) {
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
      self?.processLogin(authResult: authResult, error: error)
    }
  }

  func sendPasswordReset(email: String) {
    Auth.auth().sendPasswordReset(withEmail: email) { error in
      if let error = error {
        print("error resetPassword", error)
      }
    }
  }

  func logout() {
    Auth.auth().removeStateDidChangeListener(handle)
  }

  fileprivate func processLogin(authResult: AuthDataResult?, error: Error?) {
    if let error = error {
      if let errCode = AuthErrorCode(rawValue: error._code) {
        switch errCode {
        default:
          self.errorMessage = error.localizedDescription
          print(errCode, error.localizedDescription)
        }
      }
    } else if let authResult = authResult {
      print("authResult", authResult)
      self.authenticated = true
      self.displayLogin = false
      self.user = authResult.user
      print("authResult.user.uid", authResult.user.uid)
      print("authResult.user.email", authResult.user.email ?? "")
      self.dataService.subscribeAllUserData()
    }
  }
}

enum Menu: String, CaseIterable {
  case userDetails = "User Details"
  case boats = "Boats"
  case groups = "Groups"
  case map = "Map"
}
