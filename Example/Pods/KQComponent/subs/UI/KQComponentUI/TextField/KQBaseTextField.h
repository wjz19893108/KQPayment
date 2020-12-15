//
//  KQCustomTextField.h
//  KQPayPlugin
//
//  Created by Hunter Li on 14-3-3.
//
//

#import <UIKit/UIKit.h>
#import "KQKeyboardView.h"
#import "KQPayKeyboardView.h"
#import "KQSecureKeyboard.h"

/**
 快钱键盘类型
 
 - KQKeyboardStyleNormal: 普通键盘
 - KQKeyboardStylePay: 支付密码键盘
 - KQKeyboardStyleLetter: 登录密码键盘
 */
typedef NS_ENUM(NSInteger, KQKeyboardStyle){
    KQKeyboardStyleNormal = 0,
    KQKeyboardStylePayPassword,
    KQKeyboardStyleLoginPassword
};

@protocol  KQBaseTextFieldDelegate;
@interface KQBaseTextField : UITextField<KQkeyboardViewDelegate,KQPaykeyboardViewDelegate,KQSecureKeyboardDelegate>

/**
 设置各种类型键盘是否乱序，默认都不乱序
 for example:@{@(KQKeyboardStyleNormal):@(YES),
               @(KQKeyboardStylePayPassword):@(YES)}

 @param config 乱序配置
 */
+ (void)keyboardShuffleConfig:(NSDictionary *)config;

//@property(nonatomic, assign) BOOL isRandomShuffle; //数字键盘乱序 默认NO
@property(nonatomic, assign) BOOL isSecurity;
@property(nonatomic, weak) id kqTextfieldDelegate;
@property(nonatomic, assign) NSInteger maxLength;
@property(nonatomic, strong) NSString *cipherText;

- (NSString *)encryptPassword;
- (void)updateCipherTextInRange:(NSRange)range string:(NSString *)string;
- (void)changeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

- (void)keyborderSytleSet:(KQKeyboardStyle)style;

- (void)allTextClear;

@end

////// 新增  14-03-04 //////////////
@protocol KQBaseTextFieldDelegate <NSObject>
@optional
-(void)addNumber:(KQBaseTextField*)textField number:(NSString *)number;
-(void)deleteNumber:(KQBaseTextField*)textField;
@end
///////////////////////////////////
