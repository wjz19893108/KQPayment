//
//  KQBMatrixModel.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBBaseResModel.h"

@interface KQBMatrixModel : KQBBaseResModel<NSCoding>

@property (nonatomic, strong) NSString *cols;                         //卡片内容列数
@property (nonatomic, strong) NSString *rows;                         //卡片内容行数

@end
