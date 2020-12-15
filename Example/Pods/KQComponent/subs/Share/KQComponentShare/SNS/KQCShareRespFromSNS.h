//
//  KQShareRespFromSNS.h
//  testWeChat
//
//  Created by zouf on 15/11/11.
//  Copyright © 2015年 program. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQCShareRespFromSNS : NSObject

typedef NS_ENUM(NSInteger, KQShareMessageType){
    KQShareMessageTypeNone = 0,
    KQShareMessageTypeLaunchFromWX = 1,   // 小程序打开微信
};

/**
 判断是否分享回调

 @param url 源url请求
 @param resultBlock 分享是否成功结果回调
 @return YES：是分享 NO：不是分享
 */
+ (BOOL)handleOpenUrl:(NSURL *)url resultBlock:(void(^)(BOOL isSuccess, NSDictionary * shareDic, KQShareMessageType shareScene))resultBlock;

@end
