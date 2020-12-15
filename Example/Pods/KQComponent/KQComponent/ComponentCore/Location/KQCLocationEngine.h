//
//  KQLocationManager.h
//  KuaiQianBao
//
//  Created by 张蓓 on 15-1-28.
//  Copyright (c) 2015年 Emily. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 上次定位结果

 - KQCLocationStateUnknow: 定位结果未知
 - KQCLocationStateAvailable: 定位成功
 - KQCLocationStateUnavailable: 定位失败
 */
typedef NS_ENUM(NSInteger, KQCLocationState) {
    KQCLocationStateUnknow = 0,
    KQCLocationStateSuccess,
    KQCLocationStateFailed
};

@class KQCLocationAddress;
@interface KQCLocationEngine : NSObject

#define KQC_Engine_Location    [KQCLocationEngine sharedKQCLocationEngine]

+ (KQCLocationEngine *)sharedKQCLocationEngine;

/**
 开始定位
 */
- (void)startLocationService;

/**
 开始定位
 
 @param resultBlock  定位是否成功通过此block带回结果
 */
- (void)startLocationService:(void(^)(BOOL success))resultBlock;

/**
 获取系统当前定位状态

 @return 当前状态
 */
- (BOOL)checkStatus;

/**
 纬度
 */
@property (nonatomic, strong) NSString *latitude;

/**
 经度
 */
@property (nonatomic, strong) NSString *longitude;

/**
 地址信息
 */
@property (nonatomic, strong) KQCLocationAddress *address;

/**
 定位状态
 */
@property (nonatomic, assign) KQCLocationState locateState;

FOUNDATION_EXTERN NSNotificationName const KQCLocationCurrentCityChangedNotification;

@end
