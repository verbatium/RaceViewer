import Foundation

typealias DataStorage = [String: [String: DataObject]]

class DataLoader: ObservableObject {
  var data: DataStorage = DataStorage()

  init() {
    self.data = loadData()
  }

  func loadData() -> DataStorage {
    guard
      let path = Bundle.main.path(forResource: "demoData", ofType: "json"),
      let data = FileManager.default.contents(atPath: path),
      let decodedData = try? JSONDecoder().decode(DataStorage.self, from: data)
    else { return DataStorage() }

    return decodedData
  }
}
