//
//  KQBFont.m
//  KQCore
//
//  Created by xy on 2016/11/1.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBFont.h"

@implementation KQBFont

static NSDictionary *KQBFontDic = nil;

+ (void)registerFontSizeDic:(NSDictionary *)dic{
    KQBFontDic = [dic copy];
}

+ (UIFont *)fontWithType:(KQBFontType)type{
    return [KQBFont fontWithType:type isBold:NO];
}

+ (UIFont *)fontWithType:(KQBFontType)type isBold:(BOOL)isBold{
    NSNumber *fontSizeNum = KQBFontDic[@(type)];
    CGFloat fontSize = fontSizeNum ? [fontSizeNum floatValue] : 16.f;
    if (isBold) {
        return [UIFont boldSystemFontOfSize:fontSize];
    }
    
    return [UIFont systemFontOfSize:fontSize];
}

+ (CGFloat)fontSizeWithType:(KQBFontType)type{
    NSNumber *fontSizeNum = KQBFontDic[@(type)];
    return [fontSizeNum floatValue];
}

@end
