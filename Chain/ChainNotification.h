//
//  Chain.h
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const ChainNotificationTypeAddress; // (not support for now)
extern NSString* const ChainNotificationTypeTransaction;
extern NSString* const ChainNotificationTypeNewTransaction;
extern NSString* const ChainNotificationTypeNewBlock;
extern NSString* const ChainNotificationTypeHeartbeat; // can be received from time to time

@interface ChainNotification : NSObject

// One of ChainNotificationType{Address,Transaction,NewTransaction,NewBlock}
@property(nonatomic,readonly) NSString* type;

// ChainBlockchainMainnet by default.
@property(nonatomic) NSString* blockchain;

// Only for ChainNotificationTypeTransaction.
@property(nonatomic) NSString* transactionID;

// Instantiates a notification with a given type.
- (id) initWithType:(NSString*)type;

/// Instantiates a notification with type "transaction" watching
/// for transaction with a given ID.
- (id) initWithTransactionID:(NSString*)txid;

/// Dictionary representation suitable for network requests.
- (NSDictionary*) dictionary;

@end
