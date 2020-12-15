//
//  NSData+KQCAdditions.h
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

void *kq_NewBase64Decode(
                         const char *inputBuffer,
                         size_t length,
                         size_t *outputLength);

char *kq_NewBase64Encode(
                         const void *inputBuffer,
                         size_t length,
                         bool separateLines,
                         size_t *outputLength);

@interface NSData (KQBase64)


/**
 base64解码

 @param aString 源字符串
 @return 目标数据流
 */
+ (NSData *)dataFromBase64String:(NSString *)aString;

/**
 base64编码

 @return 目标字符串
 */
- (NSString *)base64EncodedString;

@end
