//
//  KQBStatusController.m
//  KQBusiness
//
//  Created by lihui on 17/3/7.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBStatusController.h"
#import "KQBCacheManager.h"
//#import "KQBFunctionSwitchManager.h"

@interface KQBStatusController()

@property (nonatomic, assign) BOOL  uAlertShown;
@property (nonatomic, assign) KQBStatus aUType;
@property (nonatomic, strong) NSString *aUUrl;
@property (nonatomic, strong) NSString *gradientLaunchMessageTitle;
@property (nonatomic, strong) NSString *gradientLaunchMessageContent;
@end

@implementation KQBStatusController

SYNTHESIZE_SINGLETON_FOR_CLASS(KQBStatusController);

- (BOOL)showAlert{
    BOOL flag = [self checkAU];
    
    if (_aUType == KQBStatusOptional) {
        _aUType = KQBStatusNo;
    }
    return flag;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStatus:) name:KQCApplicationStatusNotification object:nil];
    }
    return self;
}

- (void)handleStatus:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        KQBAppInfo *appInfo = [[KQBAppInfo alloc] initWithAppInfo:notification.object];
        if ([self appCheckStatus:appInfo]) {
            [self showAlert];
        }
    });
}

- (BOOL)appCheckStatus:(KQBAppInfo *)appInfo{
    if(!appInfo){
        return NO;
    }
    
    if (![self checkWithAppInfo:appInfo]) {
        return NO;
    }
    
    return _aUType >= KQBStatusOptional;
}

- (BOOL)checkWithAppInfo:(KQBAppInfo *)appInfo{
    KQBStatus status = [appInfo.appFlag integerValue];
    
    if(status == KQBStatusRequired){
        _gradientLaunchMessageTitle = appInfo.gradientLaunchMessageTitle;
        _gradientLaunchMessageContent = appInfo.gradientLaunchMessageContent;
        _aUUrl = appInfo.latestAppVersionUrl;
        _aUType = status;
        return YES;
    }
    
    KQBConfigInfo *configInfo = [[KQBConfigInfo alloc] init];
    
    KQBStatusControllerConfig *config = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(statusControllerConfig)]) {
        config = [self.delegate statusControllerConfig];
    }
    
    if (![config.totalRemindTimes isEqualToString:configInfo.upgradeRemindTimes] || ![appInfo.md5 isEqualToString:configInfo.md5]) {
        configInfo.upgradeRemindTimes = config.totalRemindTimes;
        configInfo.lastRemindTime = @"0";
        configInfo.remainUpgradeTimes = config.totalRemindTimes;
        configInfo.md5 = appInfo.md5;
        [configInfo saveCache];
    }
    
    NSInteger remainTimes = [configInfo.remainUpgradeTimes integerValue];
    if (remainTimes < 1) {
        return NO;
    }
    
    NSInteger uGap = [config.remindInterval floatValue] * 60 * 60;
    
    NSInteger timeintervalNow = [[NSDate date] timeIntervalSince1970];
    
    if ([NSString kqc_isBlank:configInfo.lastRemindTime] ) {
        configInfo.lastRemindTime = @"0";
    }
    
    NSInteger timeintervalLast = [configInfo.lastRemindTime integerValue];
    
    if ((timeintervalNow - timeintervalLast)< uGap) {
        return NO;
    }
    
    remainTimes--;
    
    NSString *lastTimeStr = [NSString stringWithFormat:@"%ld", (unsigned long)timeintervalNow];
    
    NSString *remainTimeStr = [NSString stringWithFormat:@"%ld", (unsigned long)remainTimes];
    
    configInfo.lastRemindTime = lastTimeStr;
    configInfo.remainUpgradeTimes = remainTimeStr;
    
    [configInfo saveCache];
    
    _gradientLaunchMessageTitle = appInfo.gradientLaunchMessageTitle;
    _gradientLaunchMessageContent = appInfo.gradientLaunchMessageContent;
    _aUUrl = appInfo.latestAppVersionUrl;
    _aUType = status;
    
    return YES;
}

- (BOOL)checkAU{
    if (_aUType < KQBStatusOptional) {
        return NO;
    }
    
    if (_uAlertShown) {
        return YES;
    }
    [self showStatusAlert];
    return YES;
}

-(void)showStatusAlert{
    if ([_gradientLaunchMessageContent rangeOfString:@"\\n"].length > 0) {
        _gradientLaunchMessageContent = [_gradientLaunchMessageContent stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(hideWaiting)]) {
        [self.delegate hideWaiting];
    }
    
//    [KQBWaitingView hide];
    
    if ([UIAlertController class]) {//ios8 之后使用UIAlertController
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:_gradientLaunchMessageTitle
                                                                                 message:_gradientLaunchMessageContent
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        //靠左显示
        [alertController.messageLabel setTextAlignment:NSTextAlignmentLeft];
        UIAlertAction *alertAction = nil;
        
        if (_aUType == KQBStatusOptional){
            alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                _uAlertShown = NO;
                [self newPage];
            }];
            UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                _uAlertShown = NO;
            }];
            [alertController addAction:resetAction];
        }else if (_aUType == KQBStatusRequired){
            alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                _uAlertShown = NO;
                [self checkAU];
                [self newPage];
            }];
        }
        if (alertAction) {
            [alertController addAction:alertAction];
        }
        
        _uAlertShown = YES;
        [[KQC_Engine_UI topViewController] presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertView *alert;
        if (_aUType == KQBStatusOptional) {
            alert = [[UIAlertView alloc] initWithTitle:_gradientLaunchMessageTitle
                                               message:_gradientLaunchMessageContent
                                              delegate:self
                                     cancelButtonTitle:@"稍后再说"
                                     otherButtonTitles:@"确定", nil];
        } else if (_aUType == KQBStatusRequired) {
            alert = [[UIAlertView alloc] initWithTitle:_gradientLaunchMessageTitle
                                               message:_gradientLaunchMessageContent
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"确定", nil];
        }

        CGSize size = [NSString kqc_calcStrSize:_gradientLaunchMessageContent font:[UIFont systemFontOfSize:12] lineBreakMode:NSLineBreakByTruncatingTail maxSize:CGSizeMake(240, 400)];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,0,240, size.height)];
        textLabel.font = [UIFont systemFontOfSize:12];
        textLabel.textColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.lineBreakMode =NSLineBreakByWordWrapping;
        textLabel.numberOfLines =0;
        textLabel.textAlignment =NSTextAlignmentLeft;
        textLabel.text = _gradientLaunchMessageContent;
        [alert setValue:textLabel forKey:@"accessoryView"];
        alert.message =@"";
        
        if (alert) {
            alert.tag = _aUType;
            [alert show];
            _uAlertShown = YES;
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == KQBStatusOptional) {
        alertView.delegate = nil;
        self.uAlertShown = NO;
        if(buttonIndex == 0) {
            
        } else {
            [self newPage];
        }
    } else if(alertView.tag == KQBStatusRequired) {
        alertView.delegate = nil;
        self.uAlertShown = NO;
        [self checkAU];
        [self newPage];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == KQBStatusUnknow) {
        alertView.delegate = nil;
    }
}

- (void)newPage{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_aUUrl]];
}
@end
