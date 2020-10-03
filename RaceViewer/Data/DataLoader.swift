import Foundation

typealias DataStorage = [String: [String: DataObject]]
class DataLoader: ObservableObject {
  @Published var data: DataStorage?
  init() {
    if let path = Bundle.main.path(forResource: "demoData", ofType: "json"), let data = FileManager.default.contents(atPath: path) {
      print("dataLength", data.count)
      do {
        let decodedData = try JSONDecoder().decode(DataStorage.self, from: data)
        self.data = decodedData
      } catch {
        print("Couldn't parse file \(error)")
      }

    }
  }
}
