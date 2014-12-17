//
//  Chain.h
//
//  Copyright (c) 2014 Chain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTCAddress;
@class ChainTransaction;
@class ChainTransactionOutput;
@class ChainTransactionInput;
@class ChainBlock;

@interface ChainHelpers : NSObject

+ (NSString*) addressStringForAddress:(id)addr;

+ (NSArray*) addressStringsForAddresses:(NSArray*)addrs;

+ (NSArray*) addressesForAddressStrings:(NSArray*)addressStrings;

+ (ChainTransaction*) transactionWithDictionary:(NSDictionary*)dict;

+ (ChainTransaction*) transactionWithDictionary:(NSDictionary*)dict allowTruncated:(BOOL)allowTruncated;

+ (ChainTransactionInput*) transactionInputWithDictionary:(NSDictionary*)inputDict;

+ (ChainTransactionOutput*) transactionOutputWithDictionary:(NSDictionary*)outputDict;

+ (NSArray*) opreturnsWithDictionaries:(NSArray*) dicts error:(NSError**)errorOut;

+ (NSString*) blockIDForBlockArgument:(id)block;

+ (ChainBlock*) blockWithDictionary:(NSDictionary*)dict error:(NSError**)errorOut;

// Returns nil if obj is NSNull.
+ (id) filterNSNull:(id)obj;

@end
