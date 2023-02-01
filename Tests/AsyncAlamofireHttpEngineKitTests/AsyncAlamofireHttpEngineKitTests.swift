import XCTest
@testable import AsyncAlamofireHttpEngineKit

final class AsyncAlamofireHttpEngineKitTests: XCTestCase {
    
    override func setUpWithError() throws {
        AsyncAlamofireHttpEngineConfiguration.isDebugMode = true
    }
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(AsyncAlamofireHttpEngineKit().text, "Hello, World!")
    }
    
    func testConnectionRefused() {
        let exp = expectation(description: "Queue")
        Task {
            do {
                let builder = AlamofireHttpRequestBuilder(to: URL(string: "http://192.168.86.2:8080/api")!)
                    .with(queryNamed: "mode", value: "queue")
                    .with(queryNamed: "api", value: "7e8e91228ad64261ab053ab2c83942ad")
                
                let response = try await builder.build().get()
            } catch {
                XCTFail("\(error)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 60.0)
    }
}
