//
//  UIImageView+KQBAddition.h
//  KQBusiness
//
//  Created by xy on 2016/11/1.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageView (KQOMS)

- (void)setBankIcon:(NSString *)iconName;
- (void)setBankIcon:(NSString *)iconName downImgSuccess:(void(^)(UIImage *image))success;

- (void)setOMSIcon:(NSString *)omsImageId;

@end
