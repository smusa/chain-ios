//
//  ChainBlock.h
//  Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import <CoreBitcoin/CoreBitcoin.h>

@interface ChainBlock : BTCBlockHeader

// List of NSData objects representing transaction hashes.
@property(nonatomic) NSArray* transactionHashes;

// List of NSString objects representing transaction IDs.
@property(nonatomic) NSArray* transactionIDs;

@end

