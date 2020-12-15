//
//  KQComponentPush.h
//  KQComponentPush
//
//  Created by xy on 2017/12/11.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentPush.
FOUNDATION_EXPORT double KQComponentPushVersionNumber;

//! Project version string for KQComponentPush.
FOUNDATION_EXPORT const unsigned char KQComponentPushVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentPush/PublicHeader.h>

#if __has_include(<KQComponent/KQComponent.h>)
#import <KQComponent/KQBPushManager.h>
#else
#import <KQComponentPush/KQBPushManager.h>
#endif
