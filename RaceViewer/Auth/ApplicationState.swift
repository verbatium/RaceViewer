import FirebaseAuth
import Foundation

class ApplicationState: ObservableObject {
  @Published var authenticated = false
  @Published var displayLogin = true
  @Published var user: User?

  private var handle = Auth.auth().addStateDidChangeListener { (auth, user) in
    print("auth", auth)
    print("user", user?.displayName ?? "unknown")
  }

  func signIn(email: String, password: String) {
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
      guard let strongSelf = self else { return }
      strongSelf.authenticated = true
      strongSelf.displayLogin = false
      strongSelf.user = authResult?.user
      //authResult?.credential
      //authResult?.additionalUserInfo
      if let error = error {
        print(error)
      }

    }
  }

  func logout() {
    Auth.auth().removeStateDidChangeListener(handle)

  }

  func signUp(email: String, password: String) {
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
      guard let strongSelf = self else { return }
      strongSelf.authenticated = true
      strongSelf.displayLogin = false
      strongSelf.user = authResult?.user
      //authResult?.credential
      //authResult?.additionalUserInfo
      if let error = error {
        print(error)
      }
    }
  }

}
