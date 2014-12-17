//
//  ChainTransactionInput.h
//  Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import <CoreBitcoin/CoreBitcoin.h>

// Every ChainTransactionInput instance has value property set to a value associated with its output.
@interface ChainTransactionInput : BTCTransactionInput

// Array of BTCAddress instances (addresses used in the input).
@property(nonatomic) NSArray* addresses;

@end
