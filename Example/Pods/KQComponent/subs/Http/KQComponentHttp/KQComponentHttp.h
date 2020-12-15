//
//  KQComponentHttp.h
//  KQComponentHttp
//
//  Created by xy on 2017/11/1.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentHttp.
FOUNDATION_EXPORT double KQComponentHttpVersionNumber;

//! Project version string for KQComponentHttp.
FOUNDATION_EXPORT const unsigned char KQComponentHttpVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentHttp/PublicHeader.h>

#if __has_include(<KQComponent/KQComponent.h>)
    #import <KQComponent/KQHttpCertDelegate.h>
    #import <KQComponent/KQHttpSecureDelegate.h>
    #import <KQComponent/KQHttpUIDelegate.h>
    #import <KQComponent/KQHttpDelegate.h>
    #import <KQComponent/KQHttpUserDelegate.h>

    #import <KQComponent/KQHttpMacro.h>
    #import <KQComponent/KQHttpService.h>
    #import <KQComponent/KQHttpManager.h>
    #import <KQComponent/KQHttpBaseRequestData.h>
    #import <KQComponent/KQCNetworkState.h>
    #import <KQComponent/Msg.pb.h>
    #import <KQComponent/Header.pb.h>

    #import <KQComponent/KQBErrorCode.h>
    #import <KQComponent/KQSwipeCardHttpDataSource.h>
    #import <KQComponent/KQPSwipeCardSecureDelegate.h>
    #import <KQComponent/KQHttpSwipeCardRequestData.h>
    #import <KQComponent/KQSwipeCardHttpService.h>
    #import <KQComponent/KQSwipeCardHttpManager.h>
#else
    #import <KQComponentHttp/KQHttpCertDelegate.h>
    #import <KQComponentHttp/KQHttpSecureDelegate.h>
    #import <KQComponentHttp/KQHttpUIDelegate.h>
    #import <KQComponentHttp/KQHttpDelegate.h>
    #import <KQComponentHttp/KQHttpUserDelegate.h>

    #import <KQComponentHttp/KQHttpMacro.h>
    #import <KQComponentHttp/KQHttpService.h>
    #import <KQComponentHttp/KQHttpManager.h>
    #import <KQComponentHttp/KQHttpBaseRequestData.h>
    #import <KQComponentHttp/KQCNetworkState.h>
    #import <KQComponentHttp/Msg.pb.h>
    #import <KQComponentHttp/Header.pb.h>

    #import <KQComponentHttp/KQBErrorCode.h>
    #import <KQComponentHttp/KQSwipeCardHttpDataSource.h>
    #import <KQComponentHttp/KQPSwipeCardSecureDelegate.h>
    #import <KQComponentHttp/KQHttpSwipeCardRequestData.h>
    #import <KQComponentHttp/KQSwipeCardHttpService.h>
    #import <KQComponentHttp/KQSwipeCardHttpManager.h>
#endif

