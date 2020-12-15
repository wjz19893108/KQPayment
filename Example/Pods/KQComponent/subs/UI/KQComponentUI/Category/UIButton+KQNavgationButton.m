//
//  UIButton+KQNavgationButton.m
//  kuaiQianbao
//
//  Created by zouf on 16/12/12.
//
//

#import "UIButton+KQNavgationButton.h"
#import <objc/runtime.h>


static char *currnetImageName = "currnetImageName";

@implementation UIButton(KQNavgationButton)

- (void)setNavgationImageName:(NSString *)navgationImageName {
    objc_setAssociatedObject(self, currnetImageName, navgationImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setImage:[UIImage imageNamed:navgationImageName] forState:UIControlStateNormal];
}

- (NSString *)navgationImageName {
    return objc_getAssociatedObject(self, currnetImageName);
}

- (void)changeButtonStyle:(KQNavgationStyle)style {
    NSString *navgationImageName = self.navgationImageName;
    if (style == KQNavgationStyleBlack) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (!navgationImageName) {
            return;
        }
        [self setImage:[UIImage imageNamed:navgationImageName] forState:UIControlStateNormal];
    } else if (style == KQNavgationStyleWhite) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (!navgationImageName) {
            return;
        }
        [self setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_white", navgationImageName]] forState:UIControlStateNormal];
    }
}

@end
