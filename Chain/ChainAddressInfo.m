//
//  Chain.h
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import "ChainAddressInfo.h"

@interface ChainAddressInfo ()
@property(nonatomic, readwrite) BTCAddress* address;
@property(nonatomic, readwrite) BTCAmount totalBalance;
@property(nonatomic, readwrite) BTCAmount totalReceived;
@property(nonatomic, readwrite) BTCAmount totalSent;
@property(nonatomic, readwrite) BTCAmount confirmedBalance;
@property(nonatomic, readwrite) BTCAmount confirmedReceived;
@property(nonatomic, readwrite) BTCAmount confirmedSent;
@end

@implementation ChainAddressInfo

- (id) initWithDictionary:(NSDictionary*) dictionary
{
    if (self = [super init])
    {
        self.address = [BTCAddress addressWithBase58String:dictionary[@"address"]];
        self.totalBalance      = [[dictionary[@"total"] objectForKey:@"balance"] longLongValue];
        self.totalReceived     = [[dictionary[@"total"] objectForKey:@"received"] longLongValue];
        self.totalSent         = [[dictionary[@"total"] objectForKey:@"sent"] longLongValue];
        self.confirmedBalance  = [[dictionary[@"confirmed"] objectForKey:@"balance"] longLongValue];
        self.confirmedReceived = [[dictionary[@"confirmed"] objectForKey:@"received"] longLongValue];
        self.confirmedSent     = [[dictionary[@"confirmed"] objectForKey:@"sent"] longLongValue];
    }
    return self;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<ChainAddressInfo:%@ total:%@ confirmed:%@>", self.address.base58String, @(self.totalBalance), @(self.confirmedBalance)];
}


@end
