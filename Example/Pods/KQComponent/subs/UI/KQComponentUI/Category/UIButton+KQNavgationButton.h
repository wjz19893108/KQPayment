//
//  UIButton+KQNavgationButton.h
//  kuaiQianbao
//
//  Created by zouf on 16/12/12.
//
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, KQNavgationStyle) {
    KQNavgationStyleBlack,
    KQNavgationStyleWhite
};

@interface UIButton(KQNavgationButton)

@property (nonatomic, copy, nonnull) NSString * navgationImageName;

- (void)changeButtonStyle:(KQNavgationStyle)style;

@end
