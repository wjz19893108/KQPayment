//
//  KQCFingerPrintMacro.h
//  KQCore
//
//  Created by pengkang on 2016/12/2.
//  Copyright © 2016年 xy. All rights reserved.
//

#ifndef KQCFingerPrintMacro_h
#define KQCFingerPrintMacro_h

#define IsSupportFaceID [KQCFingerPrintManager isSupportFaceID]
#define BiometryPaymentInvalidInfo IsSupportFaceID ? @"您的面容ID已失效，请重新开启面容ID支付" : @"您的指纹已失效，请重新开启指纹支付"
#define BiometryPaymentChangedInfo IsSupportFaceID ? @"系统面容ID已变更，支付成功将重新启用" : @"系统指纹已变更，支付成功将重新启用"
#define BiometryPaymentFailedInfo IsSupportFaceID ? @"面容ID验证失败，请使用支付密码" : @"指纹验证失败，请使用支付密码"
#define BiometryPaymentDealingInfo IsSupportFaceID ? @"面容ID支付处理中..." : @"指纹支付处理中..."
#define BiometryPaymentOpenInfo IsSupportFaceID ? @"您尚未开启面容ID支付 请于“个人中心-账户安全-面容ID“中开启" : @"您尚未开启指纹支付 请于“个人中心-账户安全-指纹”中开启"
#define BiometryLoginChangedInfo IsSupportFaceID ? @"你的面容ID信息发生变更，请在手机中重新添加面容ID后返回解锁或直接使用密码登录" : @"你的指纹信息发生变更，请在手机中重新添加指纹后返回解锁或直接使用密码登录"
#define BiometryVerifyInfo IsSupVportFaceID ? @"将面部正对屏幕，验证您的身份" : @"将手指放在Home键，验证您的身份"
#define BiometryVerifyFailedInfo IsSupportFaceID ? @"面容ID验证失败，请验证系统添加的面容ID" : @"指纹验证失败，请验证系统已添加的指纹"
#define BiometryTextInfo IsSupportFaceID ? @"面容ID" : @"指纹"
#define BiometryUnlockTextInfo IsSupportFaceID ? @"面容ID解锁" : @"指纹解锁"
#define BiometryPaymentTextInfo IsSupportFaceID ? @"面容ID支付" : @"指纹支付"
#define BiometryLoginCloseInfo IsSupportFaceID ? @"关闭后，您将无法更加方便快捷的使用面容ID解锁" : @"关闭后，您将无法更加方便快捷的使用指纹解锁"
#define BiometryPaymentCloseInfo IsSupportFaceID ? @"关闭后，您将无法更加方便快捷的使用面容ID支付进行付款" : @"关闭后，您将无法更加方便快捷的使用指纹支付进行付款"
#define KQFINGER_MANAGER_PASS_NOT_SET           IsSupportFaceID ? @"您尚未设置面容ID解锁密码，请于手机系统“设置>面容ID与密码”中设置" : @"您尚未设置指纹解锁密码，请于手机系统“设置>Touch ID与密码”中设置"
#define KQFINGER_MANAGER_TOUCHID_NOT_SET        IsSupportFaceID ? @"您尚未设置Face ID，请于手机系统“设置>面容ID与密码”中添加面容ID" : @"您尚未设置Touch ID，请于手机系统“设置>Touch ID与密码”中添加指纹"
#define KQFINGER_MANAGER_TOUCHID_NOT_SUPPORT    IsSupportFaceID ? @"您的手机不支持Face ID" : @"您的手机不支持Touch ID"
#define KQFINGER_MANAGER_UNKNOWN_ERROR          @"出错次数过多，请稍后重试"

typedef NS_ENUM(NSInteger, KQCFingerStatus){
    KQCFingerStatusNormal = 1,               //设备支持Touch ID并且已设置过指纹
    KQCFingerStatusPasscodeNotSet,           //设备支持Touch ID，未设置密码
    KQCFingerStatusTouchIDNotEnrolled,       //系统未录入指纹
    KQCFingerStatusUnsupportSystemVersion,   //系统版本过低，低于iOS8
    KQCFingerStatusPayUnsupportSystemVersion,//系统版本过低，低于iOS9
    KQCFingerStatusTouchIDNotAvailable,      //设备不支持Touch ID
    KQCFingerStatusOMSDenied,                //OMS关闭指纹
    KQCFingerStatusOtherError                //其他错误
};

typedef NS_ENUM(NSInteger, KQCFingerVerifyStatus){
    KQCFingerVerifyStatusSuccess = 1,       //验证成功
    KQCFingerVerifyStatusUserCancel,        //用户取消验证
    KQCFingerVerifyStatusTouchIDLockout,    //验证失败次数超限
    KQCFingerVerifyAuthenticationFailed     //指纹认证失败失败
};

#endif /* KQCFingerPrintMacro_h */
