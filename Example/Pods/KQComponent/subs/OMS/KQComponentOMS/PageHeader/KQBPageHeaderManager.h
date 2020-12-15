//
//  KQBPageHeaderManager.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

typedef NS_ENUM(NSInteger, KQBPageHeaderType){
    KQBPageHeaderTypeCredit = 601
};

#define PageHeaderManager [KQBPageHeaderManager sharedManager]

#define PageHeaderNotiDic   @{ KQC_FORMAT(@"%ld",(unsigned long)KQBPageHeaderTypeCredit):@"updateCreditHeader"}


@class KQBPageHeaderModel;

@interface KQBPageHeaderManager : KQBBaseOmsResManager


/**
 获取页面头部模板

 @param headerType 头部类型
 @return header数据
 */
- (KQBPageHeaderModel *)getHeader:(KQBPageHeaderType)headerType;

+ (KQBPageHeaderManager *)sharedManager;

@end
