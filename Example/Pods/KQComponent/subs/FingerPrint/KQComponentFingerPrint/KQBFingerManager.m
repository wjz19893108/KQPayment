//
//  KQFingerManager.m
//  kuaiQianbao
//
//  Created by pengkang on 16/5/23.
//
//

#import "KQBFingerManager.h"
#import "KQBFunctionSwitchManager.h"
#import "KQBCacheManager.h"
#import "KQBUserManager.h"
#import "KQHttpService.h"

//#define KQOMSFingerStatus    @"kitbpfmtw7"

@implementation KQBFingerManager

///OMS配置指纹开关
+ (BOOL)isOMSFingerOn{
    return  FunctionSwitchManager.fingerPrintVisible.integerValue > 0;
}

///查询是否开启系统Touch ID
+ (KQCFingerStatus)isSystemFingerOn:(NSData**)data {
    if (![KQBFingerManager isOMSFingerOn]){
        return KQCFingerStatusOMSDenied;
    }
    return [KQCFingerPrintManager isSystemFingerOn:data];
}

+ (KQCFingerStatus)isSystemFingerPayOn:(NSData**)data {
    if (!KQC_SYSTEM_VRESION_9) {
        return KQCFingerStatusPayUnsupportSystemVersion;
    }
    return [KQBFingerManager isSystemFingerOn:data];
}

///查询是否开启快钱内部指纹开关
+ (BOOL)isKQFingerOn{
    return [[KQBCacheManager loadValueForKey:KQFingerUnlockStatus] boolValue] && [KQBFingerManager isOMSFingerOn];
}

///查询是否开启快钱指纹支付
+ (void)isFingerPrintPayOn:(TouchIDPaymentBlock)touchIDPaymentBlock{
    NSData *data = nil;
    [KQBFingerManager isSystemFingerPayOn:&data];
    NSString *txnFlag = @"";
    if (data) {
        txnFlag = [data base64EncodedStringWithOptions:0];
    }
    
    NSDictionary *requestDic = @{@"txnFlag":[NSString kqc_isBlank:txnFlag] ? @"nil" : txnFlag};
    [KQHttpService request:requestDic bizType:@"M300" successBlock:^(Content *response) {
        BOOL bStatus = NO;
        [KQBUserManager sharedKQBUserManager].userInfo.touchIdPayStatus = @"NO";
        if ([response.status isEqualToString:@"0"]) {
            bStatus = NO;
        } else if ([response.status isEqualToString:@"1"]){
            [KQBUserManager sharedKQBUserManager].userInfo.touchIdPayStatus = @"YES";
            bStatus = YES;
        } else if ([response.status isEqualToString:@"2"]){
            [KQBUserManager sharedKQBUserManager].userInfo.touchIdPayStatus = @"YES";
            bStatus = YES;
        }
        
        if (touchIDPaymentBlock) {
            touchIDPaymentBlock(bStatus);
        }
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        if (touchIDPaymentBlock) {
            touchIDPaymentBlock(NO);
        }
    }];
}

///查询指纹解锁是否可用
+ (BOOL)isFingerUnlockAvailable{
    return [KQBFingerManager isKQFingerOn] && ([KQBFingerManager isSystemFingerOn:nil] == KQCFingerStatusNormal);
}

///查询指纹支付是否可用
+ (void)isFingerPayAvailable:(TouchIDPaymentBlock)touchIDPaymentBlock{
    if ([[KQBUserManager sharedKQBUserManager].userInfo.touchIdPayStatus isEqualToString:@"YES"]) {
        if (touchIDPaymentBlock) {
            touchIDPaymentBlock(YES);
        }
        return;
    }
    
    if ([[KQBUserManager sharedKQBUserManager].userInfo.touchIdPayStatus isEqualToString:@"NO"]) {
        if (touchIDPaymentBlock) {
            touchIDPaymentBlock(NO);
        }
        return;
    }
    [KQBFingerManager isFingerPrintPayOn:touchIDPaymentBlock];
}

+ (void)verifyFingerWithSuccessBlock:(void (^_Nonnull)(void))successBlock
                           failBlock:(void(^)(KQCFingerVerifyStatus error))failBlock{
    [KQCFingerPrintManager verifyFingerWithSuccessBlock:successBlock failBlock:failBlock];
}

@end
