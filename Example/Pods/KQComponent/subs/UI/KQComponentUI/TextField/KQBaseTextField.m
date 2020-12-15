//
//  KQCustomTextField.m
//  KQPayPlugin
//
//  Created by Hunter Li on 14-3-3.
//
//

#import "KQBaseTextField.h"
#import "UITextField+KQBAddition.h"

@interface KQBaseTextField()

@property (nonatomic, strong) NSMutableArray *ciperArray;
@property (nonatomic, assign) KQKeyboardStyle contentStyle;

@end

@implementation KQBaseTextField

static BOOL NormalKeyboardShuffle = NO;
static BOOL PayPasswordKeyboardShuffle = NO;
static BOOL LoginPasswordKeyboardShuffle = NO;

static NSString *KQTextFiledSecureAppendKey = @"RBTczXZUW1GX/2yFFj3Fg1UGjQeEZkVWmB4gE2JUELAvHhbEQ3Cev5wN7YU0Ghj0";
static NSString *KQPayPasswordKey = nil;
static NSInteger KeyBoardAESLoopCount = 100;

+ (void)initialize{
    NSString *tempKey = [[KQCDevice deviceId] stringByAppendingString:KQTextFiledSecureAppendKey];
    KQPayPasswordKey = [KQCSecure digestWithSHA256:tempKey];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cipherText = @"";
        self.ciperArray = [NSMutableArray array];
    }
    
    return self;
}

+ (void)keyboardShuffleConfig:(NSDictionary *)config{
    if (config[@(KQKeyboardStyleNormal)]) {
        NormalKeyboardShuffle = [config[@(KQKeyboardStyleNormal)] boolValue];
    }
    
    if (config[@(KQKeyboardStylePayPassword)]) {
        PayPasswordKeyboardShuffle = [config[@(KQKeyboardStylePayPassword)] boolValue];
    }
    
    if (config[@(KQKeyboardStyleLoginPassword)]) {
        LoginPasswordKeyboardShuffle = [config[@(KQKeyboardStyleLoginPassword)] boolValue];
    }
}

- (void)keyborderSytleSet:(KQKeyboardStyle)style
{
    self.contentStyle = style;
    if (style == KQKeyboardStylePayPassword) {
        KQPayKeyboardView *keyV = [[KQPayKeyboardView alloc] init];
        [keyV setIsRandomShuffle:PayPasswordKeyboardShuffle];
        [keyV setDelegate:self];
        [self setInputView:keyV];
    }else if (style == KQKeyboardStyleNormal){
        KQKeyboardView *keyV = [[KQKeyboardView alloc] init];
        [keyV setIsRandomShuffle:NormalKeyboardShuffle];
        [keyV setDelegate:self];
        [self setInputView:keyV];
    } else if (style == KQKeyboardStyleLoginPassword){
        KQSecureKeyboard *kb = [KQSecureKeyboard keyboardWithType:KQKeyBoardTypeASCIICapable];
        self.inputView = kb;
        kb.maxLength = _maxLength;
        [kb setDelegate:self];
        kb.inputSource = self;
    }
}

//-(void)setIsRandomShuffle:(BOOL)isRandomShuffle{
//    if (_isRandomShuffle != isRandomShuffle) {
//        _isRandomShuffle = isRandomShuffle;
//
//        [(KQKeyboardView*)self.inputView setIsRandomShuffle:_isRandomShuffle];
//    }
//}

- (void)setIsSecurity:(BOOL)isSecurity {
    _isSecurity = isSecurity;
    NSInteger idx = [self selectedRangeIndex];
    if (self.isSecurity) {
        if (self.contentStyle != KQKeyboardStylePayPassword) {
            self.text = [KQB_Manager_Secure decryptByAES:self.cipherText];
        } else {
            NSMutableString *plain = [NSMutableString string];
            [self.ciperArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *temp = [self decryptByAES:obj];
                [plain appendString:temp];
            }];
            self.text = plain;
        }
    } else {
        self.text = self.encryptPassword;
    }
    [self setSelectedRangeWithIndex:idx];
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    BOOL retValue = NO;
    
    if (action == @selector(paste:)
        || action == @selector(select:)
        || action == @selector(selectAll:)
        || action == @selector(select:)
        || action == @selector(cut:)
        || action == @selector(copy:)){
        retValue = NO;
    }else{
        retValue = [super canPerformAction:action
                                withSender:sender];
    }
    
    return retValue;
}

#pragma mark - Secure Text Entry Methods

/**
 返回与密文相同长度的‘●’
 
 @return ●●●●●●●
 */
- (NSString *)encryptPassword {
    NSInteger length = 0;
    if (self.contentStyle == KQKeyboardStylePayPassword) {
        length = self.ciperArray.count;
    } else {
        NSString *decrypt = [KQB_Manager_Secure decryptByAES:self.cipherText];
        length = decrypt.length;
    }
    
    NSMutableString *encryptPassword = [NSMutableString string];
    for (NSInteger i = 0; i < length; i++) {
        [encryptPassword appendString:@"●"];
    }
    return [encryptPassword copy];
}


/**
 更新当前密文

 @param range 替换范围
 @param string 替换内容
 */
- (void)updateCipherTextInRange:(NSRange)range string:(NSString *)string {
    if (self.contentStyle != KQKeyboardStylePayPassword) {
        NSString *decrypt = [KQB_Manager_Secure decryptByAES:self.cipherText];
        decrypt = [decrypt stringByReplacingCharactersInRange:range withString:string];
        self.cipherText = [KQB_Manager_Secure encryptByAES:decrypt];
    } else {
        BOOL isDel = [NSString kqc_isBlank:string];
        if (isDel) {
            [self.ciperArray removeObjectAtIndex:range.location];
        } else {
            [self.ciperArray insertObject:[self encryptByAES:string] atIndex:range.location];
        }
    }
}


/**
 更新当前秘闻，并根据环境显示相对应内容

 @param range 替换范围
 @param string 替换内容
 */
- (void)changeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self updateCipherTextInRange:range string:string];
    NSInteger idx = self.selectedRangeIndex;
    self.text = !self.isSecurity ? self.encryptPassword : [self.text stringByReplacingCharactersInRange:range withString:string];;
    if (self.selectedTextRange.isEmpty) {
        if (string.length == 0) {
            idx = range.location;
        } else {
            idx += 1;
        }
        [self setSelectedRangeWithIndex:idx];
    }
}

#pragma mark - KeyBoardEncryt
- (NSString *)encryptByAES:(NSString *)plainText{
    static int saltLength = 32;
    static int ivLength = 16;
    
    NSMutableData *salt = [NSMutableData data];
    NSMutableData *iv = [NSMutableData data];
    
    [self getRandomArray:salt len:saltLength];
    [self getRandomArray:iv len:ivLength];
    
    NSString *cipherStr = [KQCSecure encrypt:plainText aes256Key:KQPayPasswordKey salt:salt iv:iv rounds:KeyBoardAESLoopCount];
    if ([NSString kqc_isBlank:cipherStr]) {
        return @"";
    }
    
    return KQC_FORMAT(@"%@]%@]%@", [salt base64EncodedString], [iv base64EncodedString], cipherStr);
}

- (NSString *)decryptByAES:(NSString *)cipherStr{
    NSArray *fields = [cipherStr componentsSeparatedByString:@"]"];
    if (fields.count != 3) {
        return @"";
    }
    
    NSData *salt = [NSData dataFromBase64String:fields[0]];
    NSData *iv = [NSData dataFromBase64String:fields[1]];
    return [KQCSecure decrypt:fields[2] aes256Key:KQPayPasswordKey salt:salt iv:iv rounds:KeyBoardAESLoopCount];
}

- (void)getRandomArray:(NSMutableData *)data len:(int)len{
    for (int i = 0; i < len; i++) {
        char temp = [KQCMath getRandomNumber:0 to:255];
        [data appendBytes:&temp length:1];
    }
}

#pragma  mark - KQkeyboardViewDelegate
-(void)doneButton:(KQKeyboardView*)keyboard{
    [self resignFirstResponder];
}

-(void)numberButton:(KQKeyboardView*)keyboard
              value:(NSInteger)value{
    UITextRange *selRange = self.selectedTextRange;
    
    if (selRange.isEmpty) {
        // 输入长度限制
        if([self.text length]>=_maxLength){return;}
        NSInteger idx = [self selectedRangeIndex];
        NSString* prefixStr = [self.text substringToIndex:idx];
        NSString* suffixStr = [self.text substringFromIndex:idx];
        [self setText:[NSString stringWithFormat:@"%@%ld%@",prefixStr,(long)value,suffixStr]];
        [self setSelectedRangeWithIndex:idx + 1];
        
        if([_kqTextfieldDelegate respondsToSelector:@selector(addNumber: number:)])
            [_kqTextfieldDelegate addNumber:self number:[NSString stringWithFormat:@"%ld",(long)value]];
    }
}

-(void)deleteButton:(KQKeyboardView*)keyboard{
    UITextRange *selRange = self.selectedTextRange;
    
    if (selRange.isEmpty) {
        NSInteger idx = [self selectedRangeIndex];

        if (idx) {
            NSString* prefixStr = [self.text substringToIndex:idx-1];
            NSString* suffixStr = [self.text substringFromIndex:idx];
            [self setText:[NSString stringWithFormat:@"%@%@",prefixStr,suffixStr]];
            [self setSelectedRangeWithIndex:idx-1];
        }
        
        if([_kqTextfieldDelegate respondsToSelector:@selector(deleteNumber:)])
            [_kqTextfieldDelegate deleteNumber:self];
    }
}

- (NSString *)cipherText{
    if (self.contentStyle != KQKeyboardStylePayPassword) {
        return _cipherText;
    }
    
    NSMutableString *str = [NSMutableString string];
    [self.ciperArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%@||", obj];
    }];
    if (str.length > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 2, 2)];
    }
    return str;
}

#pragma mark - 字母键盘代理
- (void)letterDoneButton:(KQSecureKeyboard * _Nonnull )keyboard{
    [self resignFirstResponder];
}

- (NSInteger)maxTextLength{
    return _maxLength;
}

- (void)letterNumberButton:(KQSecureKeyboard * _Nonnull)keyboard value:(NSString * _Nonnull )value{
    UITextRange *selRange = self.selectedTextRange;
    
    if (selRange.isEmpty) {
        if([_kqTextfieldDelegate respondsToSelector:@selector(addNumber: number:)])
            [_kqTextfieldDelegate addNumber:self number:value];
    }
}

- (void)letterDeleteButton:(KQSecureKeyboard * _Nonnull)keyboard{
    UITextRange *selRange = self.selectedTextRange;
    if (selRange.isEmpty) {
        if([_kqTextfieldDelegate respondsToSelector:@selector(deleteNumber:)])
            [_kqTextfieldDelegate deleteNumber:self];
    }
}

#pragma  mark - 清除文字框内容
- (void)allTextClear {
    [self setText:@""];
    self.cipherText = @"";
    [self.ciperArray removeAllObjects];
}


-(void)dealloc {
    _kqTextfieldDelegate = nil;
}

@end
