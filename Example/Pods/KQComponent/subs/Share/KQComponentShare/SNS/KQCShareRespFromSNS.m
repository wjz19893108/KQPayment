//
//  KQShareRespFromSNS.m
//  testWeChat
//
//  Created by zouf on 15/11/11.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQCShareRespFromSNS.h"
#import "WXApi.h"

@interface KQCShareRespFromSNS () <WXApiDelegate>

@property (nonatomic, copy) void(^resultBlock)(BOOL isSuccess, NSDictionary * shareDic, KQShareMessageType shareScene);

@end

@implementation KQCShareRespFromSNS

static KQCShareRespFromSNS *RespFromSNS = nil;

+ (BOOL)handleOpenUrl:(NSURL *)url resultBlock:(void(^)(BOOL isSuccess, NSDictionary * shareDic, KQShareMessageType shareScene))resultBlock
{
    NSString *urlString = [url absoluteString];
    if ([urlString hasSuffix:@"platformId=wechat"]) {
        if (!RespFromSNS) {
            RespFromSNS = [[KQCShareRespFromSNS alloc] init];
        }
        RespFromSNS.resultBlock = resultBlock;
        return [WXApi handleOpenURL:url delegate:RespFromSNS];
    }
    return NO;
}

#pragma mark - WXApiDelegate
- (void)onReq:(BaseReq *)req{
    //微信向App请求内容时会调用这里，某些请求内容需要xxxResp来答复微信处理结果
    if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        LaunchFromWXReq * openMessage = (LaunchFromWXReq *)req;
        WXMediaMessage * wxMessage = openMessage.message;
        NSString * extMessage = wxMessage.messageExt;
        
        if ([NSString kqc_isBlank:extMessage]) {
            return;
        }
        
        NSData *jsonData = [extMessage dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *shareDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
        
        if (RespFromSNS.resultBlock) {
            RespFromSNS.resultBlock(YES, shareDic, KQShareMessageTypeLaunchFromWX);
        }
    }
}

- (void)onResp:(BaseResp *)resp{
    //发送消息给微信后，会调用到这里，表示微信处理结果
    if(![resp isKindOfClass:[SendMessageToWXResp class]]){
        return;
    }
    
    DLog(@"wechat resp errcode:%d", resp.errCode);
    if (self.resultBlock) {
        self.resultBlock(resp.errCode == 0 ,nil, KQShareMessageTypeNone);
    }
}

- (void)dealloc{
    DLog(@"%@:dealloc", self);
}

@end
