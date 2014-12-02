import XCTest

class OpReturnTests : BaseTests {

    override func blockchain() -> String {
        return ChainBlockchainMainnet
    }

    override func setUp() {
        super.setUp()
    }

    func testAddressOpReturns() {
        self.shouldCompleteIn(10.0)
        self.client.getAddressOpReturns("1Bj5UVzWQ84iBCUiy5eQ1NEfWfJ4a3yKG1") { opreturns, error in

            XCTAssert(opreturns.count > 0)

            let opreturn = (opreturns as [ChainOpReturn]).first!

            XCTAssert(opreturn.data.length > 0)
            XCTAssert(countElements(opreturn.text) > 0)

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testTransactionOpReturns() {
        self.shouldCompleteIn(10.0)
        self.client.getTransactionOpReturn("4a7d62a4a5cc912605c46c6a6ef6c4af451255a453e6cbf2b1022766c331f803") { opreturn, error in

            XCTAssertEqual(opreturn.transactionID, "4a7d62a4a5cc912605c46c6a6ef6c4af451255a453e6cbf2b1022766c331f803")
            XCTAssertEqual(opreturn.transactionHash, BTCHashFromID("4a7d62a4a5cc912605c46c6a6ef6c4af451255a453e6cbf2b1022766c331f803"))
            XCTAssertEqual(opreturn.text, "Chain.com - The Block Chain API")
            XCTAssertEqual(opreturn.data, BTCDataWithUTF8String("Chain.com - The Block Chain API"))

            XCTAssert(opreturn.receiverAddresses as [BTCAddress] == [BTCAddress(string: "1Bj5UVzWQ84iBCUiy5eQ1NEfWfJ4a3yKG1")])
            XCTAssert(opreturn.senderAddresses as [BTCAddress]   == [BTCAddress(string: "1Bj5UVzWQ84iBCUiy5eQ1NEfWfJ4a3yKG1")])

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testBlockOpReturnsByHeight() {
        self.shouldCompleteIn(10.0)
        self.client.getBlockOpReturnsByHeight(308920) { opreturns, error in

            XCTAssert(opreturns != nil)
            XCTAssertEqual(opreturns.count, 3)

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testBlockOpReturnsByHash() {
        self.shouldCompleteIn(10.0)
        self.client.getBlockOpReturnsByHash("0000000000000000179c39d35c090b7da042ded43ad49b911843fb418a983de1") { opreturns, error in

            XCTAssert(opreturns != nil)
            XCTAssertEqual(opreturns.count, 3)

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testLatestBlockOpReturns() {
        self.shouldCompleteIn(10.0)
        self.client.getLatestBlockOpReturnsWithCompletionHandler { opreturns, error in
            XCTAssert(opreturns != nil)
            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }
}