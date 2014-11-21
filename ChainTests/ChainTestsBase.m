#import "ChainTestsBase.h"

@interface ChainTestsBase ()
@property(nonatomic) XCTestExpectation* asyncExpectation;
@property(nonatomic) NSTimeInterval timeout;
@end

@implementation ChainTestsBase

- (void)setUp
{
    [super setUp];
    self.client = [Chain sharedInstanceWithToken:@"2277e102b5d28a90700ff3062a282228"];
    NSString* bc = self.blockchain ?: ChainBlockchainMainnet;
    self.client.blockchain = bc;
}

- (void) shouldCompleteIn:(NSTimeInterval)timeout
{
    self.timeout = timeout;
    self.asyncExpectation = [self expectationWithDescription:@"Async operation timeout"];
}

- (void) completedAsyncTask
{
    [self.asyncExpectation fulfill];
}

- (void) waitForCompletion
{
    [self waitForExpectationsWithTimeout:self.timeout handler:^(NSError* error){
        XCTAssert(error == nil, @"Address info should be fetched in under %f seconds", self.timeout);
    }];
}

@end
