//
//  KQBStartupPageManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

typedef NS_ENUM(NSInteger, KQBStartupType) {
    KQBStartupTypeStartup = 109      //开机启动页
};

#define StartupManager  [KQBStartupPageManager sharedManager]

@class KQBStartupPageModel;

@interface KQBStartupPageManager : KQBBaseOmsResManager

/**
 *  获取启动页数据
 *
 *  @param startupType : startup类型
 */
- (KQBStartupPageModel *)getStartup:(KQBStartupType)startupType;

+ (KQBStartupPageManager *)sharedManager;

@end
