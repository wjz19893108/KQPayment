//
//  KQHttpUIDelegate.h
//  KQComponentHttp
//
//  Created by xy on 2017/11/7.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQHttpMacro.h"

@protocol KQHttpUIDelegate <NSObject>

- (void)showToast:(NSString *)message;

- (void)showWatingView:(KQHttpServiceWaitingViewMode)mode;

- (void)hideWatingView:(KQHttpServiceWaitingViewMode)mode;

@end
