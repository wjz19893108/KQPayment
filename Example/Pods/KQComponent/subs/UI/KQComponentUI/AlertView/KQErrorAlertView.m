//
//  KQErrorAlertView.m
//  KQErrorAlertView
//
//  Created by Guanyi on 2018/1/2.
//  Copyright © 2018年 yiguan. All rights reserved.
//

#import "KQErrorAlertView.h"

CGFloat const containerWidth = 270.0f;
CGFloat const buttonHeight = 44.0f;

@implementation KQErrorAlertView {
    UIView *_container;
    UIView *_titleView;
    UIView *_bottomView;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UIButton *_additionButton;
    UIView *_line;
    
    NSArray<UIButton *> *_buttons;
    NSArray<NSString *> *_buttonTitles;
    KQErrorAlertViewCompletionBlock _tapBlock;
    NSString *_title;
    NSString *_message;
    UIImage *_additionImage;
}

#pragma mark- Lifecycle

+ (nonnull instancetype)showWithTitle:(nullable NSString *)title
                               message:(nullable NSString *)message
                          butttonImage:(nullable UIImage *)image
                     cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                     otherButtonTitles:(nullable NSArray *)otherButtonTitles
                              tapBlock:(nullable KQErrorAlertViewCompletionBlock)tapBlock {
    KQErrorAlertView *alertView = [[KQErrorAlertView alloc] initWithTitle:title message:message image:image cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles tapBlock:tapBlock];
    [alertView show];
    return alertView;
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        image:(UIImage *)image
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                     tapBlock:(KQErrorAlertViewCompletionBlock)tapBlock {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.alpha = 0;
        _title = title;
        _message = message;
        _tapBlock = tapBlock;
        _additionImage = image;
        NSMutableArray *mult = [NSMutableArray arrayWithArray:otherButtonTitles];
        [mult addObject:cancelButtonTitle];
        _buttonTitles = [mult copy];
    }
    return self;
}

#pragma mark- Method

- (void)show {
    [self layoutViews];
    self.container.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        self.container.alpha = 1;
        self.container.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (void)action:(UIButton *)sender {
    if (_tapBlock) {
        _tapBlock(self,[self.buttons containsObject:sender] ? [self.buttons indexOfObject:sender] : -1);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (CGSize)sizeWithContent:(NSString *)content font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGRect rect = [content boundingRectWithSize:maxSize
                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{NSFontAttributeName:font}
                                        context:nil];
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
}

- (void)layoutViews {
    UIWindow *window = [KQCApplication progressViewParentWindow];
    [window addSubview:self];
    
    self.frame = window.bounds;
    CGSize size = CGSizeZero;
    CGFloat imageSpace = 0;
    if (_additionImage) {
        imageSpace = 14 + 5;
        size = [self sizeWithContent:_title font:self.titleLabel.font maxWidth:containerWidth - 40 - imageSpace];
        self.additionButton.frame = CGRectMake(size.width + 5,(size.height - 14)/ 2, 14, 14);
    } else {
        imageSpace = 0;
        size = [self sizeWithContent:_title font:self.titleLabel.font maxWidth:containerWidth - 40 - imageSpace];
    }

    self.titleLabel.frame = CGRectMake(0, 0, size.width, size.height);
    self.titleView.frame = CGRectMake((containerWidth - size.width - imageSpace) / 2, 20, size.width + 5 + 14, size.height);
    size = [self sizeWithContent:_message font:self.detailLabel.font maxWidth:containerWidth - 32];
    self.detailLabel.frame = CGRectMake((containerWidth - size.width) / 2, CGRectGetMaxY(self.titleView.frame) + 2, size.width, size.height);
    self.line.frame = CGRectMake(0, CGRectGetMaxY(self.detailLabel.frame) + 10, containerWidth, 1/[UIScreen mainScreen].scale);
    CGRect temp = self.bottomView.frame;
    temp.origin = CGPointMake(0, CGRectGetMaxY(self.line.frame));
    self.bottomView.frame = temp;
    [self createButtons];
    self.container.frame = CGRectMake(0, 0, containerWidth, CGRectGetMaxY(self.bottomView.frame));
    self.container.center = self.center;
}

#pragma mark- Setters/Getters

- (UIView *)container {
    if (_container != nil) {
        return _container;
    }
    _container = [[UIView alloc] init];
    _container.layer.cornerRadius = 12;
    _container.backgroundColor = [UIColor whiteColor];
    _container.clipsToBounds = YES;
    _container.alpha = 0;
    [self addSubview:_container];
    return _container;
}

- (UIView *)titleView {
    if (_titleView != nil) {
        return _titleView;
    }
    _titleView = [[UIView alloc] init];
    _titleView.backgroundColor = [UIColor whiteColor];
    [self.container addSubview:_titleView];
    return _titleView;
}

- (UILabel *)titleLabel {
    if (_titleLabel != nil) {
        return _titleLabel;
    }
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = _title;
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleView addSubview:_titleLabel];
    return _titleLabel;
}

- (UIButton *)additionButton {
    if (_additionButton != nil) {
        return _additionButton;
    }
    _additionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _additionButton.frame = CGRectMake(0, 0, 14, 14);
    [_additionButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [_additionButton setBackgroundImage:_additionImage forState:UIControlStateNormal];
    [self.titleView addSubview:_additionButton];
    return _additionButton;
}

- (UILabel *)detailLabel {
    if (_detailLabel != nil) {
        return _detailLabel;
    }
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.text = _message;
    _detailLabel.textColor = [UIColor colorWithRed:0xC7 / 255.0f green:0xC7 / 255.0f blue:0xCD / 255.0f alpha:1];
    _detailLabel.numberOfLines = 0;
    _detailLabel.font = [UIFont systemFontOfSize:15];
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    [self.container addSubview:_detailLabel];
    return _detailLabel;
}

- (UIView *)line {
    if (_line != nil) {
        return _line;
    }
    _line = [[UIView alloc] init];
    _line.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.container addSubview:_line];
    return _line;
}

- (UIView *)bottomView {
    if (_bottomView != nil) {
        return _bottomView;
    }
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, buttonHeight)];
    _bottomView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.container addSubview:_bottomView];
    return _bottomView;
}

- (NSArray<UIButton *> *)buttons {
    if (_buttons != nil) {
        return _buttons;
    }
    [self createButtons];
    return _buttons;
}

- (void)createButtons {
    NSMutableArray *mult = [NSMutableArray array];
    [_buttonTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:obj forState:UIControlStateNormal];
        [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor whiteColor];
        
        CGFloat lineWidth = _buttonTitles.count == 1 ? 0 : 1 / [UIScreen mainScreen].scale;
        CGFloat buttonWidth = (containerWidth - (_buttonTitles.count - 1) * lineWidth) / _buttonTitles.count;
        button.frame = CGRectMake(idx * (buttonWidth + lineWidth), 0, buttonWidth, 44);
        if (idx == _buttonTitles.count - 1) {
            button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        }
        [self.bottomView addSubview:button];
        [mult addObject:button];
    }];
    _buttons = [mult copy];
}

@end


