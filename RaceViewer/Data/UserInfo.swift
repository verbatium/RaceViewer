import Foundation

struct UserInfo {
  let id: String
  let firstName: String?
  let lastName: String?
  let boats: [String]?
}

struct Boat: Identifiable {
  let id: String
  let owner: String
  var name: String
  var crew: [String]?
  var races: [String]?
}

struct Race {
  let id: String
  let date: Date
  let startLine: StartLine
}

struct StartLine {

}

struct Track {
  let id: String
  let sensorData: [SensorData]
}

struct SensorData {
  let id: String

}
