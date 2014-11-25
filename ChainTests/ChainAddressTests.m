
#import "ChainTestsBase.h"

@interface ChainAddressTests : ChainTestsBase
@end

@implementation ChainAddressTests

- (void)testAddressInfo
{
    [self shouldCompleteIn:2.0];

    // This is an example of a functional test case.
    BTCAddress* address = [BTCAddress addressWithBase58String:@"17x23dNjXJLzGMev6R63uyRhMWP1VHawKc"];

    [self.client getAddress:address.base58String completionHandler:^(NSDictionary *dictionary, NSError *error) {

        XCTAssert(dictionary, @"Must receive a dictionary");
        XCTAssert([dictionary[@"results"] isKindOfClass:[NSArray class]], @"Must receive a results array");

        NSDictionary* result = [dictionary[@"results"] firstObject];
        XCTAssert([dictionary[@"results"] count] == 1, @"Must have one result");

        XCTAssertEqualObjects(result[@"address"], address.base58String, @"should return the same address back");

        XCTAssert([result[@"confirmed"][@"balance"] isKindOfClass:[NSNumber class]], @"Balance must be NSNumber");
        XCTAssert([result[@"confirmed"][@"received"] isKindOfClass:[NSNumber class]], @"Balance must be NSNumber");
        XCTAssert([result[@"confirmed"][@"sent"] isKindOfClass:[NSNumber class]], @"Balance must be NSNumber");

        XCTAssert([result[@"total"][@"balance"] isKindOfClass:[NSNumber class]], @"Balance must be NSNumber");
        XCTAssert([result[@"total"][@"received"] isKindOfClass:[NSNumber class]], @"Balance must be NSNumber");
        XCTAssert([result[@"total"][@"sent"] isKindOfClass:[NSNumber class]], @"Balance must be NSNumber");

        [self completedAsyncTask];
    }];

    [self waitForCompletion];
}


@end
