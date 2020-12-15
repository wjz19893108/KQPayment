//
//  KQComponentCache.h
//  KQComponentCache
//
//  Created by xy on 2017/11/20.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentCache.
FOUNDATION_EXPORT double KQComponentCacheVersionNumber;

//! Project version string for KQComponentCache.
FOUNDATION_EXPORT const unsigned char KQComponentCacheVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentCache/PublicHeader.h>
#if __has_include(<KQComponent/KQComponent.h>)
    #import <KQComponent/KQBCacheSecureDelegate.h>
    #import <KQComponent/KQBCacheMacro.h>
    #import <KQComponent/KQBCacheEngine.h>
    #import <KQComponent/KQBCacheManager.h>
#else
    #import <KQComponentCache/KQBCacheSecureDelegate.h>
    #import <KQComponentCache/KQBCacheMacro.h>
    #import <KQComponentCache/KQBCacheEngine.h>
    #import <KQComponentCache/KQBCacheManager.h>
#endif

