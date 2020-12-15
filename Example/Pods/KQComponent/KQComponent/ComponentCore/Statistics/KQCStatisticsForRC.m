//
//  KQCStatisticsForRC.m
//  KQCusiness
//
//  Created by lihui on 17/1/4.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQCStatisticsForRC.h"
#import "EventDataForRC.h"
#import "ClientDataForRC.h"
#import <YYModel/YYModel.h>

#import "KQStatisticsNetworkHelper.h"

@interface KQCStatisticsForRC ()

@property (nonatomic, strong) NSString *appKey;  //唯一标识，用来区分不同产品
@property (nonatomic, strong) DeviceInfoData *deviceInfo;  //设备信息

@end

@implementation KQCStatisticsForRC

SYNTHESIZE_SINGLETON_FOR_CLASS(KQCStatisticsForRC);

- (void)setKey:(NSString *)key{
    self.appKey = key;
}

- (void)logEventForRC:(NSString *)eventID{
    if (!self.deviceInfo) {
        self.deviceInfo = [[DeviceInfoData alloc] init];
    }
    
    EventDataForRC *eventData = [[EventDataForRC alloc] initWithEventId:eventID deviceInfo:self.deviceInfo];        
    
    __block KQCStatisticsForRC *weakSelf = self;
    dispatch_async([KQCStatisticsForRC sendQueue], ^{
        [weakSelf postEnterInfoForRCInBackground:eventData];
    });
}

- (void)logEventLoginForRC:(NSString *)eventID{
    if (!self.deviceInfo) {
        self.deviceInfo = [[DeviceInfoData alloc] init];
    }
    
    ClientDataForRC *dataForRC = [ClientDataForRC getDeviceInfoWithAppKey:self.appKey withEventId:eventID andDeviceInfoData:self.deviceInfo];
    
    __block KQCStatisticsForRC *weakSelf = self;
    dispatch_async([KQCStatisticsForRC sendQueue], ^{
        [weakSelf postEnterInfoForRCInBackground:dataForRC];
    });
}

/**
 *  数据上送的串行队列
 *
 *  @return 队列
 */
+ (dispatch_queue_t)sendQueue {
    static dispatch_queue_t sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create("KQCStatisticsForRCQueue", NULL);
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        dispatch_set_target_queue(sharedQueue, globalQueue);
    });
    return sharedQueue;
}

- (void)postEnterInfoForRCInBackground:(NSObject*)postData{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0); //创建信号量
    
    NSData *data = [self formateModelData:postData];
    
    [[KQStatisticsNetworkHelper shareInstance] sendHttpRequest:data policy:KQStatisticsPolicyTypeRealTime successBlock:^(NSData *responseData, NSDictionary *responseHeader) {
        dispatch_semaphore_signal(sema); //在此发送信号量
    } failedBlock:^(NSError *error, NSInteger httpStatusCode) {

        dispatch_semaphore_signal(sema); //在此发送信号量
    }];
    
//    [KQHttpService request:@{@"data":data} bizType:@"RCStat" successBlock:^(id response) {
//        dispatch_semaphore_signal(sema); //在此发送信号量
//    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
//        //TODO:数据提交失败,是否保存数据待优化--lihui
//        dispatch_semaphore_signal(sema); //在此发送信号量
//    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER); //在此等待信号量
}

#pragma mark - 格式化转化array为JSONstring
- (NSData *)formateModelData:(NSObject *)obj{
    
    NSString *string = [[obj yy_modelToJSONString] stringByAppendingString:@"\n"];
//    DLog(@"json string:%@",string);
    
    NSData *result = [string dataUsingEncoding:NSUTF8StringEncoding];
    return result;
}
@end
