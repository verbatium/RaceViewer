import SwiftUI

struct LoginView: View {
  @EnvironmentObject var applicationState: ApplicationState
  @State var email: String = ""
  @State var password: String = ""
  var body: some View {
    VStack {
      Spacer()
      TextField("email", text: $email)
      TextField("password", text: $password)
      Button("Login") {
        self.applicationState.signIn(email: email, password: password)
      }
      Spacer()
    }.frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView().environmentObject(ApplicationState())
  }
}
