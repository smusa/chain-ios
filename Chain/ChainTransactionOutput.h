//
//  ChainTransactionOutput.h
//  Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import <CoreBitcoin/CoreBitcoin.h>

// Each output instance has the following informational properties set:
// - index: Int (index in its transaction)
// - confirmations: Int
// - spent: Bool
@interface ChainTransactionOutput : BTCTransactionOutput

// Array of BTCAddress instances (addresses used in the output).
@property(nonatomic) NSArray* addresses;

@end
