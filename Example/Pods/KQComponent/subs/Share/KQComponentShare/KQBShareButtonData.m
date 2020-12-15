//
//  KQShareButtonData.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/3.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQBShareButtonData.h"

@interface KQBShareButtonData ()

@property (nonatomic, assign) KQCShareType shareType;
@property (nonatomic, copy) NSString *shareButtonTitle;
@property (nonatomic, copy) NSString *shareButtonIcon;

@end

@implementation KQBShareButtonData

- (instancetype)initWithData:(KQCShareType)shareType buttonTitle:(NSString*)title buttonIcon:(NSString*)icon
{
    self = [super init];
    if (self) {
        self.shareType = shareType;
        self.shareButtonTitle = title;
        self.shareButtonIcon = icon;
    }
    return self;
}

@end
