//
//  KQBOmsManage.h
//  KQBusiness
//
//  Created by pengkang on 2016/10/21.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KQBOmsConfigData;

#define KQP_Manager_OMS    [KQPOmsManager sharedKQPOmsManager]

@interface KQPOmsManager : NSObject

@property (nonatomic, strong, nonnull) NSMutableDictionary * plistDic;

+ (nonnull KQPOmsManager *)sharedKQPOmsManager;

/**
 *  重置配置路径
 */
- (void)resetData;

/**
 *  请求OMS 图片、banner、九宫格等配置资源 M264
 */
- (void)requestOmsUserRes;

/**
 *  请求文案、H5资源、功能开关、城市等配置资源 M255
 */
- (void)requestOmsPublicRes;

/**
 *  重置配置路径
 */
- (void)resetResData;


/**
 获取资源MD5值

 @param resId 资源ID
 @return md5值
 */
- (nullable NSString *)getMD5ById:(nonnull NSString *)resId;

/**
 获取配置
 
 @param resId resId 资源ID
 @return 配置
 */
- (nullable KQBOmsConfigData *)getOMSConfigById:(nonnull NSString *)resId;

/**
 获取默认数据

 @param resId 资源Id
 @param imageName 资源
 @return 默认文件名
 */
- (nullable NSString *)getImageDefaultRes:(nonnull NSString *)resId imageName:(nonnull NSString *)imageName;

@end
