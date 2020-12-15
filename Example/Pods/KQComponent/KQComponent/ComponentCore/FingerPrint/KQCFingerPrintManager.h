//
//  KQCFingerPrintManager.h
//  KQCore
//
//  Created by pengkang on 2016/12/2.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQCFingerPrintMacro.h"
@interface KQCFingerPrintManager : NSObject

/**
 手机是否支持指纹

 @return 指纹状态
 */
+ (KQCFingerStatus)isSystemFingerOn:(NSData * __nullable * __nullable)data;

/**
 验证指纹

 @param successBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)verifyFingerWithSuccessBlock:(void (^_Nonnull)(void))successBlock failBlock:(void(^_Nonnull)(KQCFingerVerifyStatus error))failBlock;

/**
 设备是否支付 Face ID
 */
+ (BOOL)isSupportFaceID;
@end
