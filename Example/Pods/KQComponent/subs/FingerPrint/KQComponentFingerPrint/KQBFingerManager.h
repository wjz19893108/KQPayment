//
//  KQFingerManager.h
//  kuaiQianbao
//
//  Created by pengkang on 16/5/23.
//
//

#import <Foundation/Foundation.h>

#define KQFingerUnlockStatus @"kitbpfmtw6"

typedef void(^TouchIDPaymentBlock)(BOOL status);

@interface KQBFingerManager : NSObject

/**
 查询OMS是否允许Touch ID
 */
+ (BOOL)isOMSFingerOn;

/**
  查询是否开启系统Touch ID
 
 */
+ (KQCFingerStatus)isSystemFingerOn:(NSData * __nullable * __nullable)data;

/**
 查询是否有开启指纹支付的先决条件
 前置条件:
 iOS9及以上系统

 @param data 系统的指纹校验值，正常情况是一串二进制值，其他情况是nil
 */
+ (KQCFingerStatus)isSystemFingerPayOn:(NSData * __nullable * __nullable)data;

/**
 查询是否开启快钱内部指纹解锁开关
 */
+ (BOOL)isKQFingerOn;

/**
 查询是否开启快钱指纹支付开关

 @param touchIDPaymentBlock 成功回调
 */
+ (void)isFingerPrintPayOn:(TouchIDPaymentBlock __nullable)touchIDPaymentBlock;

/**
 查询指纹解锁是否可用
 */
+ (BOOL)isFingerUnlockAvailable;

/**
 查询指纹支付是否可用

 @param touchIDPaymentBlock 成功回调
 */
+ (void)isFingerPayAvailable:(TouchIDPaymentBlock __nullable)touchIDPaymentBlock;

/**
 验证指纹

 @param successBlock 验证成功回调
 @param failBlock 验证失败回调
 */
+ (void)verifyFingerWithSuccessBlock:(void (^_Nonnull)(void))successBlock failBlock:(void(^_Nonnull)(KQCFingerVerifyStatus error))failBlock;

@end
