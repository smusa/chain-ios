//
//  Chain.h
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import "ChainNotification.h"
#import "ChainNotificationResult.h"


// Internal read-write properties.

@interface ChainNotificationResult ()
@property(nonatomic, readwrite) NSString* type;
@property(nonatomic, readwrite) NSInteger droppedCount;
@property(nonatomic, readwrite) NSDictionary* payloadDictionary;
@property(nonatomic, readwrite) NSString* blockchain;
@end

@interface ChainNotificationNewTransaction ()
@property(nonatomic, readwrite) NSDictionary* transactionDictionary;
@end

@interface ChainNotificationNewBlock ()
@property(nonatomic, readwrite) NSDictionary* blockDictionary;
@end

@interface ChainNotificationTransaction ()
@property(nonatomic, readwrite) NSDictionary* transactionDictionary;
@end

@interface ChainNotificationAddress ()
@end




@implementation ChainNotificationResult

// Parses the response dictionary and returns an appropriate subclass.
+ (instancetype) notificationResultWithDictionary:(NSDictionary*)dict
{
    NSDictionary* payload = dict[@"payload"];

    ChainNotificationResult* result = nil;
    if ([payload[@"type"] isEqualToString:ChainNotificationTypeNewTransaction])
    {
        ChainNotificationNewTransaction* newTxResult = [[ChainNotificationNewTransaction alloc] init];
        newTxResult.type = ChainNotificationTypeNewTransaction;

        // TODO: parse and set the BTCTransaction
        newTxResult.transactionDictionary = payload[@"transaction"];

        result = newTxResult;
    }
    else if ([payload[@"type"] isEqualToString:ChainNotificationTypeNewBlock])
    {
        ChainNotificationNewBlock* newBlockResult = [[ChainNotificationNewBlock alloc] init];
        newBlockResult.type = ChainNotificationTypeNewBlock;

        // TODO: parse and set the BTCBlock
        newBlockResult.blockDictionary = payload[@"block"];

        result = newBlockResult;
    }
    else if ([payload[@"type"] isEqualToString:ChainNotificationTypeTransaction])
    {
        ChainNotificationTransaction* txResult = [[ChainNotificationTransaction alloc] init];
        txResult.type = ChainNotificationTypeTransaction;

        // TODO: parse and set the BTCTransaction
        txResult.transactionDictionary = payload[@"transaction"];

        result = txResult;
    }
    else if ([payload[@"type"] isEqualToString:ChainNotificationTypeAddress])
    {
        ChainNotificationAddress* addrResult = [[ChainNotificationAddress alloc] init];
        addrResult.type = ChainNotificationTypeAddress;

        // All info will be in payloadDictionary, see below.

        result = addrResult;
    }
    else if ([payload[@"type"] isEqualToString:ChainNotificationTypeHeartbeat])
    {
        // Ignore heartbeat messages.
        return nil;
    }
    else
    {
        NSLog(@"ChainNotificationResult: UNKNOWN TYPE RECEIVED: %@ Dictionary: %@", payload[@"type"], dict);
        return nil;
    }

    result.payloadDictionary = payload;
    result.droppedCount = [dict[@"dropped"] integerValue];
    result.blockchain = payload[@"block_chain"];
    return result;
}

@end


@implementation ChainNotificationNewTransaction
@end

@implementation ChainNotificationNewBlock
@end

@implementation ChainNotificationTransaction
@end

@implementation ChainNotificationAddress
@end
