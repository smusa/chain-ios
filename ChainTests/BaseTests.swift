import XCTest

/// Base class for all tests.
class BaseTests : XCTestCase {
    var client:Chain!
    var asyncExpectation:XCTestExpectation?
    var asyncTimeout:NSTimeInterval = 2.0

    override func setUp() {
        super.setUp()
        self.client = Chain.sharedInstanceWithToken("2277e102b5d28a90700ff3062a282228")
        self.client.blockchain = blockchain()
    }

    func blockchain() -> String {
        return ChainBlockchainMainnet
    }

    override func tearDown() {
        super.tearDown()
    }

    func shouldCompleteIn(timeout: NSTimeInterval) {
        self.asyncTimeout = timeout
        self.asyncExpectation = self.expectationWithDescription("Async operation should complete in \(timeout) seconds")
    }

    func completeAsyncTask() {
        self.asyncExpectation!.fulfill();
    }

    func waitForCompletion(success: ()->Void = {}) {
        self.waitForExpectationsWithTimeout(self.asyncTimeout, handler:{ (error:NSError?) in
            XCTAssert(error == nil, "Should complete within \(self.asyncTimeout) sec");
            if error != nil {
                success()
            }
        })
    }
}
