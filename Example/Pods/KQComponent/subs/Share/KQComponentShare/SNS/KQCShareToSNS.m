//
//  KQShareToSNS.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/3.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQCShareToSNS.h"
#import "WXApi.h"
#import "WXApiObject.h"

//#define KQ_APP_KEY_WeChat    @"wx755ff21355d56f4a"       // 微信分享接入appid
#define KQ_APP_KEY_WECHAT_MINIPROGRAM @"gh_52a7daee75dc"    // 微信小程序ID

@interface KQCShareToSNS()

@end

@implementation KQCShareToSNS

+ (void)registerApp:(NSString *)appKey universalLink:(NSString *)universalLink {
    [WXApi registerApp:appKey universalLink:universalLink];
}

+ (void)shareDataToSNS:(KQCShareData*)data shareType:(KQCShareType)type completesBlock:(void(^)(BOOL isSuccess))completesBlock {
    if (type == KQCShareTypeWXSceneSession) {
        [self shareDataToWXSession:data completesBlock:completesBlock];
        return;
    } else if (type == KQCShareTypeWXSceneTimeline){
        [self shareDataToWXTimeline:data completesBlock:completesBlock];
        return;
    }
    if (completesBlock) {
        completesBlock(NO);
    }
}

+ (void)shareDataToWXSession:(KQCShareData*)data completesBlock:(void(^)(BOOL isSuccess))completesBlock {
    [KQCShareToSNS shareDataToWX:WXSceneSession shareData:data completesBlock:completesBlock];
}

+ (void)shareDataToWXTimeline:(KQCShareData*)data completesBlock:(void(^)(BOOL isSuccess))completesBlock{
    [KQCShareToSNS shareDataToWX:WXSceneTimeline shareData:data completesBlock:completesBlock];
}

+ (void)shareDataToWX:(int)weChatScene shareData:(KQCShareData*)data completesBlock:(void(^)(BOOL isSuccess))completesBlock {
    if (!data) {
        if (completesBlock) {
            completesBlock(NO);
        }
        return;
    }
    
    if (!data.shareImage) {
        if (!data.shareTitle
            || !data.shareContent
            || !data.shareUrl) {
            if (completesBlock) {
                completesBlock(NO);
            }
        }
    }
    
    if (![WXApi isWXAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请先安装微信客户端再进行分享"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil,nil];
        [alert show];
        if (completesBlock) {
            completesBlock(NO);
        }
        return;
    } else if (![WXApi isWXAppSupportApi]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您的微信客户端版本太低，请先升级后再进行分享"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        if (completesBlock) {
            completesBlock(NO);
        }
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    if (data.shareImage) {
        WXImageObject *imgObj = [WXImageObject object];
        
        NSData *imgData = data.shareImageData;
        if (!imgData) {
            if (completesBlock) {
                completesBlock(NO);
            }
            return;
        }
        imgObj.imageData = imgData;
        //多媒体数据对象
        message.mediaObject = imgObj;
    } else {
        message.title = data.shareTitle;
        message.description = data.shareContent;
        [message setThumbImage:data.shareIconDownloaded];
        
        if (!data.shareIsMiniProgram) {
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = data.shareUrl;
            message.mediaObject = ext;
        } else {
            WXMiniProgramObject * miniProjObj = [[WXMiniProgramObject alloc] init];
            miniProjObj.webpageUrl = [NSString kqc_isBlank:data.shareUrl]?@"http://www.99bill.com":data.shareUrl;// 兼容低版本的网页链接
            miniProjObj.miniProgramType = ([KQCApplication environmentType] == KQCAppEnvironmentTypePro)?WXMiniProgramTypeRelease:WXMiniProgramTypePreview;// 正式版:0，测试版:1，体验版:2
            miniProjObj.userName = KQ_APP_KEY_WECHAT_MINIPROGRAM ;// 小程序原始id
            NSString *openPath = ![NSString kqc_isBlank:data.shareMiniProgramPath]?data.shareMiniProgramPath:@"pages/home/home";
            
            NSDictionary *dic = @{@"seedMebcode":KQC_NON_NIL(data.shareSeedMebcode), @"openPath":KQC_NON_NIL(openPath)};
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            miniProjObj.path = KQC_FORMAT(@"%@?parameters=%@", openPath, jsonString);
            message.mediaObject = miniProjObj;
        }
    }
    
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = weChatScene;
    [WXApi sendReq:req completion:completesBlock];
}
@end
