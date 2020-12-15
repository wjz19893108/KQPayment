//
//  KQComponentSecure.h
//  KQComponentSecure
//
//  Created by xy on 2017/11/9.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentSecure.
FOUNDATION_EXPORT double KQComponentSecureVersionNumber;

//! Project version string for KQComponentSecure.
FOUNDATION_EXPORT const unsigned char KQComponentSecureVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentSecure/PublicHeader.h>
#if __has_include(<KQComponent/KQComponent.h>)
    #import <KQComponent/KQBSecureManager.h>
    #import <KQComponent/KQBSecureCacheDelegate.h>
    #import <KQComponent/NSString+KQBAddition.h>
    #import <KQComponent/KQBSwipeCardSecureManager.h>
#else
    #import <KQComponentSecure/KQBSecureManager.h>
    #import <KQComponentSecure/KQBSecureCacheDelegate.h>
    #import <KQComponentSecure/NSString+KQBAddition.h>
    #import <KQComponentSecure/KQBSwipeCardSecureManager.h>
#endif

