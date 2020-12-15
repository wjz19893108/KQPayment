//
//  KQBBasePushManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/12/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQPPushModel.h"

@interface KQBBasePushHandler : NSObject

@property (nonatomic,strong) KQPPushModel *pushModel;

@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, strong) NSString *viewTitle;
@property (nonatomic, strong) NSString *msgContent;


/**
 推送处理

 @param pushModel 推送数据
 */
- (BOOL)handleNotification:(KQPPushModel *)pushModel;


/**
 后台处理推送
 */
- (void)handleInactiveNotification;

/**
 应用已启动，在前台
 */
- (void)handleActiveNotification;


/**
 应用尚未启动
 */
- (void)handleNotificationLauched;


/**
 解析扩展字段

 */
- (BOOL)parseExt;

@end
