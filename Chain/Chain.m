//
//  Chain.m
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import "Chain.h"
#import "ChainConnection.h"
#import "ChainSigner.h"
#import <CoreBitcoin/CoreBitcoin.h>
#import <ISO8601DateFormatter.h>

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


- (void)getAddress:(id)address completionHandler:(void (^)(ChainAddressInfo *addressInfo, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(address != nil);
    [self getAddresses:@[ address ] completionHandler:^(NSArray *addressInfos, NSError *error) {
        if (addressInfos) {
            completionHandler(addressInfos.firstObject, nil);
        } else {
            completionHandler(nil, error);
        }
    }];
}

- (void)getAddresses:(NSArray *)addresses completionHandler:(void (^)(NSArray *addressInfos, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(addresses != nil);

    NSString* addr = [[self addressStringsForAddresses:addresses] componentsJoinedByString:@","];
    NSString *pathString = [NSString stringWithFormat:@"addresses/%@", addr];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:^(NSDictionary *dictionary, NSError *error) {

        if (!dictionary) {
            completionHandler(nil, error);
            return;
        }

        NSMutableArray* results = [NSMutableArray array];

        for (NSDictionary* dict in dictionary[@"results"] ?: @[dictionary]) {
            ChainAddressInfo* addrInfo = [[ChainAddressInfo alloc] initWithDictionary:dict];
            if (addrInfo) [results addObject:addrInfo];
        }
        completionHandler(results, nil);
    }];
}



#pragma mark - Transactions By Address


- (void) getAddressTransactions:(id)address completionHandler:(void (^)(NSArray *transactions, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(address != nil);
    [self getAddressesTransactions:@[address] limit:0 completionHandler:completionHandler];
}

- (void) getAddressesTransactions:(NSArray *)addresses completionHandler:(void (^)(NSArray *transactions, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(addresses != nil);
    [self getAddressesTransactions:addresses limit:0 completionHandler:completionHandler];
}

- (void)getAddressTransactions:(id)address limit:(NSInteger)limit completionHandler:(void (^)(NSArray *transactions, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(address != nil);
    [self getAddressesTransactions:@[address] limit:0 completionHandler:completionHandler];
}

- (void)getAddressesTransactions:(NSArray *)addresses limit:(NSInteger)limit completionHandler:(void (^)(NSArray *transactions, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(addresses != nil);

    NSString* addrs = [[self addressStringsForAddresses:addresses] componentsJoinedByString:@","];
    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/transactions", addrs];
    if (limit > 0) {
        pathString = [pathString stringByAppendingString:[NSString stringWithFormat:@"?limit=%@", @(limit)]];
    }

    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:^(NSDictionary *dictionary, NSError *error) {
        if (!dictionary) {
            completionHandler(nil, error);
            return;
        }

        NSMutableArray* results = [NSMutableArray array];

        // This will be our semaphore for async calls.
        // There will be no racing conditions since all callbacks land on main queue.
        __block int loadingTxsCount = 0;

        for (NSDictionary* txdict in dictionary[@"results"]) {
            BTCTransaction* tx = [self transactionWithDictionary:txdict allowTruncated:YES];
            if (tx) {
                [results addObject:tx];
            } else {

                // Tx has probably truncated number of inputs and outputs.
                // Lets fetch it with getTransaction API.
                // Note: these calls will run in parallel, but will finish on main thread (in random order).

                // Remember position using a placeholder transaction.
                [results addObject:[[BTCTransaction alloc] init]];
                NSUInteger txindex = results.count - 1;

                loadingTxsCount++;
                NSLog(@"Chain: transaction is truncated, loading full data separately: %@ [#%@]", txdict[@"hash"], @(loadingTxsCount));
                [self getTransaction:txdict[@"hash"] completionHandler:^(BTCTransaction *fullTx, NSError *error) {

                    // If some other callback cancelled and returned, do nothing.
                    if (loadingTxsCount == 0) return;

                    loadingTxsCount--;

                    // If we fail to fetch a single tx, return immediately.
                    if (!fullTx) {
                        loadingTxsCount = 0;
                        completionHandler(nil, error);
                        return;
                    }

                    results[txindex] = fullTx;

                    if (loadingTxsCount == 0) {
                        completionHandler(results, nil);
                    }
                }];
            }
        }

        // If all transactions are already here, return immediately.
        if (loadingTxsCount == 0) {
            completionHandler(results, nil);
        }
    }];
}



#pragma mark - Unspent Outputs By Address



- (void)getAddressUnspents:(id)address completionHandler:(void (^)(NSArray *unspentOutputs, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(address != nil);

    [self getAddressesUnspents:@[address] completionHandler:completionHandler];
}

- (void)getAddressesUnspents:(NSArray *)addresses completionHandler:(void (^)(NSArray *unspentOutputs, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(addresses != nil);

    NSString *addrs = [[self addressStringsForAddresses:addresses] componentsJoinedByString:@","];
    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/unspents", addrs];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:^(NSDictionary *dictionary, NSError *error) {

        if (!dictionary) {
            completionHandler(nil, error);
            return;
        }

        NSMutableArray* results = [NSMutableArray array];
        for (NSDictionary* txoutdict in dictionary[@"results"]) {
            BTCTransactionOutput* txout = [self transactionOutputWithDictionary:txoutdict];
            [results addObject:txout];
        }

        completionHandler(results, nil);
    }];
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


- (void)getTransaction:(id)txhash completionHandler:(void (^)(BTCTransaction *transaction, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert(txhash != nil);
    NSParameterAssert([txhash isKindOfClass:[NSString class]] || [txhash isKindOfClass:[NSData class]]);

    if ([txhash isKindOfClass:[NSData class]]) {
        txhash = BTCIDFromHash(txhash);
    }

    NSString *pathString = [NSString stringWithFormat:@"transactions/%@", txhash];
    NSURL *url = [self.connection URLWithPath:pathString];
    [self.connection startGetTaskWithURL:url completionHandler:^(NSDictionary *dictionary, NSError *error) {
        if (!dictionary) {
            completionHandler(nil, error);
            return;
        }
        BTCTransaction* tx = [self transactionWithDictionary:dictionary];
        NSAssert(tx, @"Should parse transaction correctly");
        completionHandler(tx, nil);
    }];
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



#pragma mark - Transaction Builder


// Builds, signs and sends transaction in one call.
// Response is the same as from `-sendTransaction:completionHandler:` call.
// {
//   inputs: [ {
//       private_key: "568fjdk2..." or BTCKey
//     }, {
//       private_key: "5fi654kd.." or BTCKey
//     }
//   ],
//   outputs: [ {
//       address: "1f72j...",
//       amount: 60000
//     }, {
//       address: "14g37...",
//       amount: 80000
//     }
//   ]
// }
- (void) transact:(NSDictionary*)params completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler
{
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert([params[@"inputs"] isKindOfClass:[NSArray class]]);
    NSParameterAssert([params[@"outputs"] isKindOfClass:[NSArray class]]);

    ChainSigner* signer = [[ChainSigner alloc] initWithBlockchain:self.blockchain];
    NSDictionary* keysMap = [signer extractKeysFromInputs:params[@"inputs"]];

    if (!keysMap)
    {
        [NSException raise:@"ChainException" format:@"-transact: inputs must contain private keys"];
    }

    NSMutableDictionary* params2 = [params mutableCopy];
    NSMutableArray* inputs = [NSMutableArray array];
    for (NSString* address in keysMap) {
        [inputs addObject:@{@"address": address}];
    }
    params2[@"inputs"] = inputs;

    [self buildTransaction:params2 completionHandler:^(NSDictionary *template, NSError *error) {

        if (!template) {
            completionHandler(nil, error);
            return;
        }
        NSDictionary* signedTemplate = [signer signTemplate:template keys:keysMap];
        [self sendTransaction:signedTemplate completionHandler:completionHandler];
    }];
}

// Makes a request to build a transaction with given parameters.
- (void) buildTransaction:(NSDictionary*)params completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler
{
    NSParameterAssert(completionHandler != nil);
    NSParameterAssert([params[@"inputs"] isKindOfClass:[NSArray class]]);
    NSParameterAssert([params[@"outputs"] isKindOfClass:[NSArray class]]);

    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    body[@"inputs"] = params[@"inputs"];
    body[@"outputs"] = params[@"outputs"];
    if (params[@"change_address"])    body[@"change_address"]    = params[@"change_address"];
    if (params[@"miner_fee_rate"])    body[@"miner_fee_rate"]    = params[@"miner_fee_rate"];
    if (params[@"min_confirmations"]) body[@"min_confirmations"] = params[@"min_confirmations"];

    NSURL *url = [self.connection URLWithPath:@"transactions/build"];

    [self.connection startPostTaskWithURL:url dictionary:body completionHandler:completionHandler];
}

// Signs transaction template received from `-buildTransaction:completionHandler:`
// with the given keys and returns the same structure with signatures filled in.
- (NSDictionary*) signTransactionTemplate:(NSDictionary*)template keys:(NSArray* /* {"private_key": <BTCKey> or <WIF NSString> } */)keys
{
    NSParameterAssert(template != nil);
    NSParameterAssert(keys != nil);

    ChainSigner* signer = [[ChainSigner alloc] initWithBlockchain:self.blockchain];
    NSDictionary* keysMap = [signer extractKeysFromInputs:keys];

    return [signer signTemplate:template keys:keysMap];
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





#pragma mark - Notifications


- (ChainNotificationObserver*) observerForNotification:(ChainNotification*)notification
{
    return [self observerForNotification:notification resultHandler:nil];
}

- (ChainNotificationObserver*) observerForNotification:(ChainNotification*)notification resultHandler:(void(^)(ChainNotificationResult*))resultHandler
{
    NSParameterAssert(notification);

    return [self observerForNotifications:@[ notification ] resultHandler:resultHandler];
}

- (ChainNotificationObserver*) observerForNotifications:(NSArray*)notifications
{
    return [self observerForNotifications:notifications resultHandler:nil];
}

- (ChainNotificationObserver*) observerForNotifications:(NSArray*)notifications resultHandler:(void(^)(ChainNotificationResult*))resultHandler
{
    NSParameterAssert(notifications);

    ChainNotificationObserver* observer = [[ChainNotificationObserver alloc] initWithNotifications:notifications connection:self.connection];
    observer.resultHandler = resultHandler;
    [observer connect];
    return observer;
}



#pragma mark - Helpers


- (NSString*) addressStringForAddress:(id)addr
{
    if ([addr isKindOfClass:[BTCAddress class]])
    {
        return ((BTCAddress*)addr).base58String;
    }
    else if ([addr isKindOfClass:[NSString class]])
    {
        return addr;
    }
    else
    {
        [NSException raise:@"Chain: unsupported address type"
                    format:@"Addresses must be of type NSString or BTCAddress. Unsupported type detected: %@", [addr class]];
    }
    return nil;
}

- (NSArray*) addressStringsForAddresses:(NSArray*)addrs
{
    NSMutableArray* addrStrings = [NSMutableArray array];
    for (id addr in addrs) {
        NSString* s = [self addressStringForAddress:addr];
        [addrStrings addObject:s];
    }
    return addrStrings;
}

- (NSArray*) addressesForAddressStrings:(NSArray*)addressStrings
{
    NSMutableArray* addresses = [NSMutableArray array];
    for (id str in addressStrings)
    {
        BTCAddress* addr = [BTCAddress addressWithBase58String:str];
        if (addr) [addresses addObject:addr];
    }
    return addresses;
}

- (BTCTransaction*) transactionWithDictionary:(NSDictionary*)dict
{
    return [self transactionWithDictionary:dict allowTruncated:NO];
}

- (BTCTransaction*) transactionWithDictionary:(NSDictionary*)dict allowTruncated:(BOOL)allowTruncated
{
    // Will be used below to check that we constructed transaction correctly.
    NSData* receivedHash = BTCHashFromID(dict[@"hash"]);

    BTCTransaction* tx = [[BTCTransaction alloc] init];

    tx.lockTime = [dict[@"lock_time"] unsignedIntValue];

    for (NSDictionary* inputDict in dict[@"inputs"]) {
        BTCTransactionInput* txin = [self transactionInputWithDictionary:inputDict];
        [tx addInput:txin];
    }

    for (NSDictionary* outputDict in dict[@"outputs"]) {
        BTCTransactionOutput* txout = [self transactionOutputWithDictionary:outputDict];
        [tx addOutput:txout];
    }

    // Check that hash of the resulting tx is the same as received one.
    if (![tx.transactionHash isEqual:receivedHash]) {
        if (!allowTruncated)
        {
            NSLog(@"Chain: received transaction %@ and failed to build a proper binary copy. Could be non-canonical PUSHDATA somewhere. Dictionary: %@", dict[@"hash"], dict);
            NSAssert([tx.transactionHash isEqual:receivedHash], @"Transaction hash must match.");
        }
        return nil;
    }

    ISO8601DateFormatter* dateFormatter = [[ISO8601DateFormatter alloc] init];

    tx.blockHash = BTCHashFromID(dict[@"block_hash"]);
    tx.blockHeight = [dict[@"block_height"] integerValue];
    tx.blockDate = [dateFormatter dateFromString:dict[@"block_time"]];
    tx.confirmations = [dict[@"confirmations"] integerValue];
    if (dict[@"fees"]) {
        tx.fee = [dict[@"fees"] longLongValue];
    }

    NSDate* chainReceivedDate = (dict[@"chain_received_at"] != [NSNull null]) ? [dateFormatter dateFromString:dict[@"chain_received_at"]] : nil;

    if (chainReceivedDate) {
        tx.userInfo = @{
            @"chain_received_at": chainReceivedDate,
        };
    }
    return tx;
}

- (BTCTransactionInput*) transactionInputWithDictionary:(NSDictionary*)inputDict
{
    BTCTransactionInput* txin = [[BTCTransactionInput alloc] init];

    if (!inputDict[@"script_signature"] && inputDict[@"coinbase"])
    {
        txin.coinbaseData = BTCDataWithHexString(inputDict[@"coinbase"]);
    }
    else
    {
        txin.previousTransactionID = inputDict[@"output_hash"];
        txin.previousIndex = [inputDict[@"output_index"] unsignedIntValue];
        txin.signatureScript = [[BTCScript alloc] initWithString:inputDict[@"script_signature"]];
        NSAssert(txin.signatureScript, @"Must have non-nil script signature");
    }

    txin.sequence = [inputDict[@"sequence"] unsignedIntValue];

    txin.userInfo = @{
                      @"addresses": [self addressesForAddressStrings:inputDict[@"addresses"]],
                      };
    txin.value = [inputDict[@"value"] longLongValue];
    return txin;
}

- (BTCTransactionOutput*) transactionOutputWithDictionary:(NSDictionary*)outputDict
{
    BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
    txout.value = [outputDict[@"value"] longLongValue];
    txout.script = [[BTCScript alloc] initWithData:BTCDataWithHexString(outputDict[@"script_hex"])];
    txout.userInfo = @{
                       @"addresses": [self addressesForAddressStrings:outputDict[@"addresses"]],
                       };
    txout.spent = [outputDict[@"spent"] boolValue];

    // Available in unspents API
    if (outputDict[@"confirmations"] && outputDict[@"confirmations"] != [NSNull null]) {
        txout.confirmations = [outputDict[@"confirmations"] unsignedIntegerValue];
    }

    // Available in unspents API
    if (outputDict[@"output_index"] && outputDict[@"output_index"] != [NSNull null]) {
        txout.index = [outputDict[@"output_index"] unsignedIntValue];
    }
    return txout;
}



@end