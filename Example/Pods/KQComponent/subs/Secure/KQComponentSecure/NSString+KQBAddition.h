//
//  NSString+KQAdditions.h
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KQBAddition)

- (NSString *)kqb_encryptBeforeLogin;

- (NSString *)kqb_encrypt;
- (NSString *)kqb_decrypt;

@end
