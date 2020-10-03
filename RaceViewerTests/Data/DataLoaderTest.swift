import XCTest

class DataLoaderTest: XCTestCase {

  func testDataLoad() throws {
    let loader = DataLoader()

    XCTAssertEqual(2, loader.data.count)

  }

  func testFlatData() {
    let loader = DataLoader()
    XCTAssertEqual(15081, loader.flatData.count)
  }

  func testThatDataIsSorted() {
    let data = DataLoader().flatData
    let sortedData = DataLoader().flatData.sorted { $0.timestamp < $1.timestamp }

    let allOk = data.enumerated()
      .map { $1.timestamp == sortedData[$0].timestamp }
      .allSatisfy { $0 }

    XCTAssertTrue(allOk)
    XCTAssertEqual("2020-09-30T13:48:16.308Z", data.first?.timestamp)
    XCTAssertEqual("2020-09-30T16:11:34.673Z", data.last?.timestamp)
  }
}
