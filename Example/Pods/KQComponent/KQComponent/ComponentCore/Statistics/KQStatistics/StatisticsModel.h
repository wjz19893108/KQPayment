//
//  StatisticsModel.h
//  KQCusiness
//
//  Created by lihui on 16/12/27.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef enum {
    KQREALTIME = 0,       //实时发送
    KQCATCH = 1,          //启动发送
} KQReportPolicy;

@interface StatisticsModel : NSObject

/**
 唯一标识，用来区分不同产品
 */
@property (nonatomic, strong) NSString *appKey;

/**
 渠道名称,为nil或@""时,默认会被被当作@"App Store"渠道,该值暂未使用
 */
@property (nonatomic, strong) NSString *channelId;

/**
 发送策略
 */
@property (nonatomic, assign) KQReportPolicy reportPolicy;

/**
 是否仅WiFi上传，超过阈值强制上传，目前为10M
 */
@property (nonatomic, assign) BOOL isWifiOnly;

/**
 埋点是否需要上传
 */
@property (nonatomic, assign) BOOL isPostStatData;

/**
启动上传时的延迟时间
 */
@property (nonatomic, assign) CGFloat statFirstUploadDelay;

/**
 埋点存储文件夹
 */
@property (nonatomic, strong) NSString *filePath;

@end
