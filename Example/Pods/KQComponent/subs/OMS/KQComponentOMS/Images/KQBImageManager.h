//
//  KQBImageManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

#define ImageManager [KQBImageManager sharedManager]

@class KQBOmsImageModel;

@interface KQBImageManager : KQBBaseOmsResManager

/**
 *  获取image数据
 *
 *  @param imagePosition : image标识符
 */
- (KQBOmsImageModel *)getImageByPosition:(NSString *)imagePosition;

+ (KQBImageManager *)sharedManager;

@end
