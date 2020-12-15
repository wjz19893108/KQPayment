//
//  KQShareButtonData.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/3.
//  Copyright © 2015年 program. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQCShareData.h"

@interface KQBShareButtonData : NSObject

@property (nonatomic, assign, readonly) KQCShareType shareType;
@property (nonatomic, copy, readonly) NSString *shareButtonTitle;
@property (nonatomic, copy, readonly) NSString *shareButtonIcon;

- (instancetype)initWithData:(KQCShareType)shareType buttonTitle:(NSString *)title buttonIcon:(NSString *)icon;

@end
