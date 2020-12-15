//
//  KQPPushModel.m
//  KQProtocol
//
//  Created by pengkang on 2016/12/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQPPushModel.h"

@implementation KQPPushModel

- (instancetype)initWithNotification:(NSDictionary *)userinfo{
    self = [super init];
    if (self) {
        NSDictionary *apsDic = [userinfo objectForKey:@"aps"];
        self.alertStr = [apsDic objectForKey:@"alert"];
        self.soundStr = [apsDic objectForKey:@"sound"];
        self.badgeStr = [apsDic objectForKey:@"badge"];
        
        NSDictionary *customerInfoDic = userinfo[@"c"];
        if(customerInfoDic){
            self.bizType = customerInfoDic[@"bt"];
            self.extDic = customerInfoDic[@"ext"];
            self.msgId = customerInfoDic[@"id"];
        }else{
            //兼容老版本
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
            if ([userinfo objectForKey:@"url"]) {
                [paramDic setObject:[userinfo objectForKey:@"url"] forKey:@"url"];
            }
            
            if ([userinfo objectForKey:@"t"]) {
                [paramDic setObject:[userinfo objectForKey:@"t"] forKey:@"t"];
            }
            self.extDic = paramDic;
        }
        _origUserinfo = userinfo;
    }
    return self;
}

@end
