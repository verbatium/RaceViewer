import SwiftUI
struct LoginView: View {
  @EnvironmentObject var applicationState: ApplicationState
  @State private var email: String = ""
  @State private var password: String = ""
  var body: some View {
    VStack {
      TextField("E-mail", text: $email)
      SecureField("Password", text: $password)
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
    }
    .frame(width: 300)
    .padding()
    .overlay(
      RoundedRectangle(cornerRadius: 15)
        .stroke(Color.black, lineWidth: 1)
    ).background(
      RoundedRectangle(cornerRadius: 15)
        .fill(Color.windowBackgroundColor)
    )
    .textFieldStyle(RoundedBorderTextFieldStyle())
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LoginView().environmentObject(ApplicationState())
      LoginView().environmentObject(ApplicationState()).colorScheme(.light)
    }
  }
}
