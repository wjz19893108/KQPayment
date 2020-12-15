//
//  KQCFingerPrintManager.m
//  KQCore
//
//  Created by pengkang on 2016/12/2.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCFingerPrintManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation KQCFingerPrintManager

///查询是否开启系统Touch ID
+ (KQCFingerStatus)isSystemFingerOn:(NSData**)data{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    BOOL success;
    
    //iOS8 以下不支持
    if (!context) {
        return KQCFingerStatusUnsupportSystemVersion;
    }
    
    success = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (success) {
        if (@available(iOS 9.0, *)) {
            if (data) {
                *data = context.evaluatedPolicyDomainState;
            }
        }
        return KQCFingerStatusNormal;
    } else {
        switch (error.code) {
            case kLAErrorPasscodeNotSet:
                return KQCFingerStatusPasscodeNotSet;
                break;
            case kLAErrorBiometryNotAvailable:
                return KQCFingerStatusTouchIDNotAvailable;
                break;
            case kLAErrorBiometryNotEnrolled:
                return KQCFingerStatusTouchIDNotEnrolled;
                break;
            default:
                break;
        }
        return KQCFingerStatusOtherError;
    }
}

+ (void)verifyFingerWithSuccessBlock:(void (^_Nonnull)(void))successBlock
                           failBlock:(void(^)(KQCFingerVerifyStatus error))failBlock{
    LAContext *context = [[LAContext alloc] init];
    NSError *evaluateError = nil;
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&evaluateError]) {
        if (failBlock) {
            failBlock((KQCFingerVerifyStatus)[KQCFingerPrintManager handleError:evaluateError.code]);
        }
        return;
    }
    
    NSString *localizeReason = @"将手指放在Home键，验证您的身份";
    if (@available(iOS 11.0, *)) {
        if (context.biometryType == LABiometryTypeFaceID) {
            localizeReason = @"将面部正对屏幕，验证您的身份";
        }
    }
    //开启指纹解锁
    context.localizedFallbackTitle = @"";
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizeReason reply:^(BOOL success, NSError *authenticationError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if (successBlock) {
                    successBlock();
                }
            } else {
                ///kLAErrorTouchIDLockout;kLAErrorUserCancel
                if (failBlock) {
                    failBlock((KQCFingerVerifyStatus)[KQCFingerPrintManager handleError:authenticationError.code]);
                }
            }
        });
    }];
}

+ (KQCFingerVerifyStatus)handleError:(NSInteger) errorCode{
    switch (errorCode) {
        case kLAErrorUserCancel:
            return KQCFingerVerifyStatusUserCancel;
            break;
        case kLAErrorBiometryLockout:
            return KQCFingerVerifyStatusTouchIDLockout;
            break;
        case kLAErrorAuthenticationFailed:
            return KQCFingerVerifyAuthenticationFailed;
            break;
        default:
            break;
    }
    return KQCFingerVerifyAuthenticationFailed;
}

+ (BOOL)isSupportFaceID{
    LAContext *context = [[LAContext alloc]init];
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        if (@available(iOS 11.0, *)) {
            if (context.biometryType == LABiometryTypeFaceID){
                return YES;
            }
        }
    }
    
    return NO;
}
@end

