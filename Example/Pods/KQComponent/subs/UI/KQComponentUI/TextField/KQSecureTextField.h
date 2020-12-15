//
//  KQSecureTextField.h
//  KQPayPlugin
//
//  Created by Hunter Li on 14-3-6.
//
//

#import "KQBaseTextField.h"

@interface KQSecureTextField : KQBaseTextField

////// 新增  14-03-24 //////////////
- (void)allTextClear;
///////////////////////////////////

+ (KQSecureTextField *)addSecureTextField:(CGRect)frame
                          placeholderText:(NSString *)text
                                     font:(UIFont *)font
                          minimumFontSize:(float)minimumFontSize
                             keyboardType:(UIKeyboardType)UIKeyboardType
                                 delegate:(id)delegate;
@end

