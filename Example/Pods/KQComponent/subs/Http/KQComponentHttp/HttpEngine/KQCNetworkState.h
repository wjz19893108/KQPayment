//
//  KQCNetworkState.h
//  KQCoreHttpEngine
//
//  Created by xy on 2018/5/16.
//  Copyright © 2018年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQCNetworkState : NSObject

/**
 是否存在网络

 @return YES：存在 NO：不存在
 */
+ (BOOL)isExistenceNetwork;

/**
 获取当前网络类型

 @return 网络类型
 */
+ (NSString*)networkType;

@end
