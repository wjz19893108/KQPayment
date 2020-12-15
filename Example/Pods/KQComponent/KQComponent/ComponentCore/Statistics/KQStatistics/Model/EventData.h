//
//  EventData.h
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import <Foundation/Foundation.h>
#import "DeviceInfoData.h"

@interface EventData : NSObject<NSCoding>

@property (nonatomic,strong) NSString *eventId;                   //埋点事件名
@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *memberCode;
@property (nonatomic,strong) NSString *time;                      //埋点事件时间（触发和结束）
@property (nonatomic,assign) BOOL isPage;                         //是否页面埋点（页面或按键）
@property (nonatomic,assign) BOOL enterOrLeave;                   //进入页面或离开页面（只有页面时长埋点才有该属性）
@property (nonatomic,strong) NSString *from;
@property (nonatomic,strong) NSString *platform;                   //平台（写死为iOS）
@property (nonatomic,strong) NSString *osVersion;                  //OS版本
@property (nonatomic,strong) NSString *appkey;
@property (nonatomic,strong) NSString *channel;
@property (nonatomic,strong) NSString *version;                   //app版本号
@property (nonatomic,strong) NSString *message;                   //埋点信息（点击进入的入口）
@property (nonatomic,strong) NSDictionary *dicForEvent;           //事件属性

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *street;
//点击事件行为信息
- (instancetype)initWithPageName:(NSString *)pageName
                          appKey:(NSString *)appKey
                           label:(NSString *)label
                      attributes:(NSDictionary *)attributes
                      deviceInfo:(DeviceInfoData *)deviceInfo;

//页面停留时间数据
- (instancetype)initWithPageName:(NSString *)pageName
                          appKey:(NSString *)appKey
                         isEnter:(BOOL)isEnter
                      deviceInfo:(DeviceInfoData *)deviceInfo;
@end
