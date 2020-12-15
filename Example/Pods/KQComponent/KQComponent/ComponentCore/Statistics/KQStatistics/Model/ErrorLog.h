//
//  ErrorLog.h
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import <Foundation/Foundation.h>
#import "DeviceInfoData.h"

@interface ErrorLog : NSObject<NSCoding>

@property (nonatomic,strong) NSString *stacktrace;   //发生exception步骤日志（数组形式）
@property (nonatomic,strong) NSString *time;            //时间
@property (nonatomic,strong) NSString *activity;        //bundleIdentifier
@property (nonatomic,strong) NSString *appkey;
@property (nonatomic,strong) NSString *osVersion;
@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *version;
@property (nonatomic,strong) NSString *platform;
@property (nonatomic,strong) NSString *devicename;
@property (nonatomic,strong) NSString *channel;
@property (nonatomic,strong) NSString *memberCode;

- (instancetype)initWithStackTrace:(NSString *)stackTrace
                            appKey:(NSString *)appKey
                        deviceInfo:(DeviceInfoData *)deviceInfo;

@end
