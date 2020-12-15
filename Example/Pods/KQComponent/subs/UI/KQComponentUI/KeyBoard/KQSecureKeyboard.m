//
//  KQSecureKeyboard.m
//  kuaiQianbao
//
//  Created by building wang on 16/4/6.
//
//

#import "KQSecureKeyboard.h"
#import "UITextField+KQBAddition.h"

enum {
    KQKeyBoardImageLeft = 0,
    KQKeyBoardImageInner,
    KQKeyBoardImageRight,
    KQKeyBoardImageMax
};

@interface UIImage (PBHelper)

+ (nullable UIImage *)pb_imageFromColor:(nullable UIColor *)color;

- (nullable UIImage *)pb_drawRectWithRoundCorner:(CGFloat)radius toSize:(CGSize)size;

@end

@interface KQChar : UIButton

- (void)shift:(BOOL)shift;

- (void)updateChar:(nullable NSString *)chars;

- (void)updateChar:(nullable NSString *)chars shift:(BOOL)shift;

- (void)addPopup;

@end

static const NSInteger kKeyBoardH = 216;
static const NSInteger kCICOKQ = 44;
static const NSInteger kCHAR_CORNER = 5;
static const NSInteger kKeyBoardFontSize = 18;
static const NSInteger kKeyBoardBottomFontSize = 15;


#define KQKeyBoardFont(s)                        [UIFont fontWithName:@"HelveticaNeue-Light" size:s]

@interface KQSecureKeyboard ()

@property (nonatomic, assign) KQKeyBoardType type;
@property (nonatomic, assign) BOOL shiftEnable,showSymbol,showMoreSymbol;
@property (nonatomic, strong) NSMutableArray *charsBtn;

@property (nonatomic, strong) UIButton *shiftBtn,*charSymSwitch;

@property (nonatomic, assign) BOOL isKeepCapital;     // 保持大写

@end

@implementation KQSecureKeyboard

+ (nullable)keyboardWithType:(KQKeyBoardType)type {
    CGFloat viewHeight = KQC_HAS_NOTCH ? kKeyBoardH+kCICOKQ+34 : kKeyBoardH+kCICOKQ;
    return [[KQSecureKeyboard alloc] initWithFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, viewHeight) withType:type];
}

- (id)initWithFrame:(CGRect)frame withType:(KQKeyBoardType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.type = KQKeyBoardTypeNumberPad;
        [self initSetup];
    }
    return self;
}

- (void)initSetup {
    //默认信息
    self.backgroundColor = UIColorFromRGB(0x80, 0x8b, 0xa3);
    [self initLogoView];
    //创建键盘
    if (KQKeyBoardTypeNumberPad == self.type) {
        [self reloadNumberPad:false];
    }else if (KQKeyBoardTypeDecimalPad == self.type){
        [self reloadNumberPad:true];
    }else if (KQKeyBoardTypeASCIICapable == self.type){
        [self setupASCIICapableLayout:true];
    }
}

- (void)initLogoView {
    UIView *logoView = [[UIView alloc] init];
    logoView.backgroundColor = UIColorFromRGB(140, 150, 172);
    [self addSubview:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@44);
    }];
    
    UIView *helperView = [[UIView alloc] init];
    [logoView addSubview:helperView];
    [helperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(logoView);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage kqb_imageNamed:@"secure_white"]];
    [logoView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.mas_equalTo(@19);
        make.height.mas_equalTo(@19);
        make.centerY.equalTo(logoView);
        make.left.equalTo(helperView);
    }];
    
    UILabel *titleLabel = [UILabel addLabel:@"快钱安全键盘" frame:CGRectZero size:15 isBold:NO textAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] tag:0 intoView:logoView];
    [titleLabel sizeToFit];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(logoView);
        make.left.equalTo(imageView.mas_right).with.offset(12);
        make.right.equalTo(helperView);
    }];
    
    UIImage *downImage = [UIImage kqb_imageNamed:@"fold"];
    UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downButton setImage:downImage forState:UIControlStateNormal];
    [downButton addTarget: self action:@selector(charDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    [logoView addSubview:downButton];
    
    [downButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.mas_equalTo(downImage.size.width);
        make.height.mas_equalTo(downImage.size.height);
        make.centerY.equalTo(logoView);
        make.right.equalTo(logoView).offset(-15);
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    //NSLog(@"%s--%@",__FUNCTION__,newSuperview);
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    //NSLog(@"%s--%@",__FUNCTION__,newWindow);
    if (!newWindow && self.type != KQKeyBoardTypeASCIICapable) {
        [self loadRandomNumber];
    }
    self.showSymbol = NO;
    self.shiftEnable = NO;
    NSString *title = self.showSymbol?@"ABC":@".?123";
    [self.charSymSwitch setTitle:title forState:UIControlStateNormal];
    [self updateShiftBtnTitleState];
    [self setupASCIICapableLayout:false];
}

#pragma mark -- 数字键盘 --
- (void)reloadNumberPad:(BOOL)decimal {
    if (self.type != KQKeyBoardTypeASCIICapable) {
        
        NSInteger cols = 3;
        NSInteger rows = 4;
        UIColor *lineColor = UIColorFromRGB(101, 101, 101);
        UIColor *titleColor = [UIColor blackColor];
        UIColor *touchColor = UIColorFromRGB(250, 250, 250);
        UIFont *titleFont = KQKeyBoardFont(kKeyBoardFontSize);
        CGFloat itemH = kKeyBoardH/rows;
        CGFloat itemW = KQC_SCREEN_WIDTH/cols;
        for (NSInteger i = 0; i < rows; i++) {
            for (NSInteger j = 0; j < cols; j++) {
                CGRect bounds = CGRectMake(j*itemW, i*itemH+kCICOKQ, itemW, itemH);
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setHighlighted:true];
                btn.exclusiveTouch = true;
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = lineColor.CGColor;
                btn.frame = bounds;
                btn.titleLabel.font = titleFont;
                btn.titleLabel.textAlignment = NSTextAlignmentCenter;
                btn.titleLabel.textColor = titleColor;
                [btn setTitleColor:titleColor forState:UIControlStateNormal];
                [btn setTitleColor:touchColor forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
                [btn addTarget:self action:@selector(touchCancelAction:) forControlEvents:UIControlEventTouchDragOutside];
                SEL selector;
                
                if (i*(rows-1)+j == (rows*cols-2-1)) {
                    selector = decimal?@selector(numberOrDecimalAction:):@selector(doneAction:);
                }else if (i*(rows-1)+j == (rows*cols-1)){
                    selector = @selector(deleteAction:);
                }else if (i*(rows-1)+j == (rows*cols-1-1)){
                    selector = @selector(numberOrDecimalAction:);
                }else{
                    selector = @selector(numberOrDecimalAction:);
                }
                NSInteger tag = i*(rows-1)+j;
                [btn setTag:tag];
                [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
                
            }
        }
        
        [self loadRandomNumber];
    }
}

- (void)loadRandomNumber {
    BOOL decimal = (self.type == KQKeyBoardTypeDecimalPad);
    NSArray *titles = [self generateRandomNumberWithDecimal:decimal];
    NSArray *subviews = self.subviews;
    [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *tmp = (UIButton *)obj;
            NSInteger __tag = tmp.tag;
            NSString *title ;
            if (__tag == 9) {
                title = decimal?[titles objectAtIndex:__tag]:@"完成";
            }else if (__tag == 10) {
                title = [titles lastObject];
            }else if (__tag == 11){
                title = @"删除";
            }else {
                title = [titles objectAtIndex:__tag];
            }
            [tmp setTitle:title forState:UIControlStateNormal];
        }
    }];
}

#pragma mark -- 数字键盘 Action --
- (void)touchDownAction:(UIButton *)btn {
    UIColor *touchColor = [UIColor whiteColor];
    [btn setBackgroundColor:touchColor];
}

- (void)touchCancelAction:(UIButton *)btn {
    [btn setBackgroundColor:[UIColor clearColor]];
}

- (void)doneAction:(UIButton *)btn {
    [btn setBackgroundColor:[UIColor clearColor]];
    if (self.inputSource) {
        if ([self.inputSource isKindOfClass:[UITextField class]]) {
            UITextField *tmp = (UITextField *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
                BOOL ret = [tmp.delegate textFieldShouldEndEditing:tmp];
                [tmp endEditing:ret];
            }else{
                [tmp resignFirstResponder];
            }
            
        }else if ([self.inputSource isKindOfClass:[UITextView class]]){
            UITextView *tmp = (UITextView *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
                BOOL ret = [tmp.delegate textViewShouldEndEditing:tmp];
                [tmp endEditing:ret];
            }else{
                [tmp resignFirstResponder];
            }
            
        }else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
            UISearchBar *tmp = (UISearchBar *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
                BOOL ret = [tmp.delegate searchBarShouldEndEditing:tmp];
                [tmp endEditing:ret];
            }else{
                [tmp resignFirstResponder];
            }
        }
    }
}

- (void)deleteAction:(UIButton *)btn {
    if (self.inputSource) {
        if ([self.inputSource isKindOfClass:[UITextField class]]) {
            UITextField *tmp = (UITextField *)self.inputSource;
            [tmp deleteBackward];
            NSString *tmpInfo = tmp.text;
            if (tmpInfo.length > 0) {
                if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                    NSRange range = NSMakeRange(tmpInfo.length-1, 1);
                    BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:tmpInfo];
                    if (ret) {
                        [tmp deleteBackward];
                    }
                }else{
                    [tmp deleteBackward];
                }
            }
            
        }else if ([self.inputSource isKindOfClass:[UITextView class]]){
            UITextView *tmp = (UITextView *)self.inputSource;
            [tmp deleteBackward];
        }else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
            UISearchBar *tmp = (UISearchBar *)self.inputSource;
            NSMutableString *info = [NSMutableString stringWithString:tmp.text];
            if (info.length > 0) {
                NSString *s = [info substringToIndex:info.length-1];
                [tmp setText:s];
            }
        }
    }
    [btn setBackgroundColor:[UIColor clearColor]];
}

- (void)numberOrDecimalAction:(UIButton *)btn {
    NSString *title = [btn titleLabel].text;
    if (self.inputSource) {
        if ([self.inputSource isKindOfClass:[UITextField class]]) {
            UITextField *tmp = (UITextField *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                NSRange range = NSMakeRange(tmp.text.length, 1);
                BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:title];
                if (ret) {
                    [tmp insertText:title];
                }
            }else{
                [tmp insertText:title];
            }
            
        }else if ([self.inputSource isKindOfClass:[UITextView class]]){
            UITextView *tmp = (UITextView *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                NSRange range = NSMakeRange(tmp.text.length, 1);
                BOOL ret = [tmp.delegate textView:tmp shouldChangeTextInRange:range replacementText:title];
                if (ret) {
                    [tmp insertText:title];
                }
            }else{
                [tmp insertText:title];
            }
            
        }else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
            UISearchBar *tmp = (UISearchBar *)self.inputSource;
            NSMutableString *info = [NSMutableString stringWithString:tmp.text];
            [info appendString:title];
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
                NSRange range = NSMakeRange(tmp.text.length, 1);
                BOOL ret = [tmp.delegate searchBar:tmp shouldChangeTextInRange:range replacementText:title];
                if (ret) {
                    [tmp setText:[info copy]];
                }
            }else{
                [tmp setText:[info copy]];
            }
        }
    }
    [btn setBackgroundColor:[UIColor clearColor]];
}

- (void)change2System {
    if (self.inputSource) {
        if ([self.inputSource isKindOfClass:[UITextField class]]) {
            UITextField *tmp = (UITextField *)self.inputSource;
            tmp.inputView = nil;
            [tmp reloadInputViews];
        }else if ([self.inputSource isKindOfClass:[UITextView class]]){
            UITextView *tmp = (UITextView *)self.inputSource;
            tmp.inputView = nil;
            [tmp reloadInputViews];
        }else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
            UISearchBar *tmp = (UISearchBar *)self.inputSource;
            tmp.inputViewController.inputView = nil;
            [tmp reloadInputViews];
        }
    }
}

- (void)change2Custom {
    if (self.inputSource) {
        
    }
}

// 选择一个n以下的随机整数
// 计算m, 2的幂略高于n, 然后采用 random() 模数m,
// 如果在n和m之间就扔掉随机数
// (更多单纯的方法, 比如采用random()模数n, 介绍一个偏置)
// 倾向范围内较小的数字
static NSInteger random_below(NSInteger n) {
    NSInteger m = 1;
    //计算比n更大的两个最小的幂
    do {
        m <<= 1;
    } while(m < n);
    
    NSInteger ret;
    do {
        ret = random() % m;
    } while(ret >= n);
    return ret;
}

static inline NSInteger random_int(NSInteger low, NSInteger high) {
    return (arc4random() % (high-low+1)) + low;
}

- (NSArray *)generateRandomNumberWithDecimal:(BOOL)decimal {
    NSMutableArray *tmp = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        NSString *c = KQC_FORMAT(@"%ld",(long)i);
        [tmp addObject:c];
    }
    if (decimal) {
        [tmp addObject:@"."];
    }
    NSInteger len = (NSInteger)[tmp count];
    NSInteger max = random_below(len);
    NSLog(@"max :%ld",(long)max);
    for (NSInteger i = 0; i < max; i++) {
        NSInteger t = random_int(0, len-1);
        NSInteger index = (t+max)%len;
        [tmp exchangeObjectAtIndex:t withObjectAtIndex:index];
    }
    return [tmp copy];
}

#pragma mark -- 密码键盘 --

#define Characters @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m"]
#define Symbols  @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"-",@"/",@":",@";",@"(",@")",@"$",@"&",@"@",@"\"",@".",@",",@"?",@"!",@"'"]
#define moreSymbols  @[@"[",@"]",@"{",@"}",@"#",@"%",@"^",@"*",@"+",@"=",@"_",@"\\",@"|",@"~",@"<",@">",@"€",@"£",@"¥",@"•",@".",@",",@"?",@"!",@"'"]
//布局键盘
- (void)setupASCIICapableLayout:(BOOL)init {
    
    if (!init) {
        //不是初始化创建 重新布局字母或字符界面
        NSArray *subviews = self.subviews;
        [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[KQChar class]]) {
                [obj removeFromSuperview];
            }
        }];
    }
    if (_charsBtn || _charsBtn.count) {
        [_charsBtn removeAllObjects];
        _charsBtn = nil;
    }
    _charsBtn = [NSMutableArray arrayWithCapacity:0];
    
    NSArray *charSets ;NSArray *rangs;
    if (!self.showSymbol) {
        charSets = Characters;
        rangs = @[@10,@19,@26];
    }else{
        charSets = self.showMoreSymbol? moreSymbols:Symbols;
        rangs = @[@10,@20,@25];
    }
    
    //第一排
    NSInteger loc = 0;
    NSInteger length = [[rangs objectAtIndex:0] integerValue];
    NSArray *chars = [charSets subarrayWithRange:NSMakeRange(loc, length)];
    //NSLog(@"第一排:%@",chars);
    NSInteger len = [chars count];
    CGFloat char_h_dis = 7;
    CGFloat char_v_dis = 13;
    CGFloat char_uper_dis = 10;
    CGFloat char_width = (KQC_SCREEN_WIDTH-char_h_dis*len)/len;
    CGFloat char_heigh = (kKeyBoardH-char_uper_dis*2-char_v_dis*3)/4;
    UIFont *titleFont = KQKeyBoardFont(kKeyBoardFontSize);
    UIFont *bottomFont = KQKeyBoardFont(kKeyBoardBottomFontSize);
    
    UIColor *titleColor = [UIColor blackColor];
    UIColor *bgColor = [UIColor whiteColor];
    UIColor *bgSpecialColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    UIColor *doneBtnColor = UIColorFromRGB(0xf5, 0x4d, 0x4f);
    UIImage *bgImg = [UIImage pb_imageFromColor:bgColor];
    UIImage *bgSpecialImage = [UIImage pb_imageFromColor:bgSpecialColor];
    UIImage *doneBtnImage = [UIImage pb_imageFromColor:doneBtnColor];
    CGFloat cur_y = kCICOKQ+char_uper_dis;
    
    NSInteger n = 0;
    UIImage *charbgImg = [bgImg pb_drawRectWithRoundCorner:kCHAR_CORNER toSize:CGSizeMake(char_width, char_heigh)];
    
    for (NSInteger i = 0 ; i < len; i ++) {
        CGRect bounds = CGRectMake(char_h_dis*0.5+(char_width+char_h_dis)*i, cur_y, char_width, char_heigh);
        //NSString *title = [chars objectAtIndex:i];
        KQChar *btn = [KQChar buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        //btn.chars = title;
        btn.exclusiveTouch = true;
        //消耗性能
        //[btn addRoundCornerBackdround];
        btn.userInteractionEnabled = false;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setBackgroundImage:charbgImg forState:UIControlStateNormal];
        [btn setTag:n+i];
        //[btn addTarget:self action:@selector(characterTouchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self.charsBtn addObject:btn];
    }
    n+=len;
    
    //第二排
    cur_y += char_heigh+char_v_dis;
    loc = [[rangs objectAtIndex:0] integerValue];
    length = [[rangs objectAtIndex:1] integerValue];
    chars = [charSets subarrayWithRange:NSMakeRange(loc, length-loc)];
    //NSLog(@"第二排:%@",chars);
    len = [chars count];
    CGFloat start_x = (KQC_SCREEN_WIDTH-char_width*len-char_h_dis*(len-1))/2;
    for (NSInteger i = 0 ; i < len; i ++) {
        CGRect bounds = CGRectMake(start_x+(char_width+char_h_dis)*i, cur_y, char_width, char_heigh);
        KQChar *btn = [KQChar buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.userInteractionEnabled = false;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setBackgroundImage:charbgImg forState:UIControlStateNormal];
        [btn setTag:n+i];
        [self addSubview:btn];
        [self.charsBtn addObject:btn];
    }
    n+=len;
    
    //第三排
    cur_y += char_heigh+char_v_dis;
    loc = [[rangs objectAtIndex:1] integerValue];
    length = [[rangs objectAtIndex:2] integerValue];
    chars = [charSets subarrayWithRange:NSMakeRange(loc, length-loc)];
    //NSLog(@"第三排:%@",chars);
    len = [chars count];
    //CGFloat shift_dis = char_h_dis*1.5;
    CGFloat shiftWidth = char_width*1.5;
    char_width = (KQC_SCREEN_WIDTH-char_h_dis*4-shiftWidth*2-char_h_dis*(len-1))/len;
    charbgImg = [bgImg pb_drawRectWithRoundCorner:kCHAR_CORNER toSize:CGSizeMake(char_width, char_heigh)];
    CGRect bounds;UIButton *btn;
    if (init) {
        UIImage *roundImg = [bgSpecialImage pb_drawRectWithRoundCorner:kCHAR_CORNER toSize:CGSizeMake(shiftWidth, char_heigh)];
        bounds = CGRectMake(char_h_dis*0.5, cur_y, shiftWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = bottomFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = [UIColor blackColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:roundImg forState:UIControlStateNormal];
        [btn setImage:[UIImage kqb_imageNamed:self.shiftEnable?@"secure_keyboard_shifton":@"secure_keyboard_shiftoff"] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(shiftAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(repeatClick:) forControlEvents:UIControlEventTouchDownRepeat];
        [self addSubview:btn];
        self.shiftBtn = btn;
        
        bounds = CGRectMake(KQC_SCREEN_WIDTH-char_h_dis*0.5-shiftWidth, cur_y, shiftWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        //        [btn setTitle:@"删除" forState:UIControlStateNormal];
        [btn setBackgroundImage:roundImg forState:UIControlStateNormal];
        [btn setImage:[UIImage kqb_imageNamed:@"secure_keyboard_del"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(charDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    for (NSInteger i = 0 ; i < len; i ++) {
        CGRect bounds = CGRectMake(char_h_dis*2+shiftWidth+(char_width+char_h_dis)*i, cur_y, char_width, char_heigh);
        KQChar *btn = [KQChar buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.userInteractionEnabled = false;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setBackgroundImage:charbgImg forState:UIControlStateNormal];
        [btn setTag:n+i];
        [self addSubview:btn];
        [self.charsBtn addObject:btn];
    }
    
    //第四排
    if (init) {
        cur_y += char_heigh+char_v_dis;
        CGFloat numWidth = shiftWidth*2;
        UIImage *leftImg = [bgSpecialImage pb_drawRectWithRoundCorner:kCHAR_CORNER toSize:CGSizeMake(numWidth, char_heigh)];
        UIImage *doneImg = [doneBtnImage pb_drawRectWithRoundCorner:kCHAR_CORNER toSize:CGSizeMake(numWidth, char_heigh)];
        bounds = CGRectMake(char_h_dis*0.5, cur_y, numWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = bottomFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setTitle:@".?123" forState:UIControlStateNormal];
        [btn setBackgroundImage:leftImg forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(charSymbolSwitch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        self.charSymSwitch = btn;
        bounds = CGRectMake(KQC_SCREEN_WIDTH-char_h_dis*0.5-numWidth, cur_y, numWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = bottomFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        [btn setBackgroundImage:doneImg forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(charDoneAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        
        CGFloat spaceWidth = (KQC_SCREEN_WIDTH-char_h_dis*3-numWidth*2);
        bounds = CGRectMake(char_h_dis*1.5+numWidth, cur_y, spaceWidth, char_heigh);
        UIImage *roundImg = [bgImg pb_drawRectWithRoundCorner:(kCHAR_CORNER - 2) toSize:CGSizeMake(spaceWidth, char_heigh)];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = bottomFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setTitle:@"空 格" forState:UIControlStateNormal];
        [btn setBackgroundImage:roundImg forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(charSpaceAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    
    [self loadCharacters:charSets];
}

//加载键盘符号
- (void)loadCharacters:(NSArray *)array {
    
    NSInteger len = [array count];
    if (!array || len == 0) {
        return;
    }
    NSArray *subviews = self.subviews;
    [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[KQChar class]]) {
            KQChar *tmp = (KQChar *)obj;
            NSInteger __tag = tmp.tag;
            //NSLog(@"__tag:%zd---index:%d",__tag,idx);
            if (__tag < len) {
                NSString *tmpTitle = [array objectAtIndex:__tag];
                //NSLog(@"char:%@",tmpTitle);
                if (self.showSymbol) {
                    [tmp updateChar:tmpTitle];
                }else{
                    [tmp updateChar:tmpTitle shift:self.shiftEnable];
                }
            }
        }
    }];
}

#pragma mark -- 字符键盘 Action --

- (void)shiftAction:(UIButton *)btn {
    if (self.showSymbol) {
        //正显示字符符号 无需切换大写
        self.showMoreSymbol = !self.showMoreSymbol;
        [self updateShiftBtnTitleState];
        NSArray *__symbols = self.showMoreSymbol?moreSymbols:Symbols;
        [self loadCharacters:__symbols];
    }else{
        [self performSelector:@selector(tabButtonTap:) withObject:btn afterDelay:0.2];
    }
}

- (void)tabButtonTap:(UIButton *)sender{
    self.shiftEnable = !self.shiftEnable;
    [self.shiftBtn  setImage:[UIImage kqb_imageNamed:self.shiftEnable?@"secure_keyboard_shifton":@"secure_keyboard_shiftoff"] forState:UIControlStateNormal];
    NSArray *subChars = [self subviews];
    [subChars enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[KQChar class]]) {
            KQChar *tmp = (KQChar *)obj;
            [tmp shift:self.shiftEnable];
        }
    }];
    
    if (!self.shiftEnable) {
        self.isKeepCapital = NO;
    }
}

//字母 符号切换
- (void)charSymbolSwitch:(UIButton *)btn {
    self.showSymbol = !self.showSymbol;
    self.showMoreSymbol = NO;
    self.isKeepCapital = NO;
    self.shiftEnable = NO;
    NSString *title = self.showSymbol?@"ABC":@".?123";
    [self.charSymSwitch setTitle:title forState:UIControlStateNormal];
    [self updateShiftBtnTitleState];
    [self setupASCIICapableLayout:false];
}

#pragma mark - 双击事件
- (void)repeatClick:(UIButton *)btn{
    if (!self.showSymbol) {
        self.isKeepCapital = YES;
        if (!self.shiftEnable) {
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(tabButtonTap:) object:btn];
        }
    }
}

- (void)updateShiftBtnTitleState {
    NSString *title ;
    if (self.showSymbol) {
        title = self.showMoreSymbol?@"123":@"#+=";
        [self.shiftBtn setImage:[UIImage kqb_imageNamed:@""] forState:UIControlStateNormal];
        [self.shiftBtn setTitle:title forState:UIControlStateNormal];
    }else{
        [self.shiftBtn  setImage:[UIImage kqb_imageNamed:self.shiftEnable?@"secure_keyboard_shifton":@"secure_keyboard_shiftoff"] forState:UIControlStateNormal];
        [self.shiftBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

#pragma mark - 增加删除按钮事件
- (void)characterTouchAction:(KQChar *)btn {
    
    NSString *title = [btn titleLabel].text;
    if (self.inputSource) {
        if ([self.inputSource isKindOfClass:[UITextField class]]) {
            UITextField *tmp = (UITextField *)self.inputSource;
            
            if([tmp.text length]>= _maxLength){
                return;
            }
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                NSRange range = NSMakeRange([tmp selectedRangeIndex], 0);
                BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:title];
                if (ret) {
                    [tmp insertText:title];
                }
            }else{
                [tmp insertText:title];
            }
            if (!_isKeepCapital && !self.showSymbol && self.shiftEnable) {
                [self shiftAction:nil];
            }
        }else if ([self.inputSource isKindOfClass:[UITextView class]]){
            UITextView *tmp = (UITextView *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                NSRange range = NSMakeRange(tmp.text.length, 1);
                BOOL ret = [tmp.delegate textView:tmp shouldChangeTextInRange:range replacementText:title];
                if (ret) {
                    [tmp insertText:title];
                }
            }else{
                [tmp insertText:title];
            }
            
        }else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
            UISearchBar *tmp = (UISearchBar *)self.inputSource;
            NSMutableString *info = [NSMutableString stringWithString:tmp.text];
            [info appendString:title];
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
                NSRange range = NSMakeRange(tmp.text.length, 1);
                BOOL ret = [tmp.delegate searchBar:tmp shouldChangeTextInRange:range replacementText:title];
                if (ret) {
                    [tmp setText:[info copy]];
                }
            }else{
                [tmp setText:[info copy]];
            }
        }
        [_delegate letterNumberButton:self value:title];
    }
}

- (void)charSpaceAction:(UIButton *)btn {
    NSString *title = @" ";
    if (self.inputSource) {
        if ([self.inputSource isKindOfClass:[UITextField class]]) {
            UITextField *tmp = (UITextField *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                NSRange range = NSMakeRange([tmp selectedRangeIndex], 0);
                BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:title];
                if (ret) {
                    [tmp insertText:title];
                }
            }else{
                [tmp insertText:title];
            }
            
        }else if ([self.inputSource isKindOfClass:[UITextView class]]){
            UITextView *tmp = (UITextView *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                NSRange range = NSMakeRange(tmp.text.length, 1);
                BOOL ret = [tmp.delegate textView:tmp shouldChangeTextInRange:range replacementText:title];
                if (ret) {
                    [tmp insertText:title];
                }
            }else{
                [tmp insertText:title];
            }
            
        }else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
            UISearchBar *tmp = (UISearchBar *)self.inputSource;
            NSMutableString *info = [NSMutableString stringWithString:tmp.text];
            [info appendString:title];
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
                NSRange range = NSMakeRange(tmp.text.length, 1);
                BOOL ret = [tmp.delegate searchBar:tmp shouldChangeTextInRange:range replacementText:title];
                if (ret) {
                    [tmp setText:[info copy]];
                }
            }else{
                [tmp setText:[info copy]];
            }
        }
    }
}

- (void)charDeleteAction:(UIButton *)btn {
    if (self.inputSource) {
        if ([self.inputSource isKindOfClass:[UITextField class]]) {
            UITextField *tmp = (UITextField *)self.inputSource;
            //            [tmp deleteBackward];
            NSInteger idx = [tmp selectedRangeIndex];
            NSString *tmpInfo = tmp.text;
            if (tmpInfo.length > 0 && idx != 0) {
                if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                    NSRange range = NSMakeRange(idx - 1, 1);
                    BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:@""];
                    if (ret) {
                        [tmp deleteBackward];
                    }
                }else{
                    [tmp deleteBackward];
                }
            }
        }else if ([self.inputSource isKindOfClass:[UITextView class]]){
            UITextView *tmp = (UITextView *)self.inputSource;
            [tmp deleteBackward];
        }else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
            UISearchBar *tmp = (UISearchBar *)self.inputSource;
            NSMutableString *info = [NSMutableString stringWithString:tmp.text];
            if (info.length > 0) {
                NSString *s = [info substringToIndex:info.length-1];
                [tmp setText:s];
            }
        }
        [_delegate letterDeleteButton:self];
    }
}

- (void)charDoneAction:(UIButton *)btn {
    if (self.inputSource) {
        if ([self.inputSource isKindOfClass:[UITextField class]]) {
            UITextField *tmp = (UITextField *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
                BOOL ret = [tmp.delegate textFieldShouldEndEditing:tmp];
                [tmp endEditing:ret];
            }else{
                [tmp resignFirstResponder];
            }
            
        }else if ([self.inputSource isKindOfClass:[UITextView class]]){
            UITextView *tmp = (UITextView *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
                BOOL ret = [tmp.delegate textViewShouldEndEditing:tmp];
                [tmp endEditing:ret];
            }else{
                [tmp resignFirstResponder];
            }
            
        }else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
            UISearchBar *tmp = (UISearchBar *)self.inputSource;
            
            if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
                BOOL ret = [tmp.delegate searchBarShouldEndEditing:tmp];
                [tmp endEditing:ret];
            }else{
                [tmp resignFirstResponder];
            }
        }
        [_delegate letterDoneButton:self];
    }
}

- (BOOL)resignFirstResponder {
    if (self.inputSource) {
        [self.inputSource resignFirstResponder];
    }
    return[super resignFirstResponder];
}

#pragma mark -- 键盘Pan --

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"_%s_",__FUNCTION__);
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (KQChar *tmp in self.charsBtn) {
        NSArray *subs = [tmp subviews];
        if (subs.count == 3) {
            [[subs lastObject] removeFromSuperview];
        }
        if (CGRectContainsPoint(tmp.frame, touchPoint)) {
            [tmp addPopup];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"_%s_",__FUNCTION__);
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (KQChar *tmp in self.charsBtn) {
        NSArray *subs = [tmp subviews];
        if (subs.count == 3) {
            [[subs lastObject] removeFromSuperview];
        }
        if (CGRectContainsPoint(tmp.frame, touchPoint)) {
            [tmp addPopup];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"_%s_",__FUNCTION__);
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (KQChar *tmp in self.charsBtn) {
        NSArray *subs = [tmp subviews];
        if (subs.count == 3) {
            [[subs lastObject] removeFromSuperview];
        }
        if (CGRectContainsPoint(tmp.frame, touchPoint)) {
            [self characterTouchAction:tmp];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"_%s_",__FUNCTION__);
    for (KQChar *tmp in self.charsBtn) {
        NSArray *subs = [tmp subviews];
        if (subs.count == 3) {
            [[subs lastObject] removeFromSuperview];
        }
    }
}

@end

@implementation UIImage (PBHelper)
+ (UIImage *)pb_imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)pb_drawRectWithRoundCorner:(CGFloat)radius toSize:(CGSize)size {
    CGRect bounds = CGRectZero;
    bounds.size = size;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    [self drawInRect:bounds];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

@end

@interface KQChar ()

@property (nonatomic, copy, nullable) NSString *chars;
@property (nonatomic, assign) BOOL isShift;
@property (nonatomic, assign) BOOL isNoOrSymbol;

@end

@implementation KQChar

- (void)addRoundCornerBackdround {
    CGSize size = [self bounds].size;
    UIImage *backImg = [UIImage pb_imageFromColor:UIColorFromRGB(64, 66, 68)];
    backImg = [backImg pb_drawRectWithRoundCorner:kCHAR_CORNER toSize:size];
    [self setBackgroundImage:backImg forState:UIControlStateNormal];
}

- (void)updateChar:(nullable NSString *)chars {
    self.isNoOrSymbol = YES;
    if (chars.length > 0) {
        _chars = [chars copy];
        [self updateTitleState];
    }
}

- (void)updateChar:(nullable NSString *)chars shift:(BOOL)shift {
    self.isNoOrSymbol = NO;
    if (chars.length > 0) {
        _chars = [chars copy];
        self.isShift = shift;
        [self updateTitleState];
    }
}

- (void)shift:(BOOL)shift {
    if (shift == self.isShift) {
        return;
    }
    self.isShift = shift;
    [self updateTitleState];
}

- (void)updateTitleState {
    NSString *tmp = self.isShift?[self.chars uppercaseString]:[self.chars lowercaseString];
    if ([[NSThread currentThread] isMainThread]) {
        [self setTitle:tmp forState:UIControlStateNormal];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTitle:tmp forState:UIControlStateNormal];
        });
    }
}

#define _UPPER_WIDTH   (50.0 * [[UIScreen mainScreen] scale])
#define _LOWER_WIDTH   (30.0 * [[UIScreen mainScreen] scale])

#define _PAN_UPPER_RADIUS  (7.0 * [[UIScreen mainScreen] scale])
#define _PAN_LOWER_RADIUS  (7.0 * [[UIScreen mainScreen] scale])

#define _PAN_UPPDER_WIDTH   (_UPPER_WIDTH-_PAN_UPPER_RADIUS*2)
#define _PAN_UPPER_HEIGHT    (60.0 * [[UIScreen mainScreen] scale])

#define _PAN_LOWER_WIDTH     (_LOWER_WIDTH-_PAN_LOWER_RADIUS*2)
#define _PAN_LOWER_HEIGHT    (30.0 * [[UIScreen mainScreen] scale])

#define _PAN_UL_WIDTH        ((_UPPER_WIDTH-_LOWER_WIDTH)/2)

#define _PAN_MIDDLE_HEIGHT    (11.0 * [[UIScreen mainScreen] scale])

#define _PAN_CURVE_SIZE      (7.0 * [[UIScreen mainScreen] scale])

#define _PADDING_X     (15 * [[UIScreen mainScreen] scale])
#define _PADDING_Y     (11 * [[UIScreen mainScreen] scale])
#define _WIDTH   (_UPPER_WIDTH + _PADDING_X*2)
#define _HEIGHT   (_PAN_UPPER_HEIGHT + _PAN_MIDDLE_HEIGHT + _PAN_LOWER_HEIGHT + _PADDING_Y*2)


#define _OFFSET_X    -20 * [[UIScreen mainScreen] scale])
#define _OFFSET_Y    59 * [[UIScreen mainScreen] scale])


- (CGImageRef)createKeytopImageWithKind:(int)kind{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(_PADDING_X, _PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += _PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);
    
    p.x += _PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y += _PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_UPPER_RADIUS,
                 3.0*M_PI/2.0,
                 4.0*M_PI/2.0,
                 false);
    
    p.x += _PAN_UPPER_RADIUS;
    p.y += _PAN_UPPER_HEIGHT - _PAN_UPPER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + _PAN_CURVE_SIZE);
    switch (kind) {
        case KQKeyBoardImageLeft:
            p.x -= _PAN_UL_WIDTH*2;
            break;
            
        case KQKeyBoardImageInner:
            p.x -= _PAN_UL_WIDTH;
            break;
            
        case KQKeyBoardImageRight:
            break;
    }
    
    p.y += _PAN_MIDDLE_HEIGHT + _PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y - _PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y += _PAN_LOWER_HEIGHT - _PAN_CURVE_SIZE - _PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x -= _PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_LOWER_RADIUS,
                 4.0*M_PI/2.0,
                 1.0*M_PI/2.0,
                 false);
    
    p.x -= _PAN_LOWER_WIDTH;
    p.y += _PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y -= _PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_LOWER_RADIUS,
                 1.0*M_PI/2.0,
                 2.0*M_PI/2.0,
                 false);
    
    p.x -= _PAN_LOWER_RADIUS;
    p.y -= _PAN_LOWER_HEIGHT - _PAN_LOWER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - _PAN_CURVE_SIZE);
    
    switch (kind) {
        case KQKeyBoardImageLeft:
            break;
            
        case KQKeyBoardImageInner:
            p.x -= _PAN_UL_WIDTH;
            break;
            
        case KQKeyBoardImageRight:
            p.x -= _PAN_UL_WIDTH*2;
            break;
    }
    
    p.y -= _PAN_MIDDLE_HEIGHT + _PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y + _PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y -= _PAN_UPPER_HEIGHT - _PAN_UPPER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x += _PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_UPPER_RADIUS,
                 2.0*M_PI/2.0,
                 3.0*M_PI/2.0,
                 false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(_WIDTH,
                                           _HEIGHT));
    context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, _HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGFloat components[] = {
        1.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 1.0f};
    
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 2);
    
    CGRect frame = CGPathGetBoundingBox(path);
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = frame.origin;
    endPoint.y = frame.origin.y + frame.size.height;
    
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, NULL, count);
    
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    CFRelease(path);
    
    return imageRef;
}

#define kSymbolArray @[@".",@",",@"?",@"!",@"'"]

- (void)addPopup {
    UIImageView *keyPop;
    BOOL isSpecialSymbol = [kSymbolArray containsObject:self.chars];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat widthRatio = KQC_WIDTH_RATIO;
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(_PADDING_X/scale, _PADDING_Y/scale,isSpecialSymbol ? (50 + 30)* widthRatio : 50 * widthRatio, _PAN_UPPER_HEIGHT/scale)];
    
    if ([self.chars isEqualToString:@"q"] ||
        [self.chars isEqualToString:@"a"] ||
        [self.chars isEqualToString:@"1"] ||
        [self.chars isEqualToString:@"-"] ||
        [self.chars isEqualToString:@"["] ||
        [self.chars isEqualToString:@"_"]) {
        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:KQKeyBoardImageRight] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
        keyPop.frame = CGRectMake(-16 * widthRatio, -71, keyPop.width * widthRatio, keyPop.height);
    } else if ([self.chars isEqualToString:@"p"] ||
               [self.chars isEqualToString:@"l"] ||
               [self.chars isEqualToString:@"0"] ||
               [self.chars isEqualToString:@"\""]||
               [self.chars isEqualToString:@"="] ||
               [self.chars isEqualToString:@"•"]) {
        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:KQKeyBoardImageLeft] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
        keyPop.frame = CGRectMake(-38 * widthRatio, -71, keyPop.width * widthRatio, keyPop.height);
    } else {
        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:KQKeyBoardImageInner] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDownMirrored]];
        if (isSpecialSymbol) {
            keyPop.frame = CGRectMake(- 35 * widthRatio, -71, (keyPop.width + 27) * widthRatio, keyPop.height);
        } else {
            keyPop.frame = CGRectMake(- 27 * widthRatio, -71, keyPop.width * widthRatio, keyPop.height);
        }
    }
    NSString *tmp = self.isShift?[self.chars uppercaseString]:[self.chars lowercaseString];
    [text setFont:[UIFont fontWithName:KQKeyBoardFont(kKeyBoardFontSize).fontName size:44]];
    [text setTextAlignment:NSTextAlignmentCenter];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setText:tmp];
    [[text layer] setBorderWidth:1.0];//画线的宽度
    [[text layer] setBorderColor:[UIColor clearColor].CGColor];//颜色
    [[text layer]setCornerRadius:7];//圆角
    [text.layer setMasksToBounds:YES];
    
    keyPop.layer.shadowColor = [UIColor whiteColor].CGColor;
    keyPop.layer.shadowOffset = CGSizeMake(0, 3.0);
    keyPop.layer.shadowOpacity = 1;
    keyPop.layer.shadowRadius = 5.0;
    keyPop.clipsToBounds = NO;
    
    [keyPop addSubview:text];
    [self addSubview:keyPop];
}

@end

