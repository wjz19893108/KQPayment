//
//  KQBFallManager.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/28.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

typedef NS_ENUM(NSInteger, KQBFallType){
    KQBFallTypeFree = 720,
    KQBFallTypeTop = 721
};

@class KQBFallModel;

#define FallNotiDic   @{ KQC_FORMAT(@"%ld",(unsigned long)KQBFallTypeFree):@"updateFreeFall",\
                           KQC_FORMAT(@"%ld",(unsigned long)KQBFallTypeTop):@"updateTopFall"}


#define FallManager [KQBFallManager sharedManager]

@interface KQBFallManager : KQBBaseOmsResManager

- (KQBFallModel *)getFall:(KQBFallType)fallType;

+ (KQBFallManager *)sharedManager;


/**
 存储瀑布流模型

 @param fallModel 瀑布流模型
 */
- (void)saveFallModel:(KQBFallModel *)fallModel;
@end
