//
//  KQSecureKeyboard.h
//  kuaiQianbao
//
//  Created by building wang on 16/4/6.
//
//

#import <UIKit/UIKit.h>

@class KQSecureKeyboard;

typedef NS_ENUM(NSInteger, KQKeyBoardType){
    KQKeyBoardTypeNumberPad = 1 << 0,
    KQKeyBoardTypeDecimalPad = 1 << 1,
    KQKeyBoardTypeASCIICapable = 1 << 2
} ;

@protocol KQSecureKeyboardDelegate <NSObject>

@required

- (void)letterDoneButton:(KQSecureKeyboard * _Nonnull )keyboard;
- (void)letterNumberButton:(KQSecureKeyboard * _Nonnull)keyboard value:(NSString * _Nonnull )value;
- (void)letterDeleteButton:(KQSecureKeyboard * _Nonnull)keyboard;
@end

@interface KQSecureKeyboard : UIView

/**
 *  键盘类型
 *
 *  @param type 类型
 *
 */
+ (nonnull instancetype)keyboardWithType:(KQKeyBoardType)type;

/**
 *  显示view
 */
@property (nonatomic, nullable, strong) UIView *inputSource;

/**
 *  代理
 */
@property(nonatomic, assign) __nonnull id<KQSecureKeyboardDelegate> delegate;

/**
 *  文字最大长度
 */
@property(nonatomic, assign) NSInteger maxLength;

@end
