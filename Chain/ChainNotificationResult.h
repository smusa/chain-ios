//
//  Chain.h
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChainNotificationResult : NSObject

// One of ChainNotificationType* values.
@property(nonatomic, readonly) NSString* type;

// The number of Results dropped by Chain since the last Result was delivered.
// This may occur over slow network connections.
@property(nonatomic, readonly) NSInteger droppedCount;

// Raw dictionary containing payload with specific type.
// Depending on the type you will receive a specific subclass of ChainNotificationResult with
// all relevant properties set, so you normally do not need to access this dictionary.
@property(nonatomic, readonly) NSDictionary* payloadDictionary;

// Either ChainBlockchainMainnet or ChainBlockchainTestnet
@property(nonatomic, readonly) NSString* blockchain;

// Parses the response dictionary and returns an appropriate subclass.
+ (instancetype) notificationResultWithDictionary:(NSDictionary*)dict;

@end


@interface ChainNotificationNewTransaction : ChainNotificationResult
// Transaction details
@property(nonatomic, readonly) NSDictionary* transactionDictionary;
@end


@interface ChainNotificationNewBlock : ChainNotificationResult
// Block details
@property(nonatomic, readonly) NSDictionary* blockDictionary;
@end


@interface ChainNotificationTransaction : ChainNotificationResult
// Transaction details
@property(nonatomic, readonly) NSDictionary* transactionDictionary;
@end


@interface ChainNotificationAddress : ChainNotificationResult
// Not supported yet.
@end


