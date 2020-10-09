import SwiftUI

struct LoginView: View {
  @EnvironmentObject var applicationState: ApplicationState
  @State var email: String = ""
  @State var password: String = ""
  var body: some View {
    VStack {
      Spacer()
      TextField("E-mail", text: $email)
      TextField("Password", text: $password)
      if let error = self.applicationState.errorMessage {
        Text(error).foregroundColor(.red)
      }
      HStack {
        Button("Login") {
          self.applicationState.signIn(email: email, password: password)
        }
        Button("Reset password") {
          self.applicationState.sendPasswordReset(email: email)
        }
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
