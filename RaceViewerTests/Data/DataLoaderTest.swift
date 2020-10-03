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
}
