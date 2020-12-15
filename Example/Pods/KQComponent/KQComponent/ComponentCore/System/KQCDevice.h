//
//  KQCDeviceEngine.h
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQCDeviceType) {
    KQCDeviceTypeUnknown = 0,
    KQCDeviceTypeSimulator,
    KQCDeviceTypeIPhone4,
    KQCDeviceTypeIPhone4S,
    KQCDeviceTypeIPhone5,
    KQCDeviceTypeIPhone5C,
    KQCDeviceTypeIPhone5S,
    KQCDeviceTypeIPhoneSE,
    KQCDeviceTypeIPhone6,
    KQCDeviceTypeIPhone6P,
    KQCDeviceTypeIPhone6S,
    KQCDeviceTypeIPhone6SP,
    KQCDeviceTypeIPhone7,
    KQCDeviceTypeIPhone7P,
    KQCDeviceTypeIPhone8,
    KQCDeviceTypeIPhone8P,
    KQCDeviceTypeIPhoneX,
};

@interface KQCDevice : NSObject

/**
 指定缓存deviceId的key，为了兼容架构2.0之前的版本

 @param deviceIdKey 指定的key
 */
+ (void)initializeConfig:(NSString *)deviceIdKey;

/**
 获取设备唯一标示

 @return 唯一标示
 */
+ (NSString *)deviceId;

/**
 获取设备是那种类型的iPhone

 @return iPhone的类型
 */
+ (KQCDeviceType)deviceType;

/**
 屏幕是否有刘海，即是否为iPhoneX及以后的手机
 
 @return YES：有 NO：没有
 */
+ (BOOL)hasScreenNotch;

/**
 *  获取mac地址
 *
 *  @return mac地址
 */
+ (NSString *)macAddress;

/**
 获取当前ip地址

 @return ip地址
 */
+ (NSString *)deviceIPAddress;

/**
 设备信息，包括wifiName,wifiMac,osVersion,屏幕宽高

 @return 设备信息字典
 */
+ (NSDictionary *)deviceInfoDic;

/**
 设备型号
 
 @return 设备型号字符串
 */
+ (NSString *)deviceInfo;

/**
 wifi信息
 
 @return wifi信息字典
 */
+ (NSDictionary *)fetchSSIDInfo;

/**
 获取手机硬盘大小

 @return 字典中available代表剩余硬盘空间，total代表总共硬盘空间
 */
+ (NSDictionary *)fetchDiskSizeInfo;

FOUNDATION_EXTERN NSNotificationName const KQCDeviceTimeOutOfRangeNotification;

@end
