//
//  KQBBaseResModel.h
//  KQBusiness
//
//  Created by pengkang on 2017/3/13.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQBBaseResModel : NSObject<NSCoding>

@property (nonatomic, strong)NSArray  *resArray;        //资源对象数组
@property (nonatomic, strong)NSString *resourceId;      //资源表示
@property (nonatomic, assign)BOOL isDefault;            //资源表示

@end
