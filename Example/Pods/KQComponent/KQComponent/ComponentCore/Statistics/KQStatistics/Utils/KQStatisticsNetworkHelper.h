//
//  KQStatisticsNetworkHelper.h
//  KQComponent
//
//  Created by wangping on 2018/6/11.
//

#import <Foundation/Foundation.h>


typedef void(^SuccessStatisticsBlock)(NSData *responseData, NSDictionary *responseHeader);

typedef void(^FailedStatisticsBlock)(NSError *error, NSInteger httpStatusCode);


/**
 埋点策略

 - KQStatisticsPolicyTypeNormal: 普通埋点
 - KQStatisticsPolicyTypeRealTime: 实时埋点
 */
typedef NS_ENUM(NSInteger, KQStatisticsPolicyType) {
    KQStatisticsPolicyTypeNormal = 0,
    KQStatisticsPolicyTypeRealTime,
};

@interface KQStatisticsNetworkHelper : NSObject

+ (NSString*)networkType;

+ (KQStatisticsNetworkHelper *)shareInstance;

- (void)sendHttpRequest:(NSData *)data policy:(KQStatisticsPolicyType)policyType successBlock:(SuccessStatisticsBlock)successBlock failedBlock:(FailedStatisticsBlock)failedBlock;

@end
