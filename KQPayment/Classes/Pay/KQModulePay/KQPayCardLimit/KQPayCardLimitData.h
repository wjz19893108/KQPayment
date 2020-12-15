//
//  KQPayCardLimitData.h
//  kuaiQianbao
//
//  Created by zouf on 16/3/7.
//
//

#import <Foundation/Foundation.h>

@interface KQPayCardLimitData : NSObject

@property (nonatomic, strong, nullable) NSString *id;
@property (nonatomic, strong, nullable) NSString *bankId;
@property (nonatomic, strong, nullable) NSString *cardType;
@property (nonatomic, strong, nullable) NSString *productCode;
@property (nonatomic, strong, nullable) NSString *dayAmount;
@property (nonatomic, strong, nullable) NSString *monthAmount;
@property (nonatomic, strong, nullable) NSString *singleAmount;
@property (nonatomic, strong, nullable) NSString *payCardLimitDesc;

+ (instancetype __nullable)getPayCardLimitDataFromObj:(ContentBankLimitAmountDto* __nonnull)obj;

@end
