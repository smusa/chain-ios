//
//  ChainBlock.m
//  Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import "ChainBlock.h"

@implementation ChainBlock

@synthesize transactionIDs=_transactionIDs;
@synthesize transactionHashes=_transactionHashes;

- (void) setTransactionIDs:(NSArray *)transactionIDs {
    _transactionIDs = transactionIDs;
    _transactionHashes = nil;
}

- (void) setTransactionHashes:(NSArray *)transactionHashes {
    _transactionIDs = nil;
    _transactionHashes = transactionHashes;
}

- (NSArray*) transactionHashes {
    if (!_transactionHashes && _transactionIDs) {
        NSMutableArray* txhashes = [NSMutableArray array];
        for (NSString* txid in _transactionIDs) {
            [txhashes addObject:BTCHashFromID(txid)];
        }
        _transactionHashes = txhashes;
    }
    return _transactionHashes;
}

- (NSArray*) transactionIDs {
    if (!_transactionIDs && _transactionHashes) {
        NSMutableArray* txids = [NSMutableArray array];
        for (NSData* txhash in _transactionHashes) {
            [txids addObject:BTCIDFromHash(txhash)];
        }
        _transactionIDs = txids;
    }
    return _transactionIDs;
}

@end
