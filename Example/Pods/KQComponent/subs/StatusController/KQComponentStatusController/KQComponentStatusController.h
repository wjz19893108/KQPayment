//
//  KQComponentStatusController.h
//  KQComponentStatusController
//
//  Created by xy on 2017/12/13.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentStatusController.
FOUNDATION_EXPORT double KQComponentStatusControllerVersionNumber;

//! Project version string for KQComponentStatusController.
FOUNDATION_EXPORT const unsigned char KQComponentStatusControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentStatusController/PublicHeader.h>

#if __has_include(<KQComponent/KQComponent.h>)
#import <KQComponent/KQBAppInfo.h>
#import <KQComponent/KQBStatusController.h>
#import <KQComponent/KQBStatusControllerConfig.h>
#else
#import <KQComponentStatusController/KQBAppInfo.h>
#import <KQComponentStatusController/KQBStatusController.h>
#import <KQComponentStatusController/KQBStatusControllerConfig.h>
#endif
