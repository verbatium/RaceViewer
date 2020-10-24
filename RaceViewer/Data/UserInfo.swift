import Foundation

struct UserInfo {
  let id: String
  let firstName: String?
  let lastName: String?
  //let boats: [String]
}

struct Boat {
  let id: String
  let crew: [String]
  let races: [String]
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
