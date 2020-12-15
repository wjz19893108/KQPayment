//
//  KQShareToSNS.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/3.
//  Copyright © 2015年 program. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQCShareData.h"

@interface KQCShareToSNS : NSObject

/**
 注册分享的APP唯一标示

 @param appKey 微信平台注册的APP唯一标示
 @param universalLink 微信平台注册的universalLink
 */
+ (void)registerApp:(NSString *)appKey universalLink:(NSString *)universalLink;

/**
 分享数据到对应平台

 @param data 待分享的数据
 @param type 平台类型
 @param completesBlock 分享成功 or 失败
 */
+ (void)shareDataToSNS:(KQCShareData*)data shareType:(KQCShareType)type completesBlock:(void(^)(BOOL isSuccess))completesBlock;

@end
