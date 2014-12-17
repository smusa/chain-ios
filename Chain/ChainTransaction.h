//
//  ChainTransaction.h
//  Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import <CoreBitcoin/CoreBitcoin.h>
#import "ChainTransactionInput.h"
#import "ChainTransactionOutput.h"

// Each transaction has the following informational properties set:
// - blockID: String
// - blockHash: NSData
// - blockHeight: Int
// - blockDate: NSDate
// - confirmations: Int
// - fee: BTCAmount
// - inputs are ChainTransactionInput objects.
// - outputs are ChainTransactionInput objects.
@interface ChainTransaction : BTCTransaction

// The UTC time at which Chain.com indexed this transaction.
@property(nonatomic) NSDate* receivedDate;

@end
