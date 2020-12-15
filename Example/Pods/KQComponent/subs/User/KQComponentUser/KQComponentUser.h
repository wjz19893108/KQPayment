//
//  KQComponentUser.h
//  KQComponentUser
//
//  Created by xy on 2017/11/22.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentUser.
FOUNDATION_EXPORT double KQComponentUserVersionNumber;

//! Project version string for KQComponentUser.
FOUNDATION_EXPORT const unsigned char KQComponentUserVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentUser/PublicHeader.h>
#if __has_include(<KQComponent/KQComponent.h>)
    #import <KQComponent/KQBUserInfo.h>
    #import <KQComponent/KQBUserManager.h>
#else
    #import <KQComponentUser/KQBUserInfo.h>
    #import <KQComponentUser/KQBUserManager.h>
#endif

