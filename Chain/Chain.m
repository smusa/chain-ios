//
//  Chain.m
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import "Chain.h"
#import "ChainConnection.h"
#import "ChainSigner.h"
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

    NSString* addr = [[self addressStringsForAddresses:addresses] componentsJoinedByString:@","];
    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/transactions", addr];
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

        for (NSDictionary* txdict in dictionary[@"results"]) {
            BTCTransaction* tx = [self transactionWithDictionary:txdict];
            if (tx) [results addObject:tx];
        }
        completionHandler(results, nil);
    }];
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

- (void)getTransaction:(NSString *)txhash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);

    NSString *pathString = [NSString stringWithFormat:@"transactions/%@", txhash];
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


- (NSArray*) addressStringsForAddresses:(NSArray*)addrs
{
    NSMutableArray* addrStrings = [NSMutableArray array];
    for (id addr in addrs) {
        if ([addr isKindOfClass:[BTCAddress class]])
        {
            [addrStrings addObject:((BTCAddress*)addr).base58String];
        }
        else if ([addr isKindOfClass:[NSString class]])
        {
            [addrStrings addObject:addr];
        }
        else
        {
            [NSException raise:@"Chain: unsupported address type"
                        format:@"Addresses must be of type NSString or BTCAddress. Unsupported type detected: %@", [addr class]];
        }
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
    // Will be used below to check that we constructed transaction correctly.
    NSData* receivedHash = BTCTransactionHashFromID(dict[@"hash"]);

    BTCTransaction* tx = [[BTCTransaction alloc] init];

    for (NSDictionary* inputDict in dict[@"inputs"])
    {
        BTCTransactionInput* txin = [[BTCTransactionInput alloc] init];
        txin.previousTransactionID = inputDict[@"output_hash"];
        txin.previousIndex = [inputDict[@"output_index"] unsignedIntValue];
        txin.userInfo = @{@"addresses": [self addressesForAddressStrings:inputDict[@"addresses"]] };

        //   if !input_dict["script_signature"] && input_dict["coinbase"]
        //     txin.coinbase_data = BTC::Data.data_from_hex(input_dict["coinbase"])
        //   else
        //     parts = input_dict["script_signature"].split(" ").map do |part|
        //       if part.to_i.to_s == part // support "0" prefix.
        //         BTC::Opcode.opcode_for_small_integer(part.to_i)
        //       else
        //         BTC::Data.data_from_hex(part)
        //       end
        //     end
        //     txin.signature_script = (BTC::Script.new << parts)
        //   end
        //   txin.value = input_dict["value"].to_i
        [tx addInput:txin];
    }

    for (NSDictionary* outputDict in dict[@"outputs"]) {
        BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
        txout.value = [outputDict[@"value"] longLongValue];
        //   txout.script = BTC::Script.with_data(BTC::Data.data_from_hex(output_dict["script_hex"]))
        //   txout.spent = output_dict["spent"]
        //   txout.addresses = (output_dict["addresses"] || []).map{|a| BTC::Address.with_string(a) }
        [tx addOutput:txout];
    }

    // Check that hash of the resulting tx is the same as received one.
    if (![tx.transactionHash isEqual:receivedHash]) {
        NSLog(@"Chain: received transaction %@ and failed to build proper binary copy. Could be non-canonical PUSHDATA somewhere. Dictionary: %@", dict[@"hash"], dict);
        return nil;
    }

    // tx.block_hash = BTC.hash_from_id(dict["block_hash"]) // block hash is reversed hex like txid.
    // tx.block_height = dict["block_height"].to_i
    // tx.block_time = dict["block_time"] ? Time.parse(dict["block_time"]) : nil
    // tx.confirmations = dict["confirmations"].to_i
    // tx.fee = dict["fees"] ? dict["fees"].to_i : nil
    // tx.chain_received_at = dict["chain_received_at"] ? Time.parse(dict["chain_received_at"]) : nil
    // tx
    return tx;
}

@end