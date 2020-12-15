//
//  UIImage+KQProcessPay.m
//  KQBusiness
//
//  Created by xy on 2016/11/2.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "UIImage+KQProcessPay.h"

@implementation UIImage (KQProcessPay)

+ (UIImage *)kqppay_imageNamed:(NSString *)imageName{
    return [UIImage kqc_imageNamed:imageName bundleName:@"KQModulePay"];
}

@end
