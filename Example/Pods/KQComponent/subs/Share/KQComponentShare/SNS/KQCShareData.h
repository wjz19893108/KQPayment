//
//  KQCShareData.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/4.
//  Copyright © 2015年 program. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 支持的分享类型
 */
typedef NS_ENUM(NSInteger, KQCShareType){
    KQCShareTypeNone = 0,
    KQCShareTypeWXSceneSession = 1,  // 分享给朋友
    KQCShareTypeWXSceneTimeline = 2, // 分享到朋友圈
    KQCShareTypePhotographs = 3      // 保存到相册
};

/*
 支持的分享内容类型
 */
typedef NS_ENUM(NSInteger, KQCShareContentType){
    KQCShareContentTypeNormal = 0,        // 分享内容为普通链接
    KQCShareContentTypeMiniProgram = 1    // 分享内容为小程序卡片
};

/*
 需要分享的数据类
 */
@interface KQCShareData : NSObject

@property (nonatomic, copy) NSString *shareTitle;               // 分享标题
@property (nonatomic, copy) NSString *shareContent;             // 分享内容
@property (nonatomic, copy) NSString *shareUrl;                 // 目标url
@property (nonatomic, copy) NSString *shareIconUrl;             // 分享图片的Url
@property (nonatomic, copy) NSString *sharePreviewImageUrl;     // 图片分享预览，不需要预先下载
@property (nonatomic, copy) NSString *shareSeedMebcode;         // 引流种子用户
@property (nonatomic, assign) BOOL shareIsMiniProgram;          // 内容是否为小程序
@property (nonatomic, assign) BOOL shareImage;                  // 是否只有图片分享 5.2.7
@property (nonatomic, strong) NSData *shareImageData;           // 分享图片的数据流 5.2.7
@property (nonatomic, copy) NSString *shareMiniProgramPath;     // 小程序打开路径
@property (nonatomic, assign) BOOL shareNeedRealName;        //分享是否需要实名，@"true"为需要实名，其他不要
@property (nonatomic, strong) UIImage *shareIconDownloaded;     // 下载的分享图片image

@end
