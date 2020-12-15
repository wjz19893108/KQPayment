//
//  KQComponentShare.h
//  KQComponentShare
//
//  Created by xy on 2017/12/11.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentShare.
FOUNDATION_EXPORT double KQComponentShareVersionNumber;

//! Project version string for KQComponentShare.
FOUNDATION_EXPORT const unsigned char KQComponentShareVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentShare/PublicHeader.h>
#if __has_include(<KQComponent/KQComponent.h>)
#import <KQComponent/KQBShareButtonData.h>
#import <KQComponent/KQBShareMacro.h>
#import <KQComponent/KQBShareManager.h>
#import <KQComponent/KQBShareView.h>
#import <KQComponent/KQPShareDataAnalyze.h>
#else
#import <KQComponentShare/KQBShareButtonData.h>
#import <KQComponentShare/KQBShareMacro.h>
#import <KQComponentShare/KQBShareManager.h>
#import <KQComponentShare/KQBShareView.h>
#import <KQComponentShare/KQPShareDataAnalyze.h>
#endif

