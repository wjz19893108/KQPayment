//
//  KQBSodukoModel.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseResModel.h"

@interface KQBSodukoModel : KQBBaseResModel <NSCoding>

@property (nonatomic, strong)NSString *columnsPerRow;   //九宫格列数
@property (nonatomic, strong)NSString *optionType;   //九宫格类型
@end
