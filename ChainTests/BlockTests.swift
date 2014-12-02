import XCTest

class BlockTests : BaseTests {

    override func blockchain() -> String {
        return ChainBlockchainMainnet
    }

    override func setUp() {
        super.setUp()
    }

    func testBlockHeaderByHeight() {
        self.shouldCompleteIn(10.0)
        self.client.getBlockHeader(0) { blockHeader, error in

            XCTAssert(blockHeader != nil)
            XCTAssertEqual(blockHeader.height, 0)
            XCTAssertEqual(blockHeader.blockID, "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f")

            let txids = blockHeader.userInfo["transactionIDs"] as [String]
            XCTAssertEqual(txids.count, 1)

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testBlockHeaderByHeight2() {
        self.shouldCompleteIn(10.0)
        self.client.getBlockHeader(100000) { blockHeader, error in

            XCTAssert(blockHeader != nil)
            XCTAssertEqual(blockHeader.height, 100000)
            XCTAssertEqual(blockHeader.blockID, "000000000003ba27aa200b1cecaad478d2b00432346c3f1f3986da1afd33e506")

            let txids = blockHeader.userInfo["transactionIDs"] as [String]
            XCTAssertEqual(txids.count, 4)

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testBlockHeaderByHash() {
        self.shouldCompleteIn(10.0)
        self.client.getBlockHeader("000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f") { blockHeader, error in

            XCTAssert(blockHeader != nil)
            XCTAssertEqual(blockHeader.height, 0)
            XCTAssertEqual(blockHeader.blockID, "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f")

            let txids = blockHeader.userInfo["transactionIDs"] as [String]
            XCTAssertEqual(txids.count, 1)

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testBlockHeaderByHash2() {
        self.shouldCompleteIn(10.0)
        self.client.getBlockHeader("000000000003ba27aa200b1cecaad478d2b00432346c3f1f3986da1afd33e506") { blockHeader, error in

            XCTAssert(blockHeader != nil)
            XCTAssertEqual(blockHeader.height, 100000)
            XCTAssertEqual(blockHeader.blockID, "000000000003ba27aa200b1cecaad478d2b00432346c3f1f3986da1afd33e506")

            let txids = blockHeader.userInfo["transactionIDs"] as [String]
            XCTAssertEqual(txids.count, 4)

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testBlockByHash() {
        self.shouldCompleteIn(10.0)
        self.client.getBlock("000000000003ba27aa200b1cecaad478d2b00432346c3f1f3986da1afd33e506") { block, error in

            XCTAssert(block != nil)
            XCTAssertEqual(block.height, 100000)
            XCTAssertEqual(block.blockID, "000000000003ba27aa200b1cecaad478d2b00432346c3f1f3986da1afd33e506")

            let txids = block.userInfo["transactionIDs"] as [String]
            XCTAssertEqual(txids.count, 4)

            let txids2 = (block.transactions as [BTCTransaction]).map{tx in tx.transactionID! }
            XCTAssert(txids == txids2)

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

}