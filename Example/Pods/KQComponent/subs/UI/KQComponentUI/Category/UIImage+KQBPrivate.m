//
//  UIImage+KQBAdditions.m
//  KQBusiness
//
//  Created by xy on 2016/10/24.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "UIImage+KQBPrivate.h"

@implementation UIImage(KQBPrivate)

+ (UIImage *)kqb_imageNamed:(NSString *)imageName{
    if ([NSString kqc_isBlank:imageName]) {
        return nil;
    }
    
    return [UIImage kqc_imageNamed:imageName bundleName:@"KQComponentUI"];
}

@end
