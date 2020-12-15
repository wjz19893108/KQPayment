//
//  KQCMobClick.m
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import "KQCMobClick.h"
#import "ErrorLog.h"
#import <sys/utsname.h>
#import "ClientData.h"
#import "KQCStaFileManager.h"
#import "EventData.h"
#import "DeviceInfoData.h"
#import "YYModel.h"
#import "AFNetworkReachabilityManager.h"

#import "KQStatisticsFileHelp.h"
#import "KQStatisticsNetworkHelper.h"

#define KQCMobClickManager    [KQCMobClick sharedKQCMobClick]

@interface KQCMobClick (){
    dispatch_queue_t q;
}

@property (nonatomic, strong) StatisticsModel *staModel;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, assign) KQReportPolicy policy;
@property (nonatomic, strong) NSString *currentPageName; //当前页面名称
@property (nonatomic, assign) BOOL isWifiOnly;                   //是否仅WiFi上传
@property (nonatomic, assign) BOOL isPostStatData;        //自建埋点是否需要上传
@property (nonatomic, strong) DeviceInfoData *deviceInfo;  //设备信息
@property (nonatomic, assign) BOOL isStart;                       //是否应用启动启动
@property (nonatomic, strong) NSDate *lastPostTime;  //上一次上传时间
@property (nonatomic, assign) CGFloat statFirstUploadDelay;
@property (nonatomic, strong) NSTimer *postEventLogTimer;
@end

@implementation KQCMobClick

SYNTHESIZE_SINGLETON_FOR_CLASS(KQCMobClick);

#pragma mark - API method
+ (void)startWithData:(StatisticsModel *)staModel{
    [KQCMobClickManager initWithData:staModel];
}

+ (void)beginLogPageView:(NSString *)pageName{
    [KQCMobClickManager recordStartTime:pageName];
}

+ (void)endLogPageView:(NSString *)pageName{
    [KQCMobClickManager recordEndTime:pageName];
}

+ (void)event:(NSString *)eventId{
    [KQCMobClickManager event:eventId label:nil attributes:nil];
}

+ (void)event:(NSString *)eventId label:(NSString *)label{
    [KQCMobClickManager event:eventId label:label attributes:nil];
}

+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes{
    [KQCMobClickManager event:eventId label:nil attributes:attributes];
}

+ (void)realTimeEvent:(NSString *)eventId attributes:(NSDictionary *)attributes{
    [KQCMobClickManager realTimeEvent:eventId label:nil attributes:attributes];
}

+ (void)saveErrorInfo:(NSString *)info{
    [KQCMobClickManager saveErrorLog:info];
}

#pragma mark - dealloc
-(void)dealloc{
    [self.postEventLogTimer invalidate];
    self.postEventLogTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init
//初始化属性
- (id)init{
    self = [super init];
    if (self) {
        //==============配置默认值，防止空值导致异常
        self.appKey = @"blank";
        self.policy = KQCATCH;
        self.isWifiOnly = YES;
        self.isPostStatData = NO;
        self.statFirstUploadDelay = 1;
        //==============
        
        self.deviceInfo = [[DeviceInfoData alloc] init];
        
        self.currentPageName = nil;
        self.isStart = NO;
        q = dispatch_queue_create("com.99bill.kuaiQian.sta", DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveApplicationCrash:)
                                                     name:KQCApplicationCrashNotification
                                                   object:nil];
        
    }
    return self;
}

#pragma mark - 初始化自建埋点统计
-(void)initWithData:(StatisticsModel *)model{
    self.staModel = model;
    self.appKey = self.staModel.appKey;
    self.policy = self.staModel.reportPolicy;
    self.isWifiOnly = self.staModel.isWifiOnly;
    self.isPostStatData = self.staModel.isPostStatData;
    self.statFirstUploadDelay = self.staModel.statFirstUploadDelay;
    self.isStart = YES;
    
    dispatch_async(q, ^{
        [[KQCStaFileManager sharedKQCStaFileManager] setFilePath:model.filePath];
        [self postAllStaInfo];
    });
    //开启定时器，每分钟调用查询是否需要上传日志
    self.postEventLogTimer = [NSTimer scheduledTimerWithTimeInterval:60.f
                                                              target:self
                                                            selector:@selector(checkNeedPostEventLog)
                                                            userInfo:nil
                                                             repeats:YES];
    //子线程中的定时器依赖于runloop，子线程runloop需要手动开启
    [[NSRunLoop currentRunLoop] run];
    
}

#pragma mark - recordStartTimeAndEndTime
-(void)recordStartTime:(NSString*) pageName{
    __block KQCMobClick *weakSelf = self;
    dispatch_async(q, ^{
        weakSelf.currentPageName = pageName;
        
        EventData *eventData = [[EventData alloc] initWithPageName:pageName
                                                            appKey:weakSelf.appKey
                                                           isEnter:YES
                                                        deviceInfo:weakSelf.deviceInfo];
        [weakSelf recordEventData:eventData needRealTimePost:NO];
    });
}

-(void)recordEndTime:(NSString*) pageName{
    __block KQCMobClick *weakSelf = self;
    dispatch_async(q, ^{
        EventData *eventData = [[EventData alloc] initWithPageName:pageName
                                                            appKey:weakSelf.appKey
                                                           isEnter:NO
                                                        deviceInfo:weakSelf.deviceInfo];
        [weakSelf recordEventData:eventData needRealTimePost:NO];
    });
}

#pragma mark - 通过标签和行为属性记录行为
- (void)event:(NSString *)eventId label:(NSString *)label attributes:(NSDictionary *)attributes{
    __block KQCMobClick *weakSelf = self;
    dispatch_async(q, ^{
        NSLog(@"show event==========%@",eventId);
        EventData *eventData = [[EventData alloc] initWithPageName:eventId
                                                            appKey:weakSelf.appKey
                                                             label:label
                                                        attributes:attributes
                                                        deviceInfo:weakSelf.deviceInfo];
        [weakSelf recordEventData:eventData needRealTimePost:NO];
    });
}

- (void)realTimeEvent:(NSString *)eventId label:(NSString *)label attributes:(NSDictionary *)attributes{
    __block KQCMobClick *weakSelf = self;
    dispatch_async(q, ^{
        EventData *eventData = [[EventData alloc] initWithPageName:eventId
                                                            appKey:weakSelf.appKey
                                                             label:label
                                                        attributes:attributes
                                                        deviceInfo:weakSelf.deviceInfo];
        [weakSelf recordEventData:eventData needRealTimePost:YES];
    });
}

#pragma mark - 保存errorLog
- (void)saveErrorLog:(NSString*)stackTrace{
    __block KQCMobClick *weakSelf = self;
    dispatch_async(q, ^{
        DLog(@"Save error log\nError Log is %@",stackTrace);
        
        ErrorLog *errorLog = [[ErrorLog alloc] initWithStackTrace:stackTrace
                                                           appKey:weakSelf.appKey
                                                       deviceInfo:weakSelf.deviceInfo];
        NSData *data = [weakSelf formateModelData:errorLog];
        NSString *log = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [[KQCStaFileManager sharedKQCStaFileManager] saveCrashData:log];
        [[KQCStaFileManager sharedKQCStaFileManager] staLivingFileAppend:data];
    });
}


#pragma mark - 上传所有信息
-(void)postAllStaInfo{
    if (self.isPostStatData) {
        if ([self isOverTimeOfPostClientData]) {
            [self saveClientData];
        }
        AFNetworkReachabilityStatus networkStatus = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
        if (self.isWifiOnly) {
            if (networkStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
                if (![self isStatDataFileSizeOverTenMegabyte]) {
                    return;
                }
            }
        }else {
            if (networkStatus == AFNetworkReachabilityStatusNotReachable
                || networkStatus == AFNetworkReachabilityStatusUnknown) {
                return;
            }
        }
        
        if (self.isStart) {
            self.isStart = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.statFirstUploadDelay * NSEC_PER_SEC)), q, ^{
                [self postClientDataInBackground];
            });
        }else {
            [self postClientDataInBackground];
        }
    }
}

-(void)postClientDataInBackground{
    //重置写入文件路径，获取上传前的所有埋点日志
    [[KQCStaFileManager sharedKQCStaFileManager] resetFilePath];
    //读取埋点数据
    NSData *data = [[KQCStaFileManager sharedKQCStaFileManager] staData];
    if (data == nil || [data length] == 0) {
        //如果获取的数据为空，那么删除由于重置当前写入文件导致的空日志文件
        [[KQCStaFileManager sharedKQCStaFileManager] deleteAllStaData];
        return;
    }
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0); //创建信号量
    __block KQCMobClick *weakSelf = self;
    
    [[KQStatisticsNetworkHelper shareInstance] sendHttpRequest:data policy:KQStatisticsPolicyTypeNormal successBlock:^(NSData *responseData, NSDictionary *responseHeader) {
        weakSelf.lastPostTime = [NSDate date];
        [[KQCStaFileManager sharedKQCStaFileManager] deleteAllStaData];
        dispatch_semaphore_signal(sema); //在此发送信号量
    } failedBlock:^(NSError *error, NSInteger httpStatusCode) {
        dispatch_semaphore_signal(sema); //在此发送信号量
    }];
//    [KQHttpService request:@{@"data":data} bizType:@"UXStat" successBlock:^(id response) {
//        weakSelf.lastPostTime = [NSDate date];
//        [[KQCStaFileManager sharedKQCStaFileManager] deleteAllStaData];
//        dispatch_semaphore_signal(sema); //在此发送信号量
//    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
//        dispatch_semaphore_signal(sema); //在此发送信号量
//    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER); //在此等待信号量
}

#pragma mark - 上传或记录行为信息
- (void)recordEventData:(EventData*)eventData needRealTimePost:(BOOL)isRealTime{
    if (isRealTime) {
        [self postEventData:eventData];
        return;
    }
    if (self.policy == KQREALTIME) {
        AFNetworkReachabilityStatus networkStatus = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
        if (self.isWifiOnly) {
            if (networkStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
                [self saveEventData:eventData];
                return;
            }
        }else {
            if (networkStatus == AFNetworkReachabilityStatusNotReachable
                || networkStatus == AFNetworkReachabilityStatusUnknown) {
                [self saveEventData:eventData];
            }
        }
        
        [self postEventData:eventData];
        
    }else{
        [self saveEventData:eventData];
    }
}

- (void)postEventData:(EventData*)model{
    NSData *eventData = [self formateModelData:model];
    if ([self isOverTimeOfPostClientData]) {
        NSData *clientData = [self formateModelData:[self getClientData]];
        NSMutableData *tempData = [[NSMutableData alloc] initWithData:eventData];
        [tempData appendData:clientData];
        eventData = [NSData dataWithData:tempData];
    }
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0); //创建信号量
    
    [[KQStatisticsNetworkHelper shareInstance] sendHttpRequest:eventData policy:KQStatisticsPolicyTypeNormal successBlock:^(NSData *responseData, NSDictionary *responseHeader) {
        dispatch_semaphore_signal(sema); //在此发送信号量
    } failedBlock:^(NSError *error, NSInteger httpStatusCode) {
        //数据提交失败写入数据
        [self saveEventData:model];
        dispatch_semaphore_signal(sema); //在此发送信号量
    }];
    
//    [KQHttpService request:@{@"data":eventData} bizType:@"UXStat" successBlock:^(id response) {
//        dispatch_semaphore_signal(sema); //在此发送信号量
//    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
//        //数据提交失败写入数据
//        [self saveEventData:model];
//        dispatch_semaphore_signal(sema); //在此发送信号量
//    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER); //在此等待信号量
}

- (void)saveEventData:(EventData*)eventData{
    [[KQCStaFileManager sharedKQCStaFileManager] staLivingFileAppend:[self formateModelData:eventData]];
}

#pragma mark - 格式化转化array为JSONstring
- (NSData *)formateModelData:(NSObject *)obj{
    NSObject *sourceObj = obj;
    
    if ([obj isKindOfClass:[EventData class]] &&
        ((EventData *)obj).dicForEvent) {
        EventData *eventData = (EventData *)obj;
        NSMutableDictionary *dic = [[eventData yy_modelToJSONObject] mutableCopy];
        
        //对dicForEvent里的key value对做特殊处理
        [dic addEntriesFromDictionary:eventData.dicForEvent];
        sourceObj = dic;
    }
    
    NSString *string = [[sourceObj yy_modelToJSONString] stringByAppendingString:@"\n"];
//    DLog(@"json string:%@",string);
    
    NSData *result = [string dataUsingEncoding:NSUTF8StringEncoding];
    return result;
}

#pragma mark - getAndSaveClientData
- (ClientData *)getClientData{
    ClientData *clientData = [ClientData getDeviceInfoWithAppKey:self.appKey andDeviceInfoData:self.deviceInfo];
    return clientData;
}

- (void)saveClientData{
    [[KQCStaFileManager sharedKQCStaFileManager] staLivingFileAppend:[self formateModelData:[self getClientData]]];
}

//是否超过两分钟
- (BOOL)isOverTimeOfPostClientData{
    if (!self.lastPostTime) {
        return YES;
    }
    NSInteger differenceTime = [[NSDate date] timeIntervalSinceDate:self.lastPostTime];
    if (differenceTime >= 120) {
        return YES;
    }else {
        return NO;
    }
}

//埋点数据是否超过10M
- (BOOL)isStatDataFileSizeOverTenMegabyte{
    long long fileSize = [KQStatisticsFileHelp sizeAtPath:self.staModel.filePath];
    if (fileSize > 20*1024.0*1024.0) {
        [KQStatisticsFileHelp removeFile:self.staModel.filePath];
        
        return NO;
    } else if (fileSize >= 10*1024.0*1024.0) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 查询是否需要上传埋点日志
- (void)checkNeedPostEventLog{
    dispatch_async(q, ^{
        if (!self.lastPostTime) {
            //如果没有上传成功记录，那么直接上传一次，防止因为重复上传失败跳转直接return造成无法继续上传日志
            [self postAllStaInfo];
            return;
        }
        NSInteger differenceTime = [[NSDate date] timeIntervalSinceDate:self.lastPostTime];
        AFNetworkReachabilityStatus networkStatus = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
        if (networkStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self postAllStaInfo];
        }else{
            if (differenceTime >= 300) {
                [self postAllStaInfo];
            }
        }
    });
}

#pragma mark - receiveApplicationCrash
- (void)receiveApplicationCrash:(NSNotification *)notification{
    [KQCMobClick saveErrorInfo:notification.object];
}
@end
