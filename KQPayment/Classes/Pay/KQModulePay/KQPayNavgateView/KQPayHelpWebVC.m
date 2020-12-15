//
//  KQPayHelpWebVC.m
//  KQProcess
//
//  Created by Guanyi on 2018/1/5.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "KQPayHelpWebVC.h"

@interface KQPayHelpWebVC ()

@end

@implementation KQPayHelpWebVC

- (void)leftBtnClick:(UIButton *)button {
    [super leftBtnClick:button];
    if (self.handler) {
        self.handler();
    }
}

@end
