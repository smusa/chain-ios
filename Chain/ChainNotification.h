//
//  Chain.h
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const ChainNotificationTypeAddress;
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

// Only for ChainNotificationTypeAddress.
@property(nonatomic) NSString* address;

// Instantiates a notification with a given type.
- (id) initWithType:(NSString*)type;

// Instantiates a notification with type "transaction" watching
// for a transaction with a given ID.
- (id) initWithTransactionID:(NSString*)txid;

// Instantiates a notification with type "address" watching for a given address.
- (id) initWithAddress:(NSString*)address;

// Dictionary representation suitable for network requests.
- (NSDictionary*) dictionary;

@end
