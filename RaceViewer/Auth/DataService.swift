import Foundation
import Firebase
import Combine

class DataService: ObservableObject {
  private var ref: DatabaseReference
  private var userDetailsHandle: DatabaseHandle?
  private var boatHandles: [DatabaseHandle] = []
  private var subscribers: [AnyCancellable] = []

  @Published var userDetails: UserDetails?
  @Published var boatIds: [String] = []
  @Published var boatNames: [String: String] = [:]

  init(ref: DatabaseReference) {
    self.ref = ref
    $boatIds
      .print()
      .sink { _ in}
      .store(in: &subscribers)
  }

  deinit {
    unsubscribeUserDetailsChanges()
    unsubscribeUserBoats()
  }

  // MARK: Subscribers
  func subscribeAllUserData() {
    subscribeUserDetailsChanges()
    subscribeUserBoatsAdditions()
    subscribeUserBoatsRemoval()
  }

  func subscribeUserDetailsChanges() {
    guard let userID = Auth.auth().currentUser?.uid else { return }
    userDetailsHandle = ref.child("users/\(userID)/details")
      .observe(.value) { [weak self] snapshot in
        self?.userDetails = self?.decode(snapshot: snapshot)
      }
      withCancel: { (error) in
        print(error.localizedDescription)
      }
  }

  func unsubscribeUserDetailsChanges() {
    userDetailsHandle.map {
      ref.removeObserver(withHandle: $0)
      self.userDetailsHandle = nil
    }
  }

  func subscribeUserBoatsAdditions() {
    guard let userID = Auth.auth().currentUser?.uid else { return }
    let boatsHandle = ref.child("users/\(userID)/boats").observe(.childAdded) { [weak self] snapshot in
      self?.boatIds.append(snapshot.key)
      self?.getNameForBoat(key: snapshot.key)
    }
    boatHandles.append(boatsHandle)
  }

  func getNameForBoat(key: String) {
    ref.child("boats/\(key)/name")
      .observeSingleEvent(of: .value) { [weak self] snapshot in
      if let value = snapshot.value as? String {
        self?.boatNames[key] = value
      }
    }
  }

  func subscribeUserBoatsRemoval() {
    guard let userID = Auth.auth().currentUser?.uid else { return }
    let boatsHandle = ref.child("users/\(userID)/boats").observe(.childRemoved) { [weak self] snapshot in
      if let index = self?.boatIds.firstIndex(of: snapshot.key) {
        self?.boatIds.remove(at: index)
        self?.boatNames.removeValue(forKey: snapshot.key)
      }
    }
    boatHandles.append(boatsHandle)
  }

  func unsubscribeUserBoats() {
    boatHandles.forEach { ref.removeObserver(withHandle: $0)}
    boatHandles = []
  }

  func save(userDetails: UserDetails) {
    guard let userID = Auth.auth().currentUser?.uid else { return }
    var values: [String: String] = [:]
    userDetails.firstName.map {values["firstName"] = $0 }
    userDetails.lastName.map {values["lastName"] = $0 }
    self.ref.child("users/\(userID)/details").updateChildValues(values)
  }

  func createBoat() {
    guard
      let key = ref.child("boats").childByAutoId().key,
      let userId = Auth.auth().currentUser?.uid
    else { return }
    let value: [String: Any] = ["owner": userId,
                                "name": "New boat",
                                "crew": [userId: true]
    ] as [String: Any]
    ref.child("boats/\(key)/").setValue(value)
    ref.child("users/\(userId)/boats/\(key)").setValue(true)
  }

  // MARK: Private functions
  private func decode<T: Decodable>( snapshot: DataSnapshot) -> T? {
    guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: [])
    else { return nil}
    return try? JSONDecoder().decode(T.self, from: data)
  }

}
