//
//  KQKeychain.h
//  kuaishua
//
//  Created by LiuBin on 14-7-28.
//
//

#import <Foundation/Foundation.h>

@interface KQCKeychain : NSObject

/**
 指定缓存keychain的key，为了兼容架构2.0之前的版本
 
 @param key 指定的key
 */
+ (void)initializeConfig:(NSString *)key;

/**
 加载指定key的值

 @param key 指定的key
 @return 对应的值
 */
+ (id)loadValue:(NSString *)key;

/**
 更新指定key的值，如果value为空，则删除该key

 @param data 对应的value
 @param key 对应的key
 */
+ (void)saveValue:(id)data key:(NSString *)key;

/**
 删除指定key对应的值

 @param key 指定的key
 */
+ (void)deleteValue:(NSString *)key;

@end
