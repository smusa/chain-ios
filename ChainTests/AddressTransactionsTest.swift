import XCTest

class AddressTransactionsTests : BaseTests {

    override func blockchain() -> String {
        return ChainBlockchainMainnet
    }

    override func setUp() {
        super.setUp()
    }

    func testSingleAddressTransactions() {
        self.shouldCompleteIn(10.0)
        self.client.getAddressTransactions("1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG", limit: 100) { transactions, error in

            XCTAssert(transactions != nil, "Should receive some transaction for an address")

            self.verifyTransactions(transactions as [ChainTransaction], addresses: ["1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"])

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testSingleAddressTransactions2() {
        self.shouldCompleteIn(10.0)
        self.client.getAddressTransactions("17x23dNjXJLzGMev6R63uyRhMWP1VHawKc", limit: 100) { transactions, error in

            XCTAssert(transactions != nil, "Should receive some transaction for an address")

            self.verifyTransactions(transactions as [ChainTransaction], addresses: ["17x23dNjXJLzGMev6R63uyRhMWP1VHawKc"])

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testMultipleAddressesTransactions() {
        self.shouldCompleteIn(10.0)
        self.client.getAddressesTransactions(["17x23dNjXJLzGMev6R63uyRhMWP1VHawKc",
                                              "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"],
                                            limit: 100) { transactions, error in

            XCTAssert(transactions != nil, "Should receive some transaction for an address")

            self.verifyTransactions(transactions as [ChainTransaction],
                                addresses: ["17x23dNjXJLzGMev6R63uyRhMWP1VHawKc",
                                            "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"])

            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testOutputLimit() {

    }


    // Helpers

    func verifyTransactions(txs: [ChainTransaction], addresses: [String]) {

        XCTAssert(txs.count > 0)

        for tx in txs {
            let addresses = tx.inputs.reduce([] as [BTCAddress]) { acc, txin in
                let txin2 = txin as? ChainTransactionInput
                XCTAssert(txin2 != nil)
                let addrs = txin2!.addresses as? [BTCAddress]
                XCTAssert(addrs != nil)
                return acc + addrs!
            }

            XCTAssert(tx.blockHeight > 0)
        }
    }

}