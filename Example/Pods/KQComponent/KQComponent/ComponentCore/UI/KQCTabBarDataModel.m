//
//  KQCTabBarDataModel.m
//  KQCore
//
//  Created by xy on 2016/12/15.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCTabBarDataModel.h"

@implementation KQCTabBarItemDataModel

+ (instancetype)tabBarData:(NSString *)screenName title:(NSString *)title imageName:(NSString *)imageName imageNameSelected:(NSString *)imageNameSelected{
    return [KQCTabBarItemDataModel tabBarData:screenName title:title image:[UIImage imageNamed:imageName] imageSelected:[UIImage imageNamed:imageNameSelected]];
}

+ (instancetype)tabBarData:(NSString *)screenName title:(NSString *)title image:(UIImage *)image imageSelected:(UIImage *)imageSelected{
    KQCTabBarItemDataModel *data = [[KQCTabBarItemDataModel alloc] init];
    data.screenName = screenName;
    data.title = title;
    data.imageSelected = imageSelected;
    data.imageUnselected = image;
    return data;
}

@end

@implementation KQCTabBarDataModel



@end
