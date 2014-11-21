//
//  Chain.h
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import "Chain.h"
#import "ChainNotification.h"

NSString* const ChainNotificationTypeAddress = @"address";
NSString* const ChainNotificationTypeTransaction = @"transaction";
NSString* const ChainNotificationTypeNewTransaction = @"new-transaction";
NSString* const ChainNotificationTypeNewBlock = @"new-block";
NSString* const ChainNotificationTypeHeartbeat = @"heartbeat"; // can be received from time to time

@interface ChainNotification ()
@property(nonatomic, readwrite) NSString* type;
@end

@implementation ChainNotification

// Instantiates a notification with a given type.
- (id) initWithType:(NSString*)type
{
    if (self = [super init])
    {
        self.type = type;
        self.blockchain = ChainBlockchainMainnet;
    }
    return self;
}

/// Instantiates a notification with type "transaction" watching for transaction
/// with a given ID.
- (id) initWithTransactionID:(NSString*)txid
{
    NSParameterAssert(txid);
    if (self = [self initWithType:ChainNotificationTypeTransaction])
    {
        self.transactionID = txid;
    }
    return self;
}

/// Instantiates a notification with type "address" watching for a given address.
- (id) initWithAddress:(NSString*)address
{
    NSParameterAssert(address);
    if (self = [self initWithType:ChainNotificationTypeAddress])
    {
        self.address = address;
    }
    return self;
}


- (NSDictionary*) dictionary
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

    dict[@"type"] = self.type;
    dict[@"block_chain"] = self.blockchain ?: ChainBlockchainMainnet;
    if (self.transactionID) dict[@"transaction_hash"] = self.transactionID;
    if (self.address) dict[@"address"] = self.address;

    return dict;
}

@end
