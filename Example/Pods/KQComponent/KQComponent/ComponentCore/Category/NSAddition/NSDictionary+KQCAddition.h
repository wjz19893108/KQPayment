//
//  NSDictionary+KQAddition.h
//  小薇通页面
//
//  Created by tianqy on 14-9-2.
//  Copyright (c) 2014年 tianqy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KQCAddition)

/**
 深拷贝

 @return 深拷贝的字典
 */
- (NSDictionary *)kqc_mutableDeepCopy;

/**
 对应字典中的value做url encode后以key=value的形式返回一个字符串

 @return 目标字符串
 */
- (NSString *)kqc_urlEncodedKeyValueString;

/**
 json格式字符串转字典

 @param json json格式字符串
 @return 目标字典
 */
+ (NSDictionary *)kqc_dictionaryWithJson:(NSString *)json;
@end
