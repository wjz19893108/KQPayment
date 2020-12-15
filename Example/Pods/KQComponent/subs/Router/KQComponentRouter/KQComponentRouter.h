//
//  KQComponentRouter.h
//  KQComponentRouter
//
//  Created by xy on 2017/12/11.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentRouter.
FOUNDATION_EXPORT double KQComponentRouterVersionNumber;

//! Project version string for KQComponentRouter.
FOUNDATION_EXPORT const unsigned char KQComponentRouterVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentRouter/PublicHeader.h>
#if __has_include(<KQComponent/KQComponent.h>)
#import <KQComponent/KQBScreenJumpDelegate.h>
#import <KQComponent/KQBScreenJumpManager.h>
#import <KQComponent/KQBScreenJumpModel.h>
#else
#import <KQComponentRouter/KQBScreenJumpDelegate.h>
#import <KQComponentRouter/KQBScreenJumpManager.h>
#import <KQComponentRouter/KQBScreenJumpModel.h>
#endif

