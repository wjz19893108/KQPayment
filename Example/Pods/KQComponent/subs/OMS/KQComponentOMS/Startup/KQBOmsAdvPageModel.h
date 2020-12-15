//
//  KQOmsAdvPageModel.h
//  kuaiQianbao
//
//  Created by pengkang on 16/1/14.
//
//
#import "KQBOmsBaseModel.h"

@interface KQBOmsAdvPageModel : KQBOmsBaseModel <NSCoding>

@property (nonatomic, strong) NSString *showTime;           // 启动页显示时长
@property (nonatomic, strong) NSString *isCanSkip;          // 启动页是否能跳过
@property (nonatomic, strong) UIImage *image;               // 启动页图片

@end
