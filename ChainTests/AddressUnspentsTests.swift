import XCTest

class AddressUnspentsTests : BaseTests {

    override func blockchain() -> String {
        return ChainBlockchainMainnet
    }

    override func setUp() {
        super.setUp()
    }

    func testSingleAddressTransactions() {
        self.shouldCompleteIn(10.0)
        self.client.getAddressUnspents("1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG") { outputs, error in

            XCTAssert(outputs != nil, "Should receive some transaction for an address")

            XCTAssert(outputs.count > 0)

            for txout in outputs as [ChainTransactionOutput] {

                XCTAssert(txout.script.standardAddress.string == "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG")
                XCTAssert(txout.value > 0)
                XCTAssert(txout.spent == false)
                let addrs = (txout.addresses as [BTCAddress]).map{ a in a.string }
                XCTAssert(addrs.first == "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG")
                XCTAssert(addrs.count == 1)
                XCTAssert(txout.confirmations > 0)
            }

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

}