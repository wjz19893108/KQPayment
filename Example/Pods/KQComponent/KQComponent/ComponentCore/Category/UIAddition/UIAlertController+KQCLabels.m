//
//  UIImage+BarCodeGen.m
//  kuaiQianbao
//
//  Created by pengkang on 15/7/5.
//
//
#import "UIAlertController+KQCLabels.h"
@implementation UIAlertController (KQCLabels)
@dynamic titleLabel;
@dynamic messageLabel;

- (NSArray *)viewArray:(UIView *)root {
    static NSArray *_subviews = nil;
    _subviews = nil;
    for (UIView *v in root.subviews) {
        if (_subviews) {
            break;
        }
        if ([v isKindOfClass:[UILabel class]]) {
            _subviews = root.subviews;
            return _subviews;
        }
        [self viewArray:v];
    }
    return _subviews;
}

- (UILabel *)titleLabel {
    return [self viewArray:self.view][0];
}

- (UILabel *)messageLabel {
    return [self viewArray:self.view][1];
}
@end
