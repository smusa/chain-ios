//
//  Chain.h
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBitcoin/CoreBitcoin.h>

#import "ChainNotification.h"
#import "ChainNotificationResult.h"
#import "ChainNotificationObserver.h"

extern NSString* const ChainErrorDomain;

extern NSString* const ChainBlockchainMainnet;
extern NSString* const ChainBlockchainTestnet;

extern NSString* const ChainAPIVersion2;
extern NSString* const ChainAPIVersion1;

@interface Chain : NSObject

// Bitcoin blockchain being used.
// Use ChainBlockchainMainnet or ChainBlockchainTestnet.
// Default is mainnet.
@property(nonatomic) NSString *blockchain;

// API version to be used.
// Default is v2.
@property(nonatomic) NSString *version;

// Access shared Chain instance and specify the token.
// Call this method before calling `+sharedInstance`.
+ (instancetype)sharedInstanceWithToken:(NSString *)token;

// Use this method to access shared Chain instance this after specifying the token with `+sharedInstanceWithToken:`.
+ (instancetype)sharedInstance;

// Creates Chain instance with a given token.
- (id)initWithToken:(NSString *)token;


#pragma mark - Address

- (void)getAddress:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getAddresses:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;


#pragma mark - Transaction By Address

- (void)getAddressTransactions:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getAddressesTransactions:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getAddressTransactions:(NSString *)address limit:(NSInteger)limit completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getAddressesTransactions:(NSArray *)addresses limit:(NSInteger)limit completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;


#pragma mark - Unspent Outputs By Address

- (void)getAddressUnspents:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getAddressesUnspents:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;


#pragma mark - OP_RETURN

- (void)getAddressOpReturns:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getTransactionOpReturn:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getBlockOpReturnsByHash:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getBlockOpReturnsByHeight:(NSInteger)height completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getLatestBlockOpReturnsWithCompletionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;


#pragma mark - Transaction

- (void)getTransaction:(NSString *)txhash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;

// Sends transaction represented as one of the following:
// - BTCTransaction
// - NSData (raw binary)
// - NSString (raw binary in hex)
// - NSDictionary (signed tx template)
- (void)sendTransaction:(id)tx completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;


#pragma mark - Transaction Builder

// Builds, signs and sends transaction in one call.
// Response is the same as from `-sendTransaction:completionHandler:` call.
// params[@"inputs"] should contain @{@"address": <base58-encoded address>,
//                                    @"private_key": <hex|WIF|BTCKey>}
// params[@"outputs"] should contain @{@"address": <base58-encoded address>,
//                                     @"amount": @(satoshis)}
- (void) transact:(NSDictionary*)params completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;

// Makes a request to build a transaction with given parameters.
- (void) buildTransaction:(NSDictionary*)params completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;

// Signs transaction template received from `-buildTransaction:completionHandler:`
// with the given keys and sends the result to Chain to complete transaction.
- (NSDictionary*) signTransactionTemplate:(NSDictionary*)template keys:(NSArray* /* {"private_key": <BTCKey> or <WIF NSString> } */)keys;



#pragma mark - Block

- (void)getBlockByHash:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getBlockByHeight:(NSInteger)height completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;
- (void)getLatestBlockWithCompletionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler;


#pragma mark - Notifications

// Returns an observer that connects to Chain and begins receiving events.
// Call 'disconnect' on observer instance to stop receiving notifications.
- (ChainNotificationObserver*) observerForNotification:(ChainNotification*)notification;
- (ChainNotificationObserver*) observerForNotification:(ChainNotification*)notification resultHandler:(void(^)(ChainNotificationResult*))resultHandler;
- (ChainNotificationObserver*) observerForNotifications:(NSArray*)notifications;
- (ChainNotificationObserver*) observerForNotifications:(NSArray*)notifications resultHandler:(void(^)(ChainNotificationResult*))resultHandler;


@end
