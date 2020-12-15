//
//  KQBOmsImageModel.h
//  kuaiQianbao
//
//  Created by pengkang on 16/1/14.
//
//
#import "KQBOmsBaseModel.h"

@interface KQBOmsImageModel : KQBOmsBaseModel <NSCoding>

@property (nonatomic, strong) NSString *resFrom;        // 资源来源
@property (nonatomic, strong) NSString *imgPosition;    // 资源id
@property (nonatomic, strong) UIImage *image;           // 图片

@end
