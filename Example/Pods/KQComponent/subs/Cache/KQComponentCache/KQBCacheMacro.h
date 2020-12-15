//
//  KQCCacheMacro.h
//  KQCore
//
//  Created by pengkang on 2016/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#ifndef KQCCacheMacro_h
#define KQCCacheMacro_h

#define KQCacheUserFolderFlag     0x40
#define kNotificationCacheClearFinish  @"NotificationCacheClearFinish"
#define KQGesturePwdKey @"kitbpfmtw1"

FOUNDATION_EXTERN NSString *KQPageCacheMyInfoKey;
FOUNDATION_EXTERN NSString *KQPageCacheMainPersonInfoKey;
FOUNDATION_EXTERN NSString *KQPageCacheCreditKey;
FOUNDATION_EXTERN NSString *KQPageCacheUserInfoKey;
FOUNDATION_EXTERN NSString *KQPageCacheAUKey;

typedef NS_ENUM(NSInteger, KQCacheType) {
    // 以下为公共目录，为16进制表示值
    KQCacheTypeMain = 0,  // APP公共配置
    KQCacheTypeOMS,     // OMS目录
    KQCacheTypePosOrder, // mPos订单目录
    KQCacheTypePosSignImage, // mPos签购单目录
    KQCacheTypeH5Resource,   // H5静态资源目录
    KQCacheTypeMessageCenter,   // 消息中心目录
    KQCacheTypeStatistics,     // 数据埋点目录
    KQCacheTypeDescription,    // 文案配置目录
    KQCacheTypeFunctionSwitch,  // 功能开关目录
    KQCacheTypePromotionResource,//注册后推广信息
    KQCacgeTypeLog,                 // 日志目录
    KQCacheTypeStartup,       // OMS 启动页
    KQCacheTypeCardList,      // OMS 城市列表

    //以下为用户目录
    KQCacheTypeSoduko = KQCacheUserFolderFlag,  // 九宫格
    KQCacheTypeUserData,            // 用户数据
    KQCahceTypeSecureCert,          // 安全证书目录
    KQCahceTypeUserOms,             // OMS目录
    KQCahceTypeUserBanner,          // OMS Banner
    KQCacheTypeUserSoduko,          // OMS 九宫格
    KQCacheTypeUserTab,             // OMS TAB页
    KQCacheTypeUserImages,          // OMS 一般图片
    KQCacheTypeUserPage,            //  OMS 页面配置
    KQCacheTypeUserMatrix,          // OMS N行N列
    KQCacheTypeUserPageHeader,      // OMS 信用头部
    KQCacheTypeUserFall,            // OMS 瀑布流
    KQCacheTypeUserCreditProduct,   // OMS 信用产品
    KQCacheTypeUserFinancialProduct, // OMS 理财产品
    KQCacheTypeUserBufferedPage,    //  OMS 暂存页面
    KQCacheTypeUserMultiCard        //  OMS 图文卡片
};

typedef NS_ENUM(NSInteger, KQBCacheAgentType) {
    KQBCacheAgentTypePlist = 0,      // Plist文件
    KQBCacheAgentTypeDatabase        // 数据库
};

#endif /* KQCCacheMacro_h */
