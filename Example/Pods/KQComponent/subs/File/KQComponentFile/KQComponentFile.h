//
//  KQComponentFile.h
//  KQComponentFile
//
//  Created by xy on 2018/8/27.
//  Copyright © 2018年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentFile.
FOUNDATION_EXPORT double KQComponentFileVersionNumber;

//! Project version string for KQComponentFile.
FOUNDATION_EXPORT const unsigned char KQComponentFileVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentFile/PublicHeader.h>

#if __has_include(<KQComponent/KQComponent.h>)
#import <KQComponent/KQBFileEngine.h>
#import <KQComponent/KQBOPFileEngine.h>
#else
#import <KQComponent/KQBFileEngine.h>
#import <KQComponent/KQBOPFileEngine.h>
#endif
