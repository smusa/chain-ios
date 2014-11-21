
## Getting Started

This project uses CocoaPods for end-user app, but for its own static lib and
unit tests uses dependencies directly (CoreBitcoin submodule with OpenSSL).

These dependencies are not needed for the end-user, they will automatically link
via CocoaPods. But for running unit tests you have to checkout submodule and
build OpenSSL:

```bash
$ git submodule update --init
$ cd CoreBitcoin
$ ./update_openssl.sh
```

## Publishing a CocoaPod

```bash
$ git tag X.Y.Z
$ git push origin master --tags
$ pod trunk push Chain.podspec
```

## TODO

- should verify websocket connection with ChainCertificate.der anchor
- parse txs and blocks from dicts to BTCTransaction, BTCBlock
- more tests for websockets
- address notifications support in websockets
- renamed notifications API to be more aligned with Cocoa
- fix base64 deprecation warnings in RocketSocket lib
