//
//  KQBFileEngine.m
//  KQCore
//
//  Created by pengkang on 2016/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBFileEngine.h"
#include <CommonCrypto/CommonDigest.h>

#import <ZipArchive/ZipArchive.h>

#define FileMgr [NSFileManager defaultManager]

static dispatch_semaphore_t _lock = nil;

#define Lock() dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(_lock)
#define FileHashDefaultChunkSizeForReadingData 1024*8

@implementation KQBFileEngine

+ (void)initializeManager{
    if (!_lock) {
        _lock = dispatch_semaphore_create(1);
    }
}

+ (BOOL)createDirectory:(NSString *)directoryPath{
    BOOL isDirectory;
    if ([FileMgr fileExistsAtPath:directoryPath isDirectory:&isDirectory] && isDirectory) {
        return YES;
    }
    
    NSError *error = nil;
    [FileMgr createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        DLog(@"create directoryPath %@ failed:%@", directoryPath, error);
        return NO;
    }
    return YES;
}

+ (BOOL)removeFile:(NSString *)filePath{
    if (![FileMgr fileExistsAtPath:filePath]) {
        return YES;
    }
    
    NSError *error = nil;
    [FileMgr removeItemAtPath:filePath error:&error];
    if (error) {
        DLog(@"remove file error:%@     path:%@", error, filePath);
    }
    
    return error ? NO : YES;
}

+ (BOOL)removeDirectory:(NSString *)directoryPath{
    BOOL isDirectory;
    if (![FileMgr fileExistsAtPath:directoryPath isDirectory:&isDirectory]) {
        DLog(@"no directory exist:%@", directoryPath);
        return NO;
    }
    
    return [KQBFileEngine removeFile:directoryPath];
}

+ (BOOL)removeSubDirectory:(NSString *)directoryPath{
    BOOL isDirectory;
    if (![FileMgr fileExistsAtPath:directoryPath isDirectory:&isDirectory]) {
        DLog(@"no directory exist:%@", directoryPath);
        return NO;
    }
    
    NSArray *subFileArray = [FileMgr subpathsAtPath:directoryPath];
    [subFileArray enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *subPath = [directoryPath stringByAppendingPathComponent:fileName];
        
        if (![FileMgr fileExistsAtPath:subPath]) {
            return;
        }
        
        [KQBFileEngine removeFile:subPath];
    }];
    return YES;
}

+ (long long)sizeAtPath:(NSString *)path{
    BOOL isDir;
    NSFileManager *fileMgr = FileMgr;
    if (![fileMgr fileExistsAtPath:path isDirectory:&isDir]) {
        return 0;
    }
    
    if (!isDir) { // 单个文件
        return [[fileMgr attributesOfItemAtPath:path error:nil] fileSize];
    }
    
    __block long long totalSize = 0;
    NSArray *subFileArray = [fileMgr subpathsAtPath:path];
    [subFileArray enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *subPath = [path stringByAppendingPathComponent:fileName];
        BOOL isSubDir;
        if (![fileMgr fileExistsAtPath:subPath isDirectory:&isSubDir]) {
            return;
        }
        
        if (isSubDir) {
            return;
        }
        
        totalSize += [[fileMgr attributesOfItemAtPath:subPath error:nil] fileSize];
    }];
    
    return totalSize;
}

+ (BOOL)writeObject:(id)object filePath:(NSString *)filePath{
    if ([NSString kqc_isBlank:filePath]) {
        DLog(@"No file at path :%@", filePath);
        return NO;
    }
    
    if (![KQBFileEngine createFileDir:filePath]) {
        return NO;
    }
    
    Lock();
    BOOL isSuccess = [NSKeyedArchiver archiveRootObject:object toFile:filePath];
    Unlock();
    return isSuccess;
}

+ (id)readObject:(NSString *)filePath{
    
    if ([NSString kqc_isBlank:filePath]) {
        DLog(@"No file at path :%@", filePath);
        return nil;
    }
    
    Lock();
    id object;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    } @catch ( NSException *ex ) {
        object = nil;
    }
    Unlock();
    return object;
}

+ (BOOL)fileExist:(NSString *)filePath{
    BOOL isDirectory;
    if (![FileMgr fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        return NO;
    }
    
    return !isDirectory;
}

+ (BOOL)createFileDir:(NSString *)filePath{
    if ([NSString kqc_isBlank:filePath]) {
        return NO;
    }
    
    if ([KQBFileEngine fileExist:filePath]) {
        return YES;
    }
    
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    return [KQBFileEngine createDirectory:dirPath];
}

+ (void)saveData:(NSData *)data filePath:(NSString *)filePath{
    if ([FileMgr fileExistsAtPath:filePath]) {
        [FileMgr removeItemAtPath:filePath error:nil];
    }
    
    [data writeToFile:filePath atomically:YES];
}

+ (BOOL)unZipFile:(NSString *)zipFilePath to:(NSString *)targetPath{
    
    ZipArchive *kqZipArchive = [[ZipArchive alloc] init];
    [kqZipArchive UnzipOpenFile:zipFilePath];
    
    BOOL result = [kqZipArchive UnzipFileTo:targetPath overWrite:YES];
    [kqZipArchive UnzipCloseFile];
    
    return result;
}

+ (NSDictionary *)parseConfigFile:(NSString *)jsonFilePath{
    if (!jsonFilePath) {
        return nil;
    }
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:NSDataReadingMappedIfSafe error:nil];
    if (!jsonData) {
        return nil;
    }
    
    NSDictionary *configDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return configDic;
}

+ (BOOL)compareMD5WithFile:(NSString *)filePath MD5:(NSString *)md5Str{
    NSString *fileMd5Str = [KQBFileEngine getFileMD5WithPath:filePath];
    return [md5Str isEqualToString:fileMd5Str];
}

+ (NSString *)getFileMD5WithPath:(NSString *)path{
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) {
        return nil;
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength:256];
        CC_MD5_Update(&md5, [fileData bytes], (unsigned int)[fileData length]);
        if( [fileData length] == 0 ){
            done = YES;
        }
    }
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(outputBuffer, &md5);
    
    __autoreleasing NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}




CFStringRef MD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    CFStringRef result = NULL;
    
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    
    CFURLRef fileURL =
    
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  
                                  (CFStringRef)filePath,
                                  
                                  kCFURLPOSIXPathStyle,
                                  
                                  (Boolean)false);
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            
                                            (CFURLRef)fileURL);
    
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    
    CC_MD5_CTX hashObject;
    
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    
    if (!chunkSizeForReadingData) {
        
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
        
    }
    
    // Feed the data to the hash object
    
    bool hasMoreData = true;
    
    while (hasMoreData) {
        
        uint8_t buffer[chunkSizeForReadingData];
        
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;
        
        if (readBytesCount == 0) {
            
            hasMoreData = false;
            
            continue;
            
        }
        
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
        
    }
    
    // Check if the read operation succeeded
    
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    
    if (!didSucceed) goto done;
    
    // Compute the string result
    
    char hash[2 * sizeof(digest) + 1];
    
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        
    }
    
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
    
    
done:
    
    if (readStream) {
        
        CFReadStreamClose(readStream);
        
        CFRelease(readStream);
        
    }
    
    if (fileURL) {
        
        CFRelease(fileURL);
        
    }
    
    return result;
    
}

@end
