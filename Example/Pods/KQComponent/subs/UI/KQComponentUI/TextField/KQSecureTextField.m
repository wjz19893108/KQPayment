//
//  KQSecureTextField.m
//  KQPayPlugin
//
//  Created by Hunter Li on 14-3-6.
//
//

#import "KQSecureTextField.h"
#import "KQBSecureManager.h"
#import "UITextField+KQBAddition.h"


#define kCountOfBlinkTimes 3

@interface KQSecureTextField (){
    int loopCount;
    NSTimer *blinkTimer;
}

@end

@implementation KQSecureTextField
//@synthesize cipherText = _cipherText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.cipherText = [KQB_Manager_Secure encryptByAES:@""];
        loopCount = 0;
        [self setSecureTextEntry:NO];
    }
    
    return self;
}

-(NSString*)text{
    if (self.isSecurity) {
        return [super text];
    }else{
        long inputTextLength = [super.text length];
        __autoreleasing NSString* tempStr = [[NSString alloc] initWithUTF8String:""];
        while (inputTextLength) {
            inputTextLength--;
            tempStr = [tempStr stringByAppendingString:@"●"];
        }
        return tempStr;
    }
}

//-(void)setText:(NSString *)inputText{
//    if (self.isSecurity) {
//        long inputTextLength = [inputText length];
//        __autoreleasing NSString* tempStr = [[NSString alloc] initWithUTF8String:""];
//        while (inputTextLength) {
//            inputTextLength--;
//            tempStr = [tempStr stringByAppendingString:@"●"];
//        }
//
//        [super setText:tempStr];
//        //        self.cipherText = [NSData AES256EncryptWithPlainText:inputText];
//    }else{
//        [super setText:inputText];
//    }
//}

-(void)setSecureTextEntry:(BOOL)secureTextEntry{
    [super setSecureTextEntry:NO];
    
    self.isSecurity = !secureTextEntry;
//    if (secureTextEntry) {
//        [self setText:self.text];
//    }
}

#pragma mark - blink Timer blink

- (void)blink:(NSTimer *)theTimer {
    loopCount++;
    if (loopCount > kCountOfBlinkTimes) {
        int index = [[theTimer userInfo] intValue];
        [blinkTimer invalidate];
        blinkTimer = nil;
        loopCount = 0;
        
        [super setText:[self.text stringByReplacingCharactersInRange:NSMakeRange(index, 1) withString:@"●"]];
    } else {
        
    }
    loopCount++;
}

-(void)numberButton:(KQKeyboardView*)keyboard
              value:(NSInteger)value{
    UITextRange *selRange = self.selectedTextRange;
    
    if (selRange.isEmpty) {
        
        // 输入长度限制
        if([self.text length]>=self.maxLength){return;}
        
        NSInteger idx = [self selectedRangeIndex];
        NSRange range = NSMakeRange(idx, 0);
        if (self.isSecurity) {
            if (blinkTimer) {
                [super setText:[self.text stringByReplacingCharactersInRange:NSMakeRange(idx-1, 1) withString:@"●"]];
                [blinkTimer invalidate];
                blinkTimer = nil;
                loopCount = 0;
            }
            
            blinkTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                          target:self
                                                        selector:@selector(blink:)
                                                        userInfo:[NSNumber numberWithInt:(int)idx]
                                                         repeats:YES];
            
            [super setText:[NSString stringWithFormat:@"%@%ld%@",[self.text substringToIndex:idx],(long)value,[self.text substringFromIndex:idx]]];
            [self updateCipherTextInRange:range string:[NSString stringWithFormat:@"%zd",value]];
        } else {
            [self changeCharactersInRange:range replacementString:[NSString stringWithFormat:@"%zd",value]];
        }
        [self setSelectedRangeWithIndex:idx + 1];
        
        if([self.kqTextfieldDelegate respondsToSelector:@selector(addNumber: number:)])
            [self.kqTextfieldDelegate addNumber:self number:[NSString stringWithFormat:@"%ld",(long)value]];
    }
}

-(void)deleteButton:(KQKeyboardView*)keyboard{
    UITextRange *selRange = self.selectedTextRange;
    if (selRange.isEmpty) {
        NSInteger idx = [self selectedRangeIndex];
        if (idx) {
            if (self.isSecurity) {
                if (blinkTimer) {
                    [blinkTimer invalidate];
                    blinkTimer = nil;
                    loopCount = 0;
                }
            }
            NSRange range = NSMakeRange(idx - 1, 1);
            if (self.isSecurity) {
                [super setText:[NSString stringWithFormat:@"%@%@",[self.text substringToIndex:idx-1],[self.text substringFromIndex:idx]]];
                [self updateCipherTextInRange:range string:@""];
            } else {
                [self changeCharactersInRange:range replacementString:@""];
            }
            [self setSelectedRangeWithIndex:idx - 1];
        }
        
        if([self.kqTextfieldDelegate respondsToSelector:@selector(deleteNumber:)])
            [self.kqTextfieldDelegate deleteNumber:self];
    }
}
#pragma  mark - 清除文字框内容
- (void)allTextClear {
    [super allTextClear];
    
    if (self.isSecurity) {
        if (blinkTimer) {
            [blinkTimer invalidate];
            blinkTimer = nil;
            loopCount = 0;
        }
    }
}

#pragma mak - 创建输入框
+ (KQSecureTextField *)addSecureTextField:(CGRect)frame
                          placeholderText:(NSString *)text
                                     font:(UIFont *)font
                          minimumFontSize:(float)minimumFontSize
                             keyboardType:(UIKeyboardType)UIKeyboardType
                                 delegate:(id)delegate
{
    KQSecureTextField *temptextField = [[KQSecureTextField alloc] initWithFrame:frame];
    [temptextField setKeyboardType:UIKeyboardType];
    [temptextField setPlaceholder:text];
    [temptextField setFont:font];
    [temptextField setAdjustsFontSizeToFitWidth:YES];
    [temptextField setMinimumFontSize:minimumFontSize];
    [temptextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [temptextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [temptextField setDelegate:delegate];
    [temptextField setKqTextfieldDelegate:delegate];
    
    return temptextField;
}
@end

