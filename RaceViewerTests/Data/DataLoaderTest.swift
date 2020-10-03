import XCTest

class DataLoaderTest: XCTestCase {

  func testDataLoad() throws {
    let loader = DataLoader()

    XCTAssertEqual(2, loader.data.count)

  }
}
