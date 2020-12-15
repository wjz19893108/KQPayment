//
//  KQPPushModel.h
//  KQProtocol
//
//  Created by pengkang on 2016/12/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQPPushModel : NSObject

@property (nonatomic, strong) NSString *alertStr;           // 通知内容
@property (nonatomic, strong) NSString *soundStr;           // 提示音
@property (nonatomic, strong) NSString *badgeStr;           // 提示数量
@property (nonatomic, strong) NSString *bizType;            // 业务类型
@property (nonatomic, strong) NSString *msgId;              // 消息Id
@property (nonatomic, strong) NSDictionary *extDic;         // 扩展字段
@property (nonatomic, strong) NSDictionary *origUserinfo;   // 兼容1.0推送

- (instancetype)initWithNotification:(NSDictionary *)userinfo;

@end
