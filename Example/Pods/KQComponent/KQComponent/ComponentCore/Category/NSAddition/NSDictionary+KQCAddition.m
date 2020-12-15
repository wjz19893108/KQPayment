//
//  NSDictionary+KQAddition.m
//  小薇通页面
//
//  Created by tianqy on 14-9-2.
//  Copyright (c) 2014年 tianqy. All rights reserved.
//

#import "NSDictionary+KQCAddition.h"

@implementation NSDictionary (KQCAddition)

- (NSDictionary *)kqc_mutableDeepCopy{
    NSMutableDictionary *copyDic = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id copyValue = nil;
        if ([obj respondsToSelector:@selector(kqc_mutableDeepCopy)]) {
            copyValue = [obj kqc_mutableDeepCopy];
        } else if ([obj respondsToSelector:@selector(mutableCopy)]) {
            copyValue = [obj mutableCopy];
        }
        
        if (!copyValue) {
            copyValue = [obj copy];
        }
        copyDic[key] = copyValue;
    }];
    return copyDic;
}

-(NSString *)kqc_urlEncodedKeyValueString{
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in self) {
        NSObject *value = [self valueForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [string appendFormat:@"%@=%@&", [key kqc_urlEncodedString], [((NSString*)value) kqc_urlEncodedString]];
        } else {
            [string appendFormat:@"%@=%@&", [key kqc_urlEncodedString], value];
        }
    }
    
    if([string length] > 0)
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    
    return string;
}

+ (NSDictionary *)kqc_dictionaryWithJson:(NSString *)json{
    if (!json) {
        return nil;
    }
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        DLog(@"json解析失败：%@, 源串：%@", err, json);
        return nil;
    }
    return dic;
}

@end
