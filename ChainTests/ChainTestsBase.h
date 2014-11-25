#import <XCTest/XCTest.h>
#import <CoreBitcoin/CoreBitcoin.h>
#import <CoreBitcoin/CoreBitcoin+Categories.h>
#import "Chain.h"

@interface ChainTestsBase : XCTestCase

@property(nonatomic) Chain* client;

@property(nonatomic) NSString* blockchain; // default is ChainBlockchainMainnet

// Call this in the beginning of the individual test.
- (void) shouldCompleteIn:(NSTimeInterval)timeout;

// Call this when task is completed.
- (void) completedAsyncTask;

// Call this in the end of individual test.
- (void) waitForCompletion;

@end
