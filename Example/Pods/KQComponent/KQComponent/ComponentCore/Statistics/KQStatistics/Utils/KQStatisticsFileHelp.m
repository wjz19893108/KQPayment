//
//  KQStatisticsFileHelp.m
//  KQComponent
//
//  Created by wangping on 2018/6/11.
//

#import "KQStatisticsFileHelp.h"

@interface KQStatisticsFileHelp ()

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation KQStatisticsFileHelp

/**
 *  初始化&创建NSFileHandle
 *
 *  @param filePath 文件路径
 *
 *  @return 类实例
 */
- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        [self open:filePath];
    }
    return self;
}

/**
 *  追加数据至文件末尾
 *
 *  @param content 数据
 */
- (void)appendData:(NSData *)content {
    if (_fileHandle && content && [content length] > 0) {
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
            [self close];
            [self open:_filePath];
        }
        
        [_fileHandle seekToEndOfFile];
        [_fileHandle writeData:content];
    }
}

/**
 *  当前打开文件大小体积
 *
 *  @return 体积
 */
- (unsigned long long)size {
    unsigned long long ofset = 0;
    if (_fileHandle) {
        unsigned long long pos = [_fileHandle offsetInFile];
        [_fileHandle seekToEndOfFile];
        ofset = [_fileHandle offsetInFile];
        [_fileHandle seekToFileOffset:pos];
    }
    return ofset;
}

/**
 *  打开文件
 *
 *  @param filePath 文件路径
 */
- (void)open:(NSString *)filePath {
    if (![NSString kqc_isBlank:filePath]) {
        [self close];
        _filePath   = filePath;
        
        [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    }
}

/**
 *  关闭文件读写功能
 */
- (void)close {
    if (_fileHandle) {
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
}

+ (BOOL)removeFile:(NSString *)filePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error) {
        DLog(@"remove file error:%@     path:%@", error, filePath);
    }
    
    return error ? NO : YES;
}

+ (long long)sizeAtPath:(NSString *)path {
    BOOL isDir;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
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

@end
