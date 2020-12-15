//
//  KQHttpDelegate.h
//  KQBusiness
//
//  Created by xy on 2016/10/25.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KQCHttpRequestModel;
@protocol KQHttpDelegate <NSObject>

@optional

/**
 是否需要加上用户行为节点上送设备信息
 
 @param paramDic 原参数
 @param bizType  业务类型
 */
- (void)extMapParam:(NSMutableDictionary *)paramDic bizType:(NSString *)bizType;

/**
 网络请求即将有结果

 @param success 是否成功
 @param bizType 请求业务号
 @param infoDic 相关业务数据
 @return 是否继续，YES:继续 NO:中断默认处理，由APP接管
 */
- (BOOL)shouldResponseContinue:(BOOL)success bizType:(NSString *)bizType infoDic:(NSDictionary *)infoDic;

/**
 发送http网络请求，如果不实现该接口，则采用默认实现

 @param requestModel 请求参数
 */
- (void)sendHttpRequest:(KQCHttpRequestModel *)requestModel;

@end
