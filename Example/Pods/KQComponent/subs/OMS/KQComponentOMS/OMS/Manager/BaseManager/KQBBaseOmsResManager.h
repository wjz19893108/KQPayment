//
//  KQBBaseOmsResManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/25.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KQOMSNotificationName(resId)    KQC_FORMAT(@"%@%@", @"OMSNotification", resId)

typedef NS_ENUM(NSInteger, KQBResManagerType){
    KQBResManagerTypeH5Resource = 0,
    KQBResManagerTypeDescription,
    KQBResManagerTypeFunctionSwitch,
    KQBResManagerTypeBanner,
    KQBResManagerTypeSoduko,
    KQBResManagerTypeStartup,
    KQBResManagerTypeTab,
    KQBResManagerTypeImages,
    KQBResManagerTypePage,
    KQBResManagerTypeMatrix,
    KQBResManagerTypeCreditProduct,
    KQBResManagerTypeFinancialProduct,
    KQBResManagerTypePageHeader,
    KQBResManagerTypeFall,
    KQBResManagerTypeMultiCard,
    KQBResManagerTypeCardList
};

#define OmsCacheDic   @{ KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeH5Resource):@(KQCacheTypeH5Resource),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeDescription):@(KQCacheTypeDescription),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeFunctionSwitch):@(KQCacheTypeFunctionSwitch),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeBanner):@(KQCahceTypeUserBanner),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeSoduko):@(KQCacheTypeUserSoduko),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeStartup):@(KQCacheTypeStartup),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeTab):@(KQCacheTypeUserTab),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeImages):@(KQCacheTypeUserImages),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypePage):@(KQCacheTypeUserPage),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeMatrix):@(KQCacheTypeUserMatrix),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeCreditProduct):@(KQCacheTypeUserCreditProduct),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeFinancialProduct):@(KQCacheTypeUserFinancialProduct),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypePageHeader):@(KQCacheTypeUserPageHeader),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeFall):@(KQCacheTypeUserFall),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeMultiCard):@(KQCacheTypeUserMultiCard),\
                      KQC_FORMAT(@"%ld",(unsigned long)KQBResManagerTypeCardList):@(KQCacheTypeCardList)}

@class KQBOmsBaseModel;

@interface KQBBaseOmsResManager : NSObject

@property (nonatomic, strong, nonnull) NSMutableDictionary * resDic;

@property (nonatomic, assign) KQBResManagerType omsResType;

/**
 *  重置数据
 */
- (void)resetData;

/**
 *  读取缓存
 */
- (void)loadCache;

/**
 *  更新数据
 *
 *  @param msgContent : 配置信息
 *  @param resId : 资源标识符
 *  @param resHome : 资源Home
 */
- (void)updateData:(nonnull NSDictionary *)msgContent resId:(nullable NSString *)resId resHome:(nullable NSString *)resHome;

/**
 *  获取数据
 *  @param resourceId : 资源标识符
 */
- (nullable id)getResById:(nonnull NSString *)resourceId;

/**
 *  解析数据
 *  @param model : 数据模型
 *  @param dic : 配置信息
 */
- (nullable KQBOmsBaseModel *)parseBasicModel:(nonnull KQBOmsBaseModel *)model dic:(nonnull NSDictionary *)dic;


/**
 删除无用资源

 @param resourceId : 数据类型
 */
- (void)removeResById:(nonnull NSString *)resourceId;

@end
