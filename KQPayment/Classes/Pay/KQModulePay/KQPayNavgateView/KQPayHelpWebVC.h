//
//  KQPayHelpWebVC.h
//  KQProcess
//
//  Created by Guanyi on 2018/1/5.
//  Copyright © 2018年 xy. All rights reserved.
//


typedef void(^KQPayHelpBackHandler)(void);

@interface KQPayHelpWebVC : KQBBaseWebVC

@property (nonatomic, copy) KQPayHelpBackHandler handler;

@end
