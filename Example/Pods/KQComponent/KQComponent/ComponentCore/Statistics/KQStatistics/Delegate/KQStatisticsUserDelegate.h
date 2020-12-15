//
//  KQStatisticsUserDelegate.h
//  KQComponent
//
//  Created by wangping on 2018/6/11.
//

#import <Foundation/Foundation.h>

@protocol KQStatisticsUserDelegate <NSObject>

/**
 获取用户本地标示
 
 @return 本地标示
 */
- (NSString *)userId;

- (NSString *)secretUserMebCode;

// 用户存储埋点路径
- (NSString *)userStatisticsPath;

// 用户是否登录
- (BOOL)userisLogin;

@end
