import XCTest
@testable import MySwiftLib

final class MySwiftLibTests: XCTestCase {
    func testHello() {
        XCTAssertEqual(MySwiftLib.hello("world"), "hello, world!")
    }
}
