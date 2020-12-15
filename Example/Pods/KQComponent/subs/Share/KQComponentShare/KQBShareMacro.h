//
//  KQBShareMacro.h
//  KQBusiness
//
//  Created by xy on 2016/12/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#ifndef KQBShareMacro_h
#define KQBShareMacro_h

/*
 分享选择时调用的block，通知KQShareManager，选了哪种分享，在反馈分享结果block时使用
 */
typedef void(^ShareViewSelectedBlock)(KQCShareType);

/*
 显示分享View前调用的block，返回YES表示中断分享业务，返回NO表示继续分享业务
 */
typedef BOOL(^BeforeShowShareView)(KQCShareData *);

/*
 分享选择时调用的block
 */
typedef void(^ShareSelectedBlock)(KQCShareType, KQCShareData *);

/*
 分享成功时调用的block
 */
typedef void(^ShareSuccessBlock)(KQCShareType, KQCShareData *);

/*
 分享失败或取消时调用的block
 */
typedef void(^ShareFailedBlock)(KQCShareType, KQCShareData *);

#endif /* KQBShareMacro_h */
