//
//  EventDataForRC.h
//  kuaiQianbao
//
//  Created by lihui on 16/5/16.
//
//

#import <Foundation/Foundation.h>
#import "DeviceInfoData.h"

@interface EventDataForRC : NSObject<NSCoding>

@property (nonatomic, strong) NSString *eventId;                    //埋点事件名
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *time;                        //埋点事件时间（触发和结束）

- (instancetype)initWithEventId:(NSString *)eventId deviceInfo:(DeviceInfoData *)deviceInfo;
@end
