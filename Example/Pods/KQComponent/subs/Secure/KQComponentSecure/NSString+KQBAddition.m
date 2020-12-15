//
//  NSString+KQAdditions.m
//  小薇通页面
//
//  Created by tianqy on 14-9-2.
//  Copyright (c) 2014年 tianqy. All rights reserved.
//

#import "NSString+KQBAddition.h"
#import "KQBSecureManager.h"

@implementation NSString (KQBAddition)

- (NSString *)kqb_encryptBeforeLogin{
    return [KQB_Manager_Secure encryptBeforeLogin:self];
}

- (NSString *)kqb_encrypt{
    return [KQB_Manager_Secure encryptByAES:self isCacheData:NO];
}

- (NSString *)kqb_decrypt{
    return [KQB_Manager_Secure decryptByAES:self isCacheData:NO];
}


@end
