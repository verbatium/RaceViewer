import Foundation
import Firebase
import Combine

extension DatabaseReference {
  public var combine: CombineFIRDocument {
    return CombineFIRDocument(document: self)
  }
}

public struct CombineFIRDocument {
  fileprivate let document: DatabaseReference
}

extension CombineFIRDocument {

  public final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == DataSnapshot, S.Failure == Error {

    private var subscriber: S?
    private let document: DatabaseReference
    private let _cancel: () -> Void

    fileprivate init(subscriber: S,
                     document: DatabaseReference,
                     addListener: @escaping (DatabaseReference, @escaping (DataSnapshot?, Error?) -> Void) -> DatabaseHandle,
                     removeListener: @escaping (DatabaseReference, DatabaseHandle) -> Void) {
      self.subscriber = subscriber
      self.document = document

      // This is the strong reference for an ListenerRegistration from Firebase
      // Here we pipe the "messages" from Firebase to our subscriber
      let listener = addListener(document) { documentSnapshot, error in
        if let error = error {
          subscriber.receive(completion: .failure(error))
        } else if let documentSnapshot = documentSnapshot {
          _ = subscriber.receive(documentSnapshot)
        }
      }
      self._cancel = {
        removeListener(document, listener)
      }
    }

    public func request(_ demand: Subscribers.Demand) {}

    public func cancel() {
      _cancel()
      subscriber = nil
    }


  }

  public struct Publisher: Combine.Publisher {
    public typealias Output = DataSnapshot
    public typealias Failure = Error
    private let document: DatabaseReference
    private let addListener: (DatabaseReference, @escaping (DataSnapshot?, Error?) -> Void) -> DatabaseHandle
    private let removeListener: (DatabaseReference, DatabaseHandle) -> Void

    init(document: DatabaseReference,
         addListener: @escaping (DatabaseReference, @escaping (DataSnapshot?, Error?) -> Void) -> DatabaseHandle,
         removeListener: @escaping (DatabaseReference, DatabaseHandle) -> Void) {
      self.document = document
      self.addListener = addListener
      self.removeListener = removeListener
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
      let subscription = Subscription(subscriber: subscriber,
                                      document: document,
                                      addListener: addListener,
                                      removeListener: removeListener)
      subscriber.receive(subscription: subscription)
    }
  }
}

extension CombineFIRDocument {
  func childAdded() -> AnyPublisher<DataSnapshot, Error> {
    subscribe(with: .childAdded)
  }
  func childRemoved() -> AnyPublisher<DataSnapshot, Error> {
    subscribe(with: .childRemoved)
  }
  func childMoved() -> AnyPublisher<DataSnapshot, Error> {
    subscribe(with: .childMoved)
  }
  func childChanged() -> AnyPublisher<DataSnapshot, Error> {
    subscribe(with: .childChanged)
  }

  private func subscribe(with: DataEventType) -> AnyPublisher<DataSnapshot, Error> {
    Publisher(document: document,
              addListener: { (ref: DatabaseReference, fun:  @escaping (DataSnapshot?, Error?) -> Void) -> DatabaseHandle in
                ref.observe(with) { snapshot in
                  fun(snapshot, nil)
                } withCancel: { errror in
                  fun(nil, errror)
                }
              },
              removeListener: { (ref: DatabaseReference, handle: DatabaseHandle) in
                ref.removeObserver(withHandle: handle)
              }
    ).eraseToAnyPublisher()
  }

}
