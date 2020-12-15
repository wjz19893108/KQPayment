//
//  KQCScreenMarco.h
//  KQCore
//
//  Created by xy on 2016/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#ifndef KQCScreenMarco_h
#define KQCScreenMarco_h

#define KQC_SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define KQC_SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

#define KQC_HAS_NOTCH       ([KQCDevice hasScreenNotch])

#define KQC_STATUSBAR_HEIGHT        20
#define KQC_STATUSBAR_NEW_HEIGHT    [[UIApplication sharedApplication] statusBarFrame].size.height
#define KQC_NAVIGATIONBAR_HEIGHT    44
#define KQC_TABBAR_HEIGHT           (KQC_STATUSBAR_NEW_HEIGHT > 20 ? 83 : 49)

#define KQC_TOP_WINDOW      ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0 ? ([UIApplication sharedApplication].keyWindow) : ([[[UIApplication sharedApplication] windows] lastObject]))

#define KQC_WIDTH_RATIO     (KQC_SCREEN_WIDTH / 320)            // 宽度比例 - 相对于5s
#define KQC_HEIGHT_RATIO    (KQC_SCREEN_HEIGHT / 568)           // 高度比例 - 相对于5s

#define KQC_HEIGHT_RATIO_6S    (KQC_SCREEN_HEIGHT > 667 ? (KQC_SCREEN_HEIGHT / 667) : 1)      // 高度比例 - 相对于6s

#define KQC_IS_IPHONE5  (KQC_SCREEN_HEIGHT == 568.0)
#define KQC_IS_IPHONE6P (KQC_SCREEN_HEIGHT == 736.0)
//#define KQC_IS_IPHONEX  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define KQC_RESOLUTION  (KQC_SCREEN_HEIGHT < 736 ? @"2x" : @"3x")

#endif /* KQCScreenMarco_h */
