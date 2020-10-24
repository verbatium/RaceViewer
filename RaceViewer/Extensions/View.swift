import SwiftUI

extension View {
  func eraseToAnyView() -> AnyView {
    AnyView(self)
  }

  func frameFullScreen() -> some View {
    self.frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
