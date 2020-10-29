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
    }
    boatHandles.append(boatsHandle)
  }

  func subscribeUserBoatsRemoval() {
    guard let userID = Auth.auth().currentUser?.uid else { return }
    let boatsHandle = ref.child("users/\(userID)/boats").observe(.childRemoved) { [weak self] snapshot in
      if let index = self?.boatIds.firstIndex(of: snapshot.key) {
        self?.boatIds.remove(at: index)
      }
    }
    boatHandles.append(boatsHandle)
  }

  func unsubscribeUserBoats() {
    boatHandles.forEach { ref.removeObserver(withHandle: $0)}
    boatHandles = []
  }

  // MARK: Private functions
  private func decode<T: Decodable>( snapshot: DataSnapshot) -> T? {
    guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: [])
    else { return nil}
    return try? JSONDecoder().decode(T.self, from: data)
  }
}
