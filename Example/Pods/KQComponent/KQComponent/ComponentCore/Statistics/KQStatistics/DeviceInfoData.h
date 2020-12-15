//
//  DeviceInfoData.h
//  kuaiQianbao
//
//  Created by 陈屹东 on 16/4/18.
//
//

#import <Foundation/Foundation.h>

@interface DeviceInfoData : NSObject

@property (nonatomic, assign) BOOL ismobiledevice;
@property (nonatomic, assign) BOOL havebt;
@property (nonatomic, assign) BOOL havewifi;
@property (nonatomic, assign) BOOL havegps;
@property (nonatomic, assign) BOOL havegravity;

@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *language;

@property (nonatomic, strong) NSString *phonetype;
@property (nonatomic, strong) NSString *imsi;
@property (nonatomic, strong) NSString *modulename;
@property (nonatomic, strong) NSString *wifimac;
@property (nonatomic, strong) NSString *imei;

/**
 APP版本号
 */
@property (nonatomic, strong) NSString *version;

/**
 iOS系统版本号
 */
@property (nonatomic, strong) NSString *osVersion;

/**
 手机型号
 */
@property (nonatomic, strong) NSString *devicename;

/**
 SIM卡运营商信息
 */
@property (nonatomic, strong) NSString *mccmnc;

/**
 设备号，区分设备唯一标识
 */
@property (nonatomic, strong) NSString *deviceId;

/**
 手机像素
 */
@property (nonatomic, strong) NSString *resolution;

@end
