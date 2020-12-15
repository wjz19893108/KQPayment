//
//  KQBBasePushManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/12/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBasePushHandler.h"
#import "KQBScreenJumpManager.h"
#import "KQBPushManager.h"

#define BaseAvailableKeys @[@"url",@"t"]

@implementation KQBBasePushHandler

#pragma mark - 判断应用的状态，根据不同状态判断处理方式
- (BOOL)handleNotification:(KQPPushModel *)pushModel{
    self.pushModel = pushModel;
    if ([self parseExt]) {
        if (PushManeger.isLaunchOptionsNotification) {//通过通知启动快钱刷
            [self handleNotificationLauched];
        }else{//已启动快钱刷
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {//快钱刷在前台
                [self handleActiveNotification];
            }else{//快钱刷在后台
                [self handleInactiveNotification];
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark - 应用已启动，但在后台
- (void)handleInactiveNotification{
    
    if (![KQC_Engine_UI currentSelectedViewControllerInTab]) {
        [self handleNotificationLauched];
        return;
    }
    if (PushManeger.notificationType == KQPNotificationTypeNormal) {
        //处理普通通知
        if ([KQC_Engine_UI currentSelectedViewControllerInTab]) {
            [KQC_Engine_UI showRootViewController];
        }
        return;
    }
    //处理 H5或Native 通知
    [[KQBScreenJumpManager sharedKQBScreenJumpManager] handleDirect:PushManeger.screenJumpModel];
    PushManeger.notificationType = KQPNotificationTypeNone;
}

#pragma mark - 应用已启动，在前台
- (void)handleActiveNotification{
    if (!PushManeger.localNotificationArray) {
        PushManeger.localNotificationArray = [NSMutableArray array];
    }
    [PushManeger.localNotificationArray addObject:_pushModel.origUserinfo];
    PushManeger.notificationType = KQPNotificationTypeHtml;
}

#pragma mark - 应用尚未启动，从通知启动
- (void)handleNotificationLauched{
    PushManeger.isLaunchOptionsNotification = NO;
}

#pragma mark - 基础解析
- (BOOL)parseExt{
    //只能处理特定类型的通知，新增通知处理需在子类中覆盖此方法
    self.msgContent = _pushModel.alertStr;
    //解析 URL 和 Title，check是否为NotificationTypeHtml
    NSString *jumpModel = [_pushModel.extDic objectForKey:@"M"];
    NSString *jumpTarget = [_pushModel.extDic objectForKey:@"T"];
    NSString *jumpPageType = [_pushModel.extDic objectForKey:@"PT"];
    NSDictionary *jsonStr = [_pushModel.extDic objectForKey:@"EP"];
    
    NSDictionary *paramDic;
    if (jsonStr) {
        paramDic = jsonStr;
    }
    
    if (![NSString kqc_isBlank:jumpModel] && ![NSString kqc_isBlank:jumpTarget]) {

        PushManeger.screenJumpModel = [KQBScreenJumpModel jumpModelWithJumpMode:jumpModel jumpTarget:jumpTarget jumpPageType:jumpPageType targetDic:paramDic];

        switch ([jumpModel integerValue]) {
            case 1:
                PushManeger.notificationType = KQPNotificationTypeNative;
                break;
                
            case 2:
                PushManeger.notificationType = KQPNotificationTypeHtml;
                break;
                
            default:
                break;
        }
        PushManeger.viewTitle = @"快钱刷";
        return YES;
        
    }
    //纯文字通知
    PushManeger.notificationType = KQPNotificationTypeNormal;
    return YES;
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    alertView.delegate = nil;
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }else{
        [self doTarget];
        PushManeger.notificationType = KQPNotificationTypeNone;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HidePopUpView" object:nil];
}

- (void)doTarget{
    [[KQBScreenJumpManager sharedKQBScreenJumpManager] handleDirect:PushManeger.screenJumpModel];
}

@end
