import Foundation

typealias SessionKey = String
typealias RecordKey = String
typealias DataStorage = [SessionKey: [RecordKey: DataObject]]

class DataLoader: ObservableObject {
  var data: DataStorage = DataStorage()

  var flatData: [DataObject] {
    data.values
      .flatMap { records in records.values }
      .sorted { $0.timestamp < $1.timestamp }
  }

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
