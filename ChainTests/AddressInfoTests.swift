import XCTest

class AddressInfoTests : BaseTests {

    override func blockchain() -> String {
        return ChainBlockchainMainnet
    }

    override func setUp() {
        super.setUp()

    }

    func testAddressInfoWithStringAddress() {
        self.shouldCompleteIn(2.0)
        self.client.getAddress("17x23dNjXJLzGMev6R63uyRhMWP1VHawKc") { chainAddress, error in
            XCTAssert(chainAddress != nil, "Should receive some info for an address")
            XCTAssertEqual(chainAddress.address.string, "17x23dNjXJLzGMev6R63uyRhMWP1VHawKc")
            XCTAssert(chainAddress.totalReceived > 0)
            XCTAssert(chainAddress.confirmedReceived > 0)
            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testAddressInfoWithBTCAddress() {
        self.shouldCompleteIn(2.0)
        self.client.getAddress(BTCAddress(string:"17x23dNjXJLzGMev6R63uyRhMWP1VHawKc")) { addressInfo, error in
            XCTAssert(addressInfo != nil, "Should receive some info for an address")
            XCTAssertEqual(addressInfo.address.string, "17x23dNjXJLzGMev6R63uyRhMWP1VHawKc")
            XCTAssert(addressInfo.totalReceived > 0)
            XCTAssert(addressInfo.confirmedReceived > 0)
            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testMultipleAddresses() {
        self.shouldCompleteIn(2.0)

        let mixedAddresses = [
            BTCAddress(base58String:"17x23dNjXJLzGMev6R63uyRhMWP1VHawKc"),
            "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"
        ]

        self.client.getAddresses(mixedAddresses) { chainAddresses, error in
            XCTAssert(chainAddresses != nil, "Should receive some details for the addresses")
            for ca in chainAddresses as [ChainAddress] {
                XCTAssert(
                    ca.address.string == "17x23dNjXJLzGMev6R63uyRhMWP1VHawKc" ||
                    ca.address.string == "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"
                )
                XCTAssert(ca.totalReceived > 0)
                XCTAssert(ca.confirmedReceived > 0)
            }
            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }


}