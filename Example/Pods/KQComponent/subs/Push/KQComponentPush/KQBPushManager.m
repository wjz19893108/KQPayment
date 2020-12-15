//
//  KQBPushManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/12/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBPushManager.h"
#import "KQBScreenJumpModel.h"
#import "KQBBasePushHandler.h"
#import "BPush.h"

#define BaiduAppKey_DEV @"f4N9fd5ExXGS0raItVd7VLuj"   // 集成
#define BaiduAppKey @"07LvL8afpADeYnr2IkHoqmRX"     // 生产

#define HandlerPoolDic  @{@"00":@"KQBDefaultPushHandler"}

@interface KQBPushManager ()

@property (nonatomic, copy) void (^resultBlock)(BOOL isSuccess);

@end

@implementation KQBPushManager{
    NSString *msgContent;
    NSMutableDictionary *handlerDic;//handler 对象池
}

SYNTHESIZE_SINGLETON_FOR_CLASS(KQBPushManager);

- (id)init{
    self = [super init];
    if (self) {
        handlerDic = [[NSMutableDictionary alloc] init];
        [self initHandlerPool];
    }
    return self;
}

#pragma mark - 初始化对象池
-(void)initHandlerPool{
    [HandlerPoolDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        Class handlerClass = NSClassFromString(obj);
        [handlerDic setObject:[[handlerClass alloc] init] forKey:key];
    }];
}

- (void)handleNotification:(NSDictionary *)userinfo{
    [self parseUserInfo:userinfo];
    [BPush handleNotification:userinfo];
}

- (void)checkLocalNotification{
    [_localNotificationArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *apsDic = [obj objectForKey:@"aps"];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5+idx];
        [BPush localNotification:date alertBody:[apsDic objectForKey:@"alert"] badge:1 withFirstAction:nil withSecondAction:nil userInfo:obj soundName:UILocalNotificationDefaultSoundName region:nil regionTriggersOnce:NO category:nil useBehaviorTextInput:NO];
    }];
    [_localNotificationArray removeAllObjects];
}

//解析通知内容的UserInfo
- (void)parseUserInfo:(NSDictionary *)userinfo{
    KQPPushModel *pushModel = [[KQPPushModel alloc] initWithNotification:userinfo];
    BOOL pushStatus = [self configPushHandler:pushModel];
    
    if ([NSString kqc_isBlank:pushModel.msgId]) {
        //老版本推送，无需回送处理结果
        return;
    }
    
    NSDictionary *paramDic = @{@"MemberIdentity":@[@{@"idType":pushModel.msgId, @"status":pushStatus?@"1":@"0"}]};
    [KQHttpService request:paramDic bizType:@"M221" successBlock:^(id response) {
        
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
}

- (BOOL)configPushHandler:(KQPPushModel *)pushModel{
    KQBBasePushHandler *subHandler = [handlerDic objectForKey:pushModel.bizType];
    
    if (!subHandler) {
        subHandler = [handlerDic objectForKey:@"00"];
    }
    return [subHandler handleNotification:pushModel];
}

+ (void)startPushEngine:(NSDictionary *)launchOptions resultBlock:(void(^)(BOOL success))resultBlock{
    PushManeger.resultBlock = resultBlock;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = PushManeger;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    //                    NSLog(@"%@", settings);
                }];
            } else {
                //点击不允许
            }
            
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }

    if ([KQCApplication environmentType] == KQCAppEnvironmentTypePro) {
        [BPush registerChannel:launchOptions apiKey:BaiduAppKey pushMode:BPushModeProduction withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:NO isDebug:NO];
    } else {
        [BPush registerChannel:launchOptions apiKey:BaiduAppKey_DEV pushMode:BPushModeProduction withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:NO isDebug:NO];
    }
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        PushManeger.isLaunchOptionsNotification = YES;
    }
    
    NSDictionary *localUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localUserInfo) {
        PushManeger.isLaunchOptionsNotification = YES;
    }
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

+ (void)registerDeviceToken:(NSData *)deviceToken{
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        if (error || !result) {
            PushManeger.pushOpenState = KQBPushOpenStateUnavailable;
            return;
        }
        
        PushManeger.channelId = result[@"channel_id"];
        PushManeger.userId = result[@"user_id"];
        PushManeger.pushOpenState = KQBPushOpenStateAvailable;
    }];
}

- (void)setPushOpenState:(KQBPushOpenState)pushOpenState{
    _pushOpenState = pushOpenState;
    if (self.resultBlock) {
        self.resultBlock(_pushOpenState);
    }
}

#pragma mark - iOS 10及以上
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    [PushManeger handleNotification:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler
{
    [PushManeger handleNotification:response.notification.request.content.userInfo];
}

@end
