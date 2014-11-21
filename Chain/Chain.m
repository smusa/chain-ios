//
//  Chain.m
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import "Chain.h"
#import "ChainConnection.h"
#import <CoreBitcoin/CoreBitcoin.h>

NSString* const ChainErrorDomain = @"com.chain.error";

NSString* const ChainBlockchainMainnet = @"bitcoin";
NSString* const ChainBlockchainTestnet = @"testnet3";

NSString* const ChainAPIVersion2 = @"v2";
NSString* const ChainAPIVersion1 = @"v1";

NSString* const ChainDefaultHostname = @"api.chain.com";
NSString* const ChainDefaultWebSocketHostname = @"ws.chain.com";

@interface Chain()
@property(nonatomic) NSString *token;
@property(nonatomic) ChainConnection *connection;
@end

@implementation Chain

static Chain *sharedInstance = nil;

+ (instancetype)sharedInstanceWithToken:(NSString *)token {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Chain alloc] initWithToken:token];
    });
    return sharedInstance;
}

+ (instancetype)sharedInstance {
    if (sharedInstance == nil) {
        [NSException raise:@"ChainException" format:@"Called +sharedInstance before specifying token with +sharedInstanceWithToken:"];
    }
    return sharedInstance;
}

- (id)initWithToken:(NSString *)token {
    if (self = [super init]) {

        self.connection = [[ChainConnection alloc] init];
        self.connection.hostname = ChainDefaultHostname;
        self.connection.webSocketHostname = ChainDefaultWebSocketHostname;
        self.token = token;
        self.blockchain = ChainBlockchainMainnet;
        self.version = ChainAPIVersion2;
    }
    return self;
}

- (void) setToken:(NSString *)token {
    _token = token;
    self.connection.token = _token;
}

- (void) setBlockchain:(NSString *)blockchain
{
    _blockchain = blockchain;
    self.connection.blockchain = blockchain;
}

- (void) setVersion:(NSString *)version
{
    _version = version;
    self.connection.version = version;
}


#pragma mark - Address

- (void)getAddress:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"addresses/%@", address];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getAddresses:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *joinedAddresses = [addresses componentsJoinedByString:@","];
    [self getAddress:joinedAddresses completionHandler:completionHandler];
}

#pragma mark - Transaction By Address

- (void)getAddressTransactions:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    [self getAddressTransactions:address limit:0 completionHandler:completionHandler];
}

- (void)getAddressesTransactions:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *joinedAddresses = [addresses componentsJoinedByString:@","];
    [self getAddressTransactions:joinedAddresses limit:0 completionHandler:completionHandler];
}

- (void)getAddressTransactions:(NSString *)address limit:(NSInteger)limit completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/transactions", address];
    if (limit) {
        pathString = [pathString stringByAppendingString:[NSString stringWithFormat:@"?limit=%@", @(limit)]];
    }
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getAddressesTransactions:(NSArray *)addresses limit:(NSInteger)limit completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *joinedAddresses = [addresses componentsJoinedByString:@","];
    [self getAddressTransactions:joinedAddresses limit:limit completionHandler:completionHandler];
}

#pragma mark - Unspent Outputs By Address

- (void)getAddressUnspents:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/unspents", address];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getAddressesUnspents:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *joinedAddresses = [addresses componentsJoinedByString:@","];
    [self getAddressUnspents:joinedAddresses completionHandler:completionHandler];
}

#pragma mark - OP_RETURN

- (void)getAddressOpReturns:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/op-returns", address];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getBlockOpReturnsByHash:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"block/%@/op-returns", hash];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getBlockOpReturnsByHeight:(NSInteger)height completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"block/%@/op-returns", @(height)];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getLatestBlockOpReturnsWithCompletionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"block/latest/op-returns"];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getTransactionOpReturn:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"transactions/%@/op-return", hash];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

#pragma mark - Transaction

- (void)getTransaction:(NSString *)txid completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"transactions/%@", txid];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}


- (void)sendTransaction:(id)tx completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"transactions/send"];
    NSURL *url = [self.connection URLWithPath:pathString];

    // If BTCTransaction provided, convert to hex.
    if ([tx isKindOfClass:[BTCTransaction class]]) {
        tx = ((BTCTransaction*)tx).data;
    }

    // If NSData provided, convert to hex.
    if ([tx isKindOfClass:[NSData class]]) {
        tx = BTCHexStringFromData(tx);
    }

    NSDictionary *requestDictionary = nil;

    // If hex string provided, wrap it in {signed_hex: ...} dictionary.
    if ([tx isKindOfClass:[NSString class]]) {
        requestDictionary = @{@"signed_hex": tx};
    } else {
        // Template is dictionary, send as-is.
        requestDictionary = tx;
    }

    [self.connection startPostTaskWithURL:url dictionary:requestDictionary completionHandler:completionHandler];
}


#pragma mark - Block


- (void)getBlockByHash:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"blocks/%@", hash];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getBlockByHeight:(NSInteger)height completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"blocks/%@", @(height)];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}

- (void)getLatestBlockWithCompletionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"blocks/latest"];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:completionHandler];
}


@end