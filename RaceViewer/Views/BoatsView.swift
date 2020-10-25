import SwiftUI
import Firebase
import Combine

class BoatsViewModel: ObservableObject {
  var ref: DatabaseReference
  private var handle: DatabaseHandle?
  @Published var selectedBoat: Boat?
  @Published var boats: [Boat] = []

  init(ref: DatabaseReference) {
    self.ref = ref
  }

  func createBoat() {
    guard
      let key = ref.child("Boats").childByAutoId().key,
      let userId = Auth.auth().currentUser?.uid
    else { return }
    let value = [ "owner": userId,
                  "name": "New boat"
    ]
    ref.child("boats/\(key)/").setValue(value)
  }

  func loadData() {
    guard
      let userId = Auth.auth().currentUser?.uid,
      handle == nil
    else { return }
    handle = ref.child("boats")
      .queryOrdered(byChild: "owner")
      .queryEqual(toValue: userId)
      .observe(.value) { snapshot in
        if let datas = snapshot.children.allObjects as? [DataSnapshot] {
          let results: [Boat] = datas.compactMap {
            guard
              let value = $0.value as? NSDictionary,
              let name = value["name"] as? String else {
              return nil
            }
           return Boat(id: $0.key,
                        owner: userId,
                        name: name)
          }
          print(results)
            self.boats = results
        }
      }
      withCancel: { error in
        print(error.localizedDescription)
      }
  }

  func onAppear() {
    loadData()
  }

  deinit {
    handle.map {
      ref.removeObserver(withHandle: $0)
      self.handle = nil
    }
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
      Button("Create boat") {
        model.createBoat()
      }
      List(model.boats) { boat in
          NavigationLink(boat.name, destination: BoatDetails(boat: boat))
        }
    }
    .onAppear(perform: model.onAppear)
  }
}

struct BoatsView_Previews: PreviewProvider {
  static var previews: some View {
    BoatsView(model: BoatsViewModel(ref: DatabaseReference()))
  }
}
