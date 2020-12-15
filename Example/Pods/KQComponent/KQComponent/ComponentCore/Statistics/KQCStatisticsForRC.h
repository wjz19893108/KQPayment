//
//  KQCStatisticsForRC.h
//  KQCusiness
//
//  Created by lihui on 17/1/4.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQCStatisticsForRC : NSObject

+ (KQCStatisticsForRC *)sharedKQCStatisticsForRC;

- (void)setKey:(NSString *)key;
- (void)logEventForRC:(NSString *)eventID;  //自建风控埋点实时上送，上送行为数据
- (void)logEventLoginForRC:(NSString *)eventID;  //自建登录风控埋点实时上送，上送行为数据
@end
