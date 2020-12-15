//
//  KQPhoneTextField.m
//  kuaishua
//
//  Created by tianqy on 14-6-24.
//
//

#import "KQPhoneTextField.h"

@implementation KQPhoneTextField

-(void)numberButton:(KQKeyboardView*)keyboard
              value:(NSInteger)value{
    UITextRange *selRange = self.selectedTextRange;
    
    if (selRange.isEmpty) {
        
        // 输入长度限制
        if([self.text length]>=13){return;}
        
        //焦点位置index
        UITextPosition *selStartPos = selRange.start;
        NSInteger idx = [self offsetFromPosition:self.beginningOfDocument
                                      toPosition:selStartPos];
        
        //焦点前空格数 #123 1234 1234
        long prefixSpaceCount = 0;
        if (idx >= 9) {
            prefixSpaceCount = 2;
        }else if(idx  >= 4){
            prefixSpaceCount = 1;
        }
        
        //把空格去掉
        NSString *srcStr = [self.text stringByReplacingOccurrencesOfString:@" "
                                                                withString:@""];
        
        //焦点前字符串
        NSString* prefixStr = [srcStr substringToIndex:idx-prefixSpaceCount];
        //焦点后字符串
        NSString* suffixStr = [srcStr substringFromIndex:idx-prefixSpaceCount];
        
        //组合新的字符串
        NSString* inputStr = [NSString stringWithFormat:@"%@%ld%@",prefixStr,(long)value,suffixStr];
        
        NSString *inputStrRs;
        //格式化字符串#123 1234 1234
        if ([inputStr length] > 7) {
            inputStrRs = [NSString stringWithFormat:@"%@ %@ %@",
                          [inputStr substringToIndex:3],
                          [inputStr substringWithRange:NSMakeRange(3, 4)],
                          [inputStr substringFromIndex:7]];
        }else if([inputStr length] > 3){
            inputStrRs = [NSString stringWithFormat:@"%@ %@",
                          [inputStr substringToIndex:3],
                          [inputStr substringFromIndex:3]];
        }else{
            inputStrRs = inputStr;
        }
        [self setText:inputStrRs];
        
        //重新定位焦点
        //int spaceCount = (idx+1)%5 == 0 ? 1 : 0;//**加入修改
        int spaceCount = (idx == 3||idx == 8)? 1:0;
        UITextPosition* endPos = [self positionFromPosition:self.beginningOfDocument
                                                inDirection:UITextLayoutDirectionRight
                                                     offset:1 + idx + spaceCount];
        UITextRange* resetSelRange = [self textRangeFromPosition:endPos
                                                      toPosition:endPos];
        [self setSelectedTextRange:resetSelRange];
        
        if([self.kqTextfieldDelegate respondsToSelector:@selector(addNumber: number:)])
            [self.kqTextfieldDelegate addNumber:self number: [NSString stringWithFormat:@"%ld",(long)value]];
    }
}

-(void)deleteButton:(KQKeyboardView*)keyboard{
    UITextRange *selRange = self.selectedTextRange;
    UITextPosition *selStartPos = selRange.start;
    
    if (selRange.isEmpty) {
        //焦点位置index
        NSInteger idx = [self offsetFromPosition:self.beginningOfDocument
                                      toPosition:selStartPos];
        if (idx) {
            //焦点前空格数
            //焦点前空格数 #123 1234 1234
            long prefixSpaceCount = 0;
            if (idx >= 9) {
                prefixSpaceCount = 2;
            }else if(idx  >= 4){
                prefixSpaceCount = 1;
            }
            
            //把空格去掉
            NSString *srcStr = [self.text stringByReplacingOccurrencesOfString:@" "
                                                                    withString:@""];
            
            //焦点前字符串
            NSString* prefixStr = [srcStr substringToIndex:idx-prefixSpaceCount-1];
            //焦点后字符串
            NSString* suffixStr = [srcStr substringFromIndex:idx-prefixSpaceCount];
            
            //组合新的字符串
            NSString* inputStr = [NSString stringWithFormat:@"%@%@",prefixStr,suffixStr];
            
            
            NSString *inputStrRs;
            //格式化字符串#123 1234 1234
            if ([inputStr length] > 7) {
                inputStrRs = [NSString stringWithFormat:@"%@ %@ %@",
                              [inputStr substringToIndex:3],
                              [inputStr substringWithRange:NSMakeRange(3, 4)],
                              [inputStr substringFromIndex:7]];
            }else if([inputStr length] > 3){
                inputStrRs = [NSString stringWithFormat:@"%@ %@",
                              [inputStr substringToIndex:3],
                              [inputStr substringFromIndex:3]];
            }else{
                inputStrRs = inputStr;
            }
            [self setText:inputStrRs];
            
            //重新定位焦点
            int spaceCount = (idx == 5||idx == 10)? 1:0;
            UITextPosition* endPos = [self positionFromPosition:self.beginningOfDocument
                                                    inDirection:UITextLayoutDirectionRight
                                                         offset:idx-1-spaceCount];
            UITextRange* resetSelRange = [self textRangeFromPosition:endPos
                                                          toPosition:endPos];
            [self setSelectedTextRange:resetSelRange];
        }
        
        if([self.kqTextfieldDelegate respondsToSelector:@selector(deleteNumber:)])
            [self.kqTextfieldDelegate deleteNumber:self];
    }
}
@end
