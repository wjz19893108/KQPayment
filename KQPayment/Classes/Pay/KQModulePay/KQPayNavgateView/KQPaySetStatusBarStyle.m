//
//  KQPaySetStatusBarStyle.m
//  kuaiQianbao
//
//  Created by zouf on 15/12/17.
//
//

#import "KQPaySetStatusBarStyle.h"

@interface KQPaySetStatusBarStyle ()

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation KQPaySetStatusBarStyle

- (instancetype)initWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    self = [super init];
    if (self) {
        self.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle];
    }
    return self;
}

- (void)dealloc
{
    [UIApplication sharedApplication].statusBarStyle = self.statusBarStyle;
}

@end
