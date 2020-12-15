//
//  KQCStaFileManager.m
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import "KQCStaFileManager.h"
#import "KQStatisticsFileHelp.h"

@interface KQCStaFileManager()

@property (nonatomic, strong) KQStatisticsFileHelp *fileOPManager;
@property (nonatomic, strong) NSString *directoryPath;
@property (nonatomic, strong) NSString *defaultPath;

@end

@implementation KQCStaFileManager

SYNTHESIZE_SINGLETON_FOR_CLASS(KQCStaFileManager);

- (void)setFilePath:(NSString *)path{
    if ([NSString kqc_isBlank:path]) {
        return;
    }
    self.defaultPath = path;
    
    [self resetFilePath];
}

- (void)resetFilePath{
    self.directoryPath = [self.defaultPath stringByAppendingPathComponent:[self defaultFileName]];
    self.fileOPManager = [[KQStatisticsFileHelp alloc] initWithFilePath:self.directoryPath];
}

- (NSString *)defaultFileName{
    return KQC_FORMAT(@"sta_%@.log", [KQCDate dateFormat:[NSDate date] destFormat:KQDateFormatAccurateMicroSecond]);
}

- (void)staLivingFileAppend:(NSData *)content{
    dispatch_async([KQCStaFileManager staLivingFileQueue], ^{
        if (self.fileOPManager && content && [content length] > 0) {
            [self.fileOPManager appendData:content];
        }
    });
}

/**
 *  持续文件写入的串行队列
 *
 *  @return 队列
 */
+ (dispatch_queue_t)staLivingFileQueue {
    static dispatch_queue_t sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create("KQCStaManagerLivingFileQueue", NULL);
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        dispatch_set_target_queue(sharedQueue, globalQueue);
    });
    return sharedQueue;
}

- (NSData *)staData {
    if ([NSString kqc_isBlank:self.directoryPath]) {
        return nil;
    }
    
    NSMutableData *uploadData = [NSMutableData data];
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.directoryPath stringByDeletingLastPathComponent] error:&error]) {
        
        //当前使用中的文件跳过
        if ([file isEqualToString:[self.directoryPath lastPathComponent]]) {
            continue;
        }
        
        if ([[file pathExtension] isEqualToString:@"log"]) {
            NSData *fileContent = [NSData dataWithContentsOfFile:[[self.directoryPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:file]];
            if (fileContent) {
                [uploadData appendData:fileContent];
            }
        }
        
    }
    
    return uploadData;
}

- (void)deleteAllStaData{
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.directoryPath stringByDeletingLastPathComponent] error:&error]) {
        
        //当前使用中的文件跳过
        if ([file isEqualToString:[self.directoryPath lastPathComponent]]) {
            continue;
        }
        
        if ([[file pathExtension] isEqualToString:@"log"]) {
            [[NSFileManager defaultManager] removeItemAtPath:[[self.directoryPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:file] error:&error];
        }
    };
}

- (void)saveCrashData:(NSString *)data{
    NSString *filePath = [self.defaultPath stringByAppendingPathComponent:@"crash_log.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]) {
        [data writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return;
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    NSData* stringData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:stringData];
    [fileHandle closeFile];
}

@end
