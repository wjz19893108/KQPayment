//
//  KQCFileEngine.h
//  KQCore
//
//  Created by pengkang on 2016/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQBFileEngine : NSObject

/**
 初始化文件系统
 */
+ (void)initializeManager;

/**
 删除指定文件

 @param filePath 完整文件路径
 @return 成功 or 失败
 */
+ (BOOL)removeFile:(NSString *)filePath;

/**
 删除指定文件夹

 @param directoryPath 完整文件夹路径
 @return 成功 or 失败
 */
+ (BOOL)removeDirectory:(NSString *)directoryPath;

/**
 删除指定路径的所有子文件

 @param directoryPath 文件路径
 @return 成功 or 失败
 */
+ (BOOL)removeSubDirectory:(NSString *)directoryPath;

/**
 计算指定路径文件大小，path可以为文件或者文件夹

 @param path 完整文件路径
 @return 文件大小总和
 */
+ (long long)sizeAtPath:(NSString *)path;

/**
 将对象保存到指定的文件路径

 @param object 待保存对象
 @param filePath 完整的文件路径
 @return 成功 or 失败
 */
+ (BOOL)writeObject:(id)object filePath:(NSString *)filePath;

/**
 读取指定文件路径的对象

 @param filePath 完整的文件路径
 @return 读取对象
 */
+ (id)readObject:(NSString *)filePath;

/**
 创建指定的文件夹，如果存在则不创建，直接返回YES

 @param directoryPath  完整的文件夹目录
 @return 成功 or 失败
 */
+ (BOOL)createDirectory:(NSString *)directoryPath;

/**
 保存数据到指定的文件

 @param data 待保存数据
 @param filePath 完整的文件路径
 */
+ (void)saveData:(NSData *)data filePath:(NSString *)filePath;

/**
 查看文件是否存在

 @param filePath 完整的文件路径
 @return 存在与否
 */
+ (BOOL)fileExist:(NSString *)filePath;

/**
 
 *  @param zipFilePath
 *  @param targetPath
 */


/**
 解压zip包

 @param zipFilePath ZIP文件路径
 @param targetPath 解压目标路径
 @return 解压成功与否
 */
+ (BOOL)unZipFile:(NSString *)zipFilePath to:(NSString *)targetPath;

/**
 解析json文件

 @param jsonFilePath json文件路径
 @return 解析成功与否
 */
+ (NSDictionary *)parseConfigFile:(NSString *)jsonFilePath;

/**
 获取zip文件的MD5值

 @param path zip文件路径
 @return MD5值
 */
+ (NSString *)getFileMD5WithPath:(NSString *)path;

/**
  比较文件MD5值

 @param filePath 目标文件地址
 @param md5Str MD5
 @return 是否一致
 */
+ (BOOL)compareMD5WithFile:(NSString *)filePath MD5:(NSString *)md5Str;
@end
