//
//  KQBOmsMatrixModel.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBOmsBaseModel.h"

@interface KQBOmsMatrixModel : KQBOmsBaseModel<NSCoding>

@property (nonatomic, strong) UIImage *image;           // 图片
@property (nonatomic, strong) NSString *resFrom;
@property (nonatomic, assign) BOOL isCached;
@end
