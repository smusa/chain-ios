import XCTest

class NotificationsTests : BaseTests {

    override func blockchain() -> String {
        return ChainBlockchainMainnet
    }

    override func setUp() {
        super.setUp()

    }

    func testNewTransactionNotifications() {

        shouldCompleteIn(10.0)
        let expectedTransactions = 4
        var transactions:[AnyObject] = []

        let notification = ChainNotification(type: ChainNotificationTypeNewTransaction)
        let observer = self.client.observerForNotification(notification, resultHandler: { (result) in

            if let newtxresult = result as? ChainNotificationNewTransaction {
                transactions.append(newtxresult.transactionDictionary)
            }

            if transactions.count >= expectedTransactions {
                self.completeAsyncTask()
            }
        })

        waitForCompletion {
            XCTAssertGreaterThanOrEqual(transactions.count, expectedTransactions, "Should receive \(expectedTransactions) transactions")
        }
    }


    func testCloseConnectionNotifications() {

        let delayAfterDisconnect = 2.0

        shouldCompleteIn(10.0 + delayAfterDisconnect)

        var transactions:[AnyObject] = []

        let notification = ChainNotification(type: ChainNotificationTypeNewTransaction)

        var observer:ChainNotificationObserver!
        observer = self.client.observerForNotification(notification, resultHandler: { result in

            if let newtxresult = result as? ChainNotificationNewTransaction {
                transactions.append(newtxresult.transactionDictionary)
            }

            if transactions.count >= 1 {
                // immediately disconnect
                observer.disconnect()

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayAfterDisconnect * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    self.completeAsyncTask()
                }
            }
        })


        waitForCompletion {
            XCTAssertEqual(transactions.count, 1, "Should receive only 1 transaction because connection was closed")
        }
    }

}