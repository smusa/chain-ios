//
//  Chain.m
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import "Chain.h"
#import "CNURLSessionDelegate.h"

typedef enum : NSUInteger {
    ChainRequestMethodPut,
    ChainRequestMethodGet,
} ChainRequestMethod;

@interface Chain()
@property NSString *token;
@property NSURLSession *session;
@end

@implementation Chain

static Chain *sharedInstance = nil;

+ (instancetype)sharedInstanceWithToken:(NSString *)token {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Chain alloc] initWithToken:token];
        sharedInstance.blockChain = DEFAULT_BLOCK_CHAIN;
        sharedInstance.version = DEFAULT_CHAIN_VERSION;
    });
    return sharedInstance;
}

+ (instancetype)sharedInstance {
    if (sharedInstance == nil) {
        NSLog(@"%@ warning sharedInstance called before sharedInstanceWithToken:", self);
    }
    return sharedInstance;
}

- (id)initWithToken:(NSString *)token {
    if (self = [super init]) {
        self.token = token;
        self.blockChain = DEFAULT_BLOCK_CHAIN;
        self.version = DEFAULT_CHAIN_VERSION;
    }
    return self;
}

#pragma mark -

- (NSURLSession *)_newChainSession {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Accept": @"application/json",
                                                   @"Accept-Language": @"en"};
    
    CNURLSessionDelegate *sessionDelegate = [[CNURLSessionDelegate alloc] init];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:sessionDelegate delegateQueue:nil];
    return session;
}

#pragma mark - Address

- (void)getAddress:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"addresses/%@", address];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getAddresses:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *joinedAddresses = [addresses componentsJoinedByString:@","];
    [self getAddress:joinedAddresses completionHandler:completionHandler];
}

#pragma mark - Transaction By Address

- (void)getAddressTransactions:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    [self getAddressTransactions:address limit:0 completionHandler:completionHandler];
}

- (void)getAddressesTransactions:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *joinedAddresses = [addresses componentsJoinedByString:@","];
    [self getAddressTransactions:joinedAddresses limit:0 completionHandler:completionHandler];
}

- (void)getAddressTransactions:(NSString *)address limit:(NSInteger)limit completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/transactions", address];
    if (limit) {
        pathString = [pathString stringByAppendingString:[NSString stringWithFormat:@"?limit=%@", @(limit)]];
    }
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getAddressesTransactions:(NSArray *)addresses limit:(NSInteger)limit completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *joinedAddresses = [addresses componentsJoinedByString:@","];
    [self getAddressTransactions:joinedAddresses limit:limit completionHandler:completionHandler];
}

#pragma mark - Unspent Outputs By Address

- (void)getAddressUnspents:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/unspents", address];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getAddressesUnspents:(NSArray *)addresses completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *joinedAddresses = [addresses componentsJoinedByString:@","];
    [self getAddressUnspents:joinedAddresses completionHandler:completionHandler];
}

#pragma mark - OP_RETURN

- (void)getAddressOpReturns:(NSString *)address completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"addresses/%@/op-returns", address];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getBlockOpReturnsByHash:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"block/%@/op-returns", hash];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getBlockOpReturnsByHeight:(NSInteger)height completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"block/%@/op-returns", @(height)];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getLatestBlockOpReturnsWithCompletionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"block/latest/op-returns"];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getTransactionOpReturn:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"transactions/%@/op-return", hash];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

#pragma mark - Transaction

- (void)getTransaction:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"transactions/%@", hash];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}


- (void)sendTransaction:(NSString *)hex completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"transactions"];
    NSURL *url = [self _newURLWithPath:pathString];

    NSDictionary *requestDictionary = @{@"hex":hex};
    NSError *serializationError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:&serializationError];
    if (serializationError != nil) {
        completionHandler(nil, serializationError);
    } else {
        [self _startPutTaskWithRequestURL:url data:data completionHandler:completionHandler];
    }
}

#pragma mark - Block

- (void)getBlockByHash:(NSString *)hash completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"blocks/%@", hash];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getBlockByHeight:(NSInteger)height completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"blocks/%@", @(height)];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

- (void)getLatestBlockWithCompletionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    NSString *pathString = [NSString stringWithFormat:@"blocks/latest"];
    NSURL *url = [self _newURLWithPath:pathString];
    [self _startGetTaskWithRequestURL:url completionHandler:completionHandler];
}

#pragma mark - HTTP Helpers

- (NSString *)_authForPath:(NSString *)path {
    if ([path rangeOfString:@"?"].location == NSNotFound) {
        return [NSString stringWithFormat:@"?api-key-id=%@", self.token];
    } else {
        return [NSString stringWithFormat:@"&api-key-id=%@", self.token];
    }
}

- (NSURL *)_newURLWithPath:(NSString *)path {
    NSString *auth = [self _authForPath:path];
    NSString *URLString = [NSString stringWithFormat:@"%@/%@/%@/%@%@", CHAIN_BASE_URL, self.version, self.blockChain, path, auth];
    return [NSURL URLWithString:URLString];
}

-(void)_startPutTaskWithRequestURL:(NSURL *)url data:(NSData *)data completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    [self _startTaskWithRequestMethod:ChainRequestMethodPut URL:url data:data completionHandler:completionHandler];
}

-(void)_startGetTaskWithRequestURL:(NSURL *)url completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    [self _startTaskWithRequestMethod:ChainRequestMethodGet URL:url data:nil completionHandler:completionHandler];
}

-(void)_startTaskWithRequestMethod:(ChainRequestMethod)method URL:(NSURL *)url data:(NSData *)data completionHandler:(void (^)(NSDictionary *dictionary, NSError *error))completionHandler {
    
    if (!self.session) {
        self.session = [self _newChainSession];
    }

    void(^chainCompletionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSError *parseError = nil;
            
            // Prepare dictionary.
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSDictionary *jsonDictionary = nil;
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                jsonDictionary = jsonObject;
            } else if ([jsonObject isKindOfClass:[NSArray class]]) {
                jsonDictionary = @{@"results": jsonObject};
            }
            
            if (parseError) {
                completionHandler(jsonDictionary, parseError);
            } else {
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    completionHandler(jsonDictionary, nil);
                } else {
                    NSError *returnError = [NSError errorWithDomain:@"com.Chain" code:0 userInfo:jsonDictionary];
                    completionHandler(jsonDictionary, returnError);
                }
            }
        }
    };

    switch (method) {
        case ChainRequestMethodPut: {
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"PUT"];
            [[self.session uploadTaskWithRequest:urlRequest fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                chainCompletionHandler(data, response, error);
            }] resume];
        }
            break;
        case ChainRequestMethodGet: {
            [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                chainCompletionHandler(data, response, error);
            }] resume];
        }
            break;
        default:
            break;
    }
}

@end