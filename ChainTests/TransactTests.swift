import XCTest

class TransactTests : BaseTests {

    var key1: BTCKey!
    var key2: BTCKey!
    var key3: BTCKey!

    override func blockchain() -> String {
        return ChainBlockchainTestnet
    }

    override func setUp() {
        super.setUp()

        key1 = BTCKey(WIF: "cMrXnFTX6LyEGaUp5Du6onM8kQqD6gGoeoDTKj9KmE87n4qP6umh")
        key2 = BTCKey(WIF: "cTut2nqgnG4vvdphvZe3gN3zgQLoqdZ2iPKg8yuuDfXMGBobGjvD")
        key3 = BTCKey(WIF: "cUbwpPTPKwqA3LU215Zg8Ua9YFXBjHQLvYfgM7qpDa1LXpRCPAeG")

        XCTAssertEqual(key1.addressTestnet.base58String(), "mrn4jgT5gGLZjK36CAGWZj917meq9Rk3Gv")
        XCTAssertEqual(key2.addressTestnet.base58String(), "mzRf7M6cUzRWWPCUPNu5f9swpAaBZBKg8K")
        XCTAssertEqual(key3.addressTestnet.base58String(), "mu4pn3U3frfjDCw1QsG8dxNh7qJTTJ7A3J")
    }

    func keyForAddress(address: BTCAddress) -> BTCKey? {
        let addrString = address.base58String()
        if key1.addressTestnet.base58String() == addrString { return key1 }
        if key2.addressTestnet.base58String() == addrString { return key2 }
        if key3.addressTestnet.base58String() == addrString { return key3 }
        return nil
    }

    func testBuildingTransaction() {

        shouldCompleteIn(2.0)

        self.client.buildTransaction([
            "inputs": [
                ["address": "mrn4jgT5gGLZjK36CAGWZj917meq9Rk3Gv"],
                ["address": "mzRf7M6cUzRWWPCUPNu5f9swpAaBZBKg8K"],
                ["address": "mu4pn3U3frfjDCw1QsG8dxNh7qJTTJ7A3J"],
            ],
            "outputs": [
                [ "address": "mrn4jgT5gGLZjK36CAGWZj917meq9Rk3Gv", "amount": 13500000 ],
                [ "address": "mzRf7M6cUzRWWPCUPNu5f9swpAaBZBKg8K", "amount": 1200000 ],
                [ "address": "mu4pn3U3frfjDCw1QsG8dxNh7qJTTJ7A3J", "amount": 20000 ]
            ]
            ]) { (dictionary, error) in

                //NSLog("template: %@", dictionary)

                let tx:BTCTransaction? = BTCTransaction(data:BTCDataWithHexString(dictionary["unsigned_hex"] as String));

                XCTAssert(tx != nil, "Should parse transaction correctly")

                let inputs = dictionary["inputs"] as [[String:AnyObject]]
                XCTAssert(inputs.count > 0, "Should return inputs to sign");

                for input in inputs {

                    let sigTemplates = input["signatures"] as [[String:AnyObject]]
                    XCTAssertEqual(input["signatures_required"] as Int, 1, "Should require one signature")
                    XCTAssertEqual(sigTemplates.count, 1, "Should provide one signature template")

                    let sigTemplate = sigTemplates.first!

                    let hashToSign = BTCDataWithHexString(sigTemplate["hash_to_sign"] as String)
                    XCTAssert(hashToSign.length == 32, "Should provide a hash to sign")

                    let addr = BTCAddress(base58String: sigTemplate["address"] as String)
                    XCTAssert(addr != nil, "Address should not nil")

                    let key = self.keyForAddress(addr)

                    XCTAssert(key != nil, "Address should correspond to one of our keys")
                }

                self.completeAsyncTask()
        }

        waitForCompletion()
    }


    func testInsufficientFunds() {

        shouldCompleteIn(2.0)

        self.client.buildTransaction([
            "inputs": [
                ["address": "mrn4jgT5gGLZjK36CAGWZj917meq9Rk3Gv"],
            ],
            "outputs": [
                [ "address": "mrn4jgT5gGLZjK36CAGWZj917meq9Rk3Gv", "amount": 1003500000 ],
            ]
            ]) { (dictionary, error) in

                //NSLog("Error: %@", error)

                XCTAssert(dictionary == nil, "Should fail")
                XCTAssertEqual(error.domain, ChainErrorDomain, "Should return error code for ChainErrorDomain")
                XCTAssertEqual(error.code, 601, "Should return error code 'not enough funds'")

                XCTAssert(error.localizedDescription.rangeOfString("insufficient",
                    options: NSStringCompareOptions.CaseInsensitiveSearch) != nil,
                    "Should say something about insufficient funds")

                self.completeAsyncTask()
        }

        waitForCompletion()
    }


    func testSigningTransaction() {

        let signedTemplate = self.client.signTransactionTemplate(
            [
                "inputs": [
                        [
                            "address": "mrn4jgT5gGLZjK36CAGWZj917meq9Rk3Gv",
                            "signatures": [
                                [
                                    "address": "mrn4jgT5gGLZjK36CAGWZj917meq9Rk3Gv",
                                    "hash_to_sign": "500f36ef25ed16919f9de007a4eaf5954cbfe269c7cb09cbc906ea6f079e2a3e",
                                    "public_key": "<insert public key>",
                                    "signature": "<insert signature>",
                                ]
                            ],
                            "signatures_required": 1,
                        ],
                        [
                            "address": "mu4pn3U3frfjDCw1QsG8dxNh7qJTTJ7A3J",
                            "signatures": [
                                [
                                    "address": "mu4pn3U3frfjDCw1QsG8dxNh7qJTTJ7A3J",
                                    "hash_to_sign": "2a3d9f985c47864efb8e2779d2661287378447ba2d063138da14da3db6100137",
                                    "public_key": "<insert public key>",
                                    "signature": "<insert signature>"
                                ]
                            ],
                            "signatures_required": 1
                        ]
                ],
            ],
            keys: [
                ["private_key": key1],
                ["private_key": key2],
                ["private_key": key3],
            ]) as [String:AnyObject]!

        XCTAssert(signedTemplate != nil, "Template must be returned")

        for input in signedTemplate!["inputs"] as [[String:AnyObject]] {
            for sigTemplate in input["signatures"] as [[String:String]] {

                let hash = BTCDataWithHexString(sigTemplate["hash_to_sign"])
                let pubkey = BTCDataWithHexString(sigTemplate["public_key"])
                let sig = BTCDataWithHexString(sigTemplate["signature"])

                XCTAssert(hash != nil, "Should have valid hex hash")
                XCTAssert(pubkey != nil, "Should have valid hex pubkey")
                XCTAssert(sig != nil, "Should have valid hex sig")

                let key = BTCKey(publicKey: pubkey)

                XCTAssert(key != nil, "Should have valid BTCKey with pubkey")
                XCTAssert(key.isValidSignature(sig, hash: hash), "Signature should be validated with the pubkey")
            }
        }
    }



    // Build, sign, send transaction
    func testTransact() {

        shouldCompleteIn(10.0)

        self.client.transact([
            "inputs": [
                ["private_key": key1.WIF, "address": key1.addressTestnet.base58String()],
                ["private_key": key2.WIF, "address": key2.addressTestnet.base58String()],
                ["private_key": key3.WIF, "address": key3.addressTestnet.base58String()],
            ],
            "outputs": [
                [ "address": "mrn4jgT5gGLZjK36CAGWZj917meq9Rk3Gv", "amount": 2350000 ],
                [ "address": "mzRf7M6cUzRWWPCUPNu5f9swpAaBZBKg8K", "amount": 1200000 ],
                [ "address": "mu4pn3U3frfjDCw1QsG8dxNh7qJTTJ7A3J", "amount": 20000 ]
            ]
            ]) { (dictionary, error) in

                let txid = dictionary["transaction_hash"] as String
                let txhash = BTCTransactionHashFromID(txid)

                NSLog("BROADCASTED TRANSACTION: %@", txid)

                XCTAssert(txhash.length == 32, "Must return a 256-bit transaction ID in hex.")

                self.completeAsyncTask()
        }

        waitForCompletion()
    }
}