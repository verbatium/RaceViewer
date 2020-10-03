import MapKit
import XCTest

class DataObjectTest: XCTestCase {

  func testDecode() throws {
    if let result = try? JSONDecoder().decode(DataObject.self, from: data) {
      XCTAssertEqual(5.480000019073485, result.aparentWindAngle)
    } else {
      XCTFail("Failed to parse JSON Objectt")
    }
  }

  func testLocation() {
    let expected = CLLocationCoordinate2D(latitude: 59.46689516666667, longitude: 24.828788999999997)

    let result = object.location

    XCTAssertEqual(expected.latitude, result.latitude)
    XCTAssertEqual(expected.longitude, result.longitude)
  }

  var object: DataObject {
    guard let result = try? JSONDecoder().decode(DataObject.self, from: data) else {
      fatalError()
    }
    return result
  }

  var data: Data {
    """
    {
          "aparentWindAngle" : 5.480000019073485,
          "apparentWindSpeed" : 1.5745140314102173,
          "courseOverGround" : 6.136577606201172,
          "currentDrift" : 0.20000000298023224,
          "currentSet" : 3.419099807739258,
          "heading" : 2.4272503852844243,
          "latitude" : 1.0378931165966354,
          "longitude" : 0.4333441173329505,
          "speedOverGround" : 0.8999999761581423,
          "timestamp" : "2020-09-30T13:48:16.308Z",
          "trueWindAngle" : 6.182600021362305,
          "trueWindDirection" : 2.3249650001525883,
          "trueWindSpeed" : 1.5745140314102173,
          "waterSpeed" : 0
    }
    """.data(using: String.Encoding.utf8)!
  }

}
