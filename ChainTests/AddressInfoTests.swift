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
        self.client.getAddress("17x23dNjXJLzGMev6R63uyRhMWP1VHawKc") { addressInfo, error in
            XCTAssert(addressInfo != nil, "Should receive some info for an address")
            XCTAssertEqual(addressInfo.address.base58String(), "17x23dNjXJLzGMev6R63uyRhMWP1VHawKc")
            XCTAssert(addressInfo.totalReceived > 0)
            XCTAssert(addressInfo.confirmedReceived > 0)
            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }

    func testAddressInfoWithBTCAddress() {
        self.shouldCompleteIn(2.0)
        self.client.getAddress(BTCAddress(base58String:"17x23dNjXJLzGMev6R63uyRhMWP1VHawKc")) { addressInfo, error in
            XCTAssert(addressInfo != nil, "Should receive some info for an address")
            XCTAssertEqual(addressInfo.address.base58String(), "17x23dNjXJLzGMev6R63uyRhMWP1VHawKc")
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

        self.client.getAddresses(mixedAddresses) { addressInfos, error in
            XCTAssert(addressInfos != nil, "Should receive some infos for the addresses")
            for info in addressInfos as [ChainAddressInfo] {
                XCTAssert(
                    info.address.base58String() == "17x23dNjXJLzGMev6R63uyRhMWP1VHawKc" ||
                    info.address.base58String() == "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"
                )
                XCTAssert(info.totalReceived > 0)
                XCTAssert(info.confirmedReceived > 0)
            }
            self.completeAsyncTask()
        }
        self.waitForCompletion();
    }


}