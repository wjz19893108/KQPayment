//
//  KQComponentFingerPrint.h
//  KQComponentFingerPrint
//
//  Created by xy on 2017/12/14.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentFingerPrint.
FOUNDATION_EXPORT double KQComponentFingerPrintVersionNumber;

//! Project version string for KQComponentFingerPrint.
FOUNDATION_EXPORT const unsigned char KQComponentFingerPrintVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentFingerPrint/PublicHeader.h>
#if __has_include(<KQComponent/KQComponent.h>)
#import <KQComponent/KQBFingerManager.h>
#else
#import <KQComponentFingerPrint/KQBFingerManager.h>
#endif

