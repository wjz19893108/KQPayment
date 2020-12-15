//
//  KQBColor.m
//  KQCore
//
//  Created by xy on 2016/11/1.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBColor.h"

@implementation KQBColor

static NSDictionary *KQBColorDic = nil;

+ (void)registerColorDic:(NSDictionary *)dic{
    KQBColorDic = [dic copy];
}

+ (UIColor *)colorWithType:(KQBColorType)type{
    return KQBColorDic[@(type)];
}

@end
