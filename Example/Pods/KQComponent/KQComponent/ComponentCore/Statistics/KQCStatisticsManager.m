//
//  StatisticsManager.m
//  kuaishua
//
//  Created by xuyue on 14/11/27.
//
//

#import "KQCStatisticsManager.h"
#import <objc/message.h>
#define UMeng418
#ifdef UMeng418
#import <UMMobClick/MobClick.h>
#endif

//#import "KQCFunctionSwitchManager.h"
//#import "KQBCacheManager.h"
#import "KQCStatisticsForRC.h"
#import "KQCMobClick.h"

#import "KQCStatisticsManager.h"
#import "KQStatisticsNetworkHelper.h"

#import "KQStatisticsUserDelegate.h"
#import "KQStatisticsNetworkDelegate.h"

@implementation UIButton (StatisticsManager)
@dynamic eventID;

static void *StatisticsManagerEventIDKey = (void *)@"StatisticsManagerEventIDKey";

- (NSString *)eventID{
    return objc_getAssociatedObject(self, StatisticsManagerEventIDKey);
}

- (void)setEventID:(NSString *)eventID{
    objc_setAssociatedObject(self, StatisticsManagerEventIDKey, eventID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation KQCStatisticsManager

static NSDictionary *StatisticsValueDic = nil; // 存放具体的界面名称

SYNTHESIZE_SINGLETON_FOR_CLASS(KQCStatisticsManager);

+ (void)registerStatistics:(StatisticsModel *)config valueDic:(NSDictionary *)valueDic{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#ifdef UMeng418
        NSString *version = [KQCApplication version];
        UMConfigInstance.appKey = config.appKey;
        UMConfigInstance.ePolicy = REALTIME;
        
        [MobClick startWithConfigure:UMConfigInstance];
        [MobClick setAppVersion:version];
        
    #ifdef DEBUG
        //        [MobClick setLogEnabled:YES];
        [MobClick setCrashReportEnabled:NO];
    #endif
#endif
        [KQCStatisticsManager channelsToPromote:config.appKey];
        
        [[KQCStatisticsForRC sharedKQCStatisticsForRC] setKey:config.appKey];

        StatisticsValueDic = [[NSDictionary alloc] initWithDictionary:valueDic];
//        [KQCStatisticsManager initializeStatisticsDic];
        
        NSString *logPath = NSTemporaryDirectory();
        if (KQStatisticsManager.userDelegate && [KQStatisticsManager.userDelegate respondsToSelector:@selector(userStatisticsPath)]) {
            logPath = KQC_NON_NIL([KQStatisticsManager.userDelegate userStatisticsPath]);
        }
        
        config.filePath = logPath;
        [KQCMobClick startWithData:config];
    });
}

#pragma mark - 渠道推广监测
//注：此处key必须使用生产的key值才能查看到激活数据，留存率等等
+ (void)channelsToPromote:(NSString *)appKey{
    NSString *deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *mac = [KQCDevice macAddress];
    NSString *idfa = [KQCApplication idfaString];
    NSString *idfv = [KQCApplication idfvString];
    NSString *urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", appKey, deviceName, mac, idfa, idfv];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];
}

+ (NSString *)getPageNameWithScreen:(NSObject *)screen{
    if ([screen isKindOfClass:[NSString class]]) {
        return StatisticsValueDic[screen];
    }
    
    id destPage = StatisticsValueDic[NSStringFromClass([screen class])];
    if (!destPage) {
        return nil;
    }
    
    if ([destPage isKindOfClass:[NSString class]]) {
        return destPage;
    }
    
    if (![destPage isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    SEL statisKeySEL = NSSelectorFromString(@"statisKey");
    if (![screen respondsToSelector:statisKeySEL]) {
        return nil;
    }
    
    NSObject* statisKey = [screen performSelector:statisKeySEL withObject:nil];
    
//    NSObject* statisKey = objc_msgSend(screen, statisKeySEL);
    if (!statisKey) {
        return nil;
    }
    return destPage[statisKey];
}

+ (void)beginLogPageView:(NSObject *)screen{
    NSString *pageName = [KQCStatisticsManager getPageNameWithScreen:screen];
    if ([NSString kqc_isBlank:pageName]) {
        return;
    }
    
#ifdef UMeng418
    [MobClick beginLogPageView:pageName];
#endif
    [KQCMobClick beginLogPageView:pageName];
}

+ (void)endLogPageView:(NSString *)screen{
    NSString *pageName = [KQCStatisticsManager getPageNameWithScreen:screen];
    if ([NSString kqc_isBlank:pageName]) {
        return;
    }
#ifdef UMeng418
    [MobClick endLogPageView:pageName];
#endif
    [KQCMobClick endLogPageView:pageName];
}

+ (void)logPageName:(NSString *)pageName{
    if ([NSString kqc_isBlank:pageName]) {
        return;
    }
#ifdef UMeng418
    [MobClick logPageView:pageName seconds:1];
//    [MobClick beginLogPageView:pageName];
//    [MobClick endLogPageView:pageName];
#endif
    [KQCMobClick beginLogPageView:pageName];
    [KQCMobClick endLogPageView:pageName];
}

+ (void)logEvent:(NSString *)eventID button:(UIButton *)button{
    if ([NSString kqc_isBlank:eventID]) {
        return;
    }
    button.eventID = eventID;
    [button addTarget:[KQCStatisticsManager sharedKQCStatisticsManager] action:@selector(eventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)eventButtonClick:(UIButton *)button{
    [KQCStatisticsManager logEvent:button.eventID attributes:nil];
}

+ (void)logEvent:(NSString *)eventID{
    if ([NSString kqc_isBlank:eventID]) {
        return;
    }
    
    [KQCStatisticsManager logEvent:eventID attributes:nil];
}

//调用此方法不会将是否登录的Dic加入埋点
+ (void)logEvent:(NSString *)eventID label:(NSString *)label{
    if ([NSString kqc_isBlank:eventID]) {
        return;
    }
    
    if (![NSString kqc_isBlank:label]) {
#ifdef UMeng418
        [MobClick event:eventID label:label];
#endif
        [KQCMobClick event:eventID label:label];
    }else{
        [KQCStatisticsManager logEvent:eventID attributes:nil];
    }
}

+ (void)logEvent:(NSString *)eventID attributes:(NSDictionary *)dic{
    if ([NSString kqc_isBlank:eventID]) {
        return;
    }
    
    NSMutableDictionary *paramDic = [dic mutableCopy];
    if (!paramDic) {
        paramDic = [NSMutableDictionary dictionary];
    }
    
    BOOL isLogin = NO;
    if (KQStatisticsManager.userDelegate && [KQStatisticsManager.userDelegate respondsToSelector:@selector(userisLogin)]) {
        isLogin = [KQStatisticsManager.userDelegate userisLogin];
    }
    NSString *loginStatus = isLogin ? @"已登录" : @"未登录";
    paramDic[@"isLogin"] = loginStatus;
    
    if ([paramDic objectForKey:@"statType"]) {
        [KQCMobClick event:eventID attributes:paramDic];
        return;
    }
#ifdef UMeng418
    [MobClick event:eventID attributes:paramDic];
#endif
    [KQCMobClick event:eventID attributes:paramDic];
}

+ (void)logEvent:(NSString *)eventID isLogin:(BOOL)flag{
    if ([NSString kqc_isBlank:eventID]) {
        return;
    }
    
    NSDictionary *dic = @{@"isLogin":@"未登录"};
    if (flag) {
        dic = @{@"isLogin":@"已登录"};
    }
#ifdef UMeng418
    [MobClick event:eventID attributes:dic];
#endif
    [KQCMobClick event:eventID attributes:dic];
}

+ (void)logEventForRC:(NSString *)eventID{
    if ([NSString kqc_isBlank:eventID]) {
        return;
    }
    
    [[KQCStatisticsForRC sharedKQCStatisticsForRC] logEventForRC:eventID];
}

+ (void)logLoginEventForRC:(NSString *)eventID{
    if ([NSString kqc_isBlank:eventID]) {
        return;
    }
    
    [[KQCStatisticsForRC sharedKQCStatisticsForRC] logEventLoginForRC:eventID];
}

@end
