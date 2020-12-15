//
//  KQHttpEngineNew.m
//  kuaiQianbao
//
//  Created by xy on 15/5/5.
//
//

#import "KQCHttpEngine.h"
#import "AFNetworking.h"
#import "AFSecurityPolicy.h"
#import "KQCURLConnection.h"

static NSString * const NeedCheckCerString = @"oms-99bill.cn-bj.ufileos.com"; // ATS标准OMS下载数据需校检证书

@interface KQCHttpEngine ()

@property (nonatomic, assign) BOOL ignoreCert;

@end

@implementation KQCHttpEngine

//static AFHTTPSessionManager *manager;
static AFHTTPSessionManager *DownloadManager;
static NSMutableDictionary *SessionManagerDic = nil;

#define KQRequestTimeOut 15.0f
#define kQRequestupLoadTimeOut 30.0f

+ (void)initialize{
    SessionManagerDic = [[NSMutableDictionary alloc] initWithCapacity:5];
}

- (NSURLSessionTask *)sendHttpRequest:(KQCHttpRequestModel *)requestModel{
    self.ignoreCert = requestModel.isIgnoreCert;
    NSURL *requestUrl = [NSURL URLWithString:requestModel.url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = requestModel.header;
    request.HTTPBody = requestModel.body;
    
    AFHTTPSessionManager *manager = [self getSessionManager:requestModel.url];
    
    [self safeStrategy:manager];
    [request setTimeoutInterval:requestModel.timeout > 0 ? : KQRequestTimeOut];
    NSURLSessionDataTask *task = [manager uploadTaskWithRequest:request fromData:requestModel.body progress:^(NSProgress * _Nonnull uploadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (error) {
            if (requestModel.failedBlock) {
                requestModel.failedBlock(error, httpResponse.statusCode);
            }
        } else {
            if (requestModel.successBlock) {
                requestModel.successBlock(responseObject, httpResponse.allHeaderFields);
            }
        }
    }];
    
    [task resume];
    return task;
}

//- (void)requestData:(NSData *)param url:(NSString *)url header:(NSDictionary *)header successBlock:(void (^)(NSData *responseData, NSDictionary *responseHeader))successBlock failedBlock:(void (^)(NSError *error,NSInteger httpStatusCode))failedBlock timeout:(NSInteger)timeout{
//
//}

+ (void)cancelRequest:(NSString *)url isUpload:(BOOL)isUpload{
    AFHTTPSessionManager *manager = SessionManagerDic[url];
    if (!manager) {
        return;
    }
    [manager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    
    if (isUpload) {
        [KQCURLConnection cancel];
    }
}

- (NSString *)responseStringWithEncoding:(NSData *)responseObject{
    return [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
}

- (void)uploadFileData:(NSData *)imageData
                   url:(NSString *)urlStr
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
             failBlock:(void (^)(NSData *responseData, NSError *error))failBlock
        uploadProgress:(void (^)(double progress))progressBlock
            ignoreCert:(BOOL)ignoreCert {
    
    self.ignoreCert = ignoreCert;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:urlStr
                                                                                             parameters:nil
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  [formData appendPartWithFileData:imageData
                                                                                                              name:@"file"
                                                                                                          fileName:fileName
                                                                                                          mimeType:@"application/octet-stream"];
                                                                              } error:nil];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [request setTimeoutInterval:kQRequestupLoadTimeOut]; // 考虑2G网情况，增加上传文件超时时间
    [self safeStrategy:manager];
    
    //#ifndef VERSION_PRO
    //    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request
    //                                                                       progress:nil
    //                                                              completionHandler:^(NSURLResponse *response, id responseObject, NSError* error) {
    //                                                                  if (error) {
    //                                                                      if (failBlock) {
    //                                                                          failBlock(responseObject, error);
    //                                                                      }
    //                                                                  } else {
    //                                                                      if (successBlock) {
    //                                                                          successBlock([self responseStringWithEncoding:responseObject], responseObject);
    //                                                                      }
    //                                                                  }
    //                                                              }];
    //    [uploadTask resume];
    //
    //#else
    //fix bugs iOS 7系统使用NSURLSessionUploadTask，系统会自动去除content-length，使用chunked方式传输
    //         造成服务器无法解析，异常stream ended unexpectedly
    if (KQC_SYSTEM_VRESION_8 || self.ignoreCert) {
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request
                                                                           progress:nil
                                                                  completionHandler:^(NSURLResponse *response, id responseObject, NSError* error) {
                                                                      if (error) {
                                                                          if (failBlock) {
                                                                              failBlock(responseObject, error);
                                                                          }
                                                                      } else {
                                                                          if (successBlock) {
                                                                              successBlock([self responseStringWithEncoding:responseObject], responseObject);
                                                                          }
                                                                      }
                                                                  }];
        [uploadTask resume];
    } else {
        KQCURLConnection *uploadConnection = [[KQCURLConnection alloc] initWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                if (failBlock) {
                    failBlock(responseObject, error);
                }
            } else {
                if (successBlock) {
                    successBlock([self responseStringWithEncoding:responseObject], responseObject);
                }
            }
        }];
        [uploadConnection start];
        
    }
    //#endif
    
}



static SecCertificateRef AFUTHTTPBinOrgCertificate(NSString *resName) {
    NSString *certPath = [[NSBundle bundleForClass:[KQCHttpEngine class]] pathForResource:resName ofType:@"cer"];
    NSCAssert(certPath != nil, @"Path for certificate should not be nil");
    NSData *certData = [NSData dataWithContentsOfFile:certPath];
    
    return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certData));
}

- (AFHTTPSessionManager *)getSessionManager:(NSString *)url{
    AFHTTPSessionManager *manager = SessionManagerDic[url];
    if (manager) {
        return manager;
    }
    
    manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    SessionManagerDic[url] = manager;
    
    return manager;
}

- (void)downloadFileFrom:(NSString *)url
                bodyData:(NSData *)bodyData
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
          uploadProgress:(void (^)(double progress))progressBlock
              ignoreCert:(BOOL)ignoreCert {
    
    if (![url containsString:@"http://"]&&![url containsString:@"https://"]) {
        return;
    }
    self.ignoreCert = ignoreCert;
    
    NSRange tempRang = [url rangeOfString:NeedCheckCerString];
    BOOL isHTTPSRequest = ![url containsString:@"https://"];
    BOOL iSOMSDownLoad = (tempRang.location != NSNotFound);
    NSURL *downloadUrl = [NSURL URLWithString:url];
    
    if (iSOMSDownLoad || isHTTPSRequest) {
        self.ignoreCert = YES;
        if (!DownloadManager) {
            DownloadManager = [self getSessionManager:downloadUrl.host];
            DownloadManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [DownloadManager.requestSerializer setTimeoutInterval:KQRequestTimeOut];
            [self calibrationCertificate];
        }
    } else {
        AFHTTPSessionManager *manager = [self getSessionManager:KQC_NON_NIL(url)];
        //        if (!manager) {
        //            manager = [AFHTTPSessionManager manager];
        //        }
        [manager.requestSerializer setTimeoutInterval:KQRequestTimeOut];
        [self safeStrategy:manager];
    }
    
    if (!filePath) {//get 下载
        AFHTTPSessionManager *manager = iSOMSDownLoad ? DownloadManager : [self getSessionManager:url];
        [manager GET:url parameters:nil headers:@{@"Content-Type":@"application/json"} progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progressBlock) {
                progressBlock(downloadProgress.fractionCompleted);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (successBlock) {
                successBlock([self responseStringWithEncoding:responseObject], responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failedBlock) {
                failedBlock(error);
            }
        }];
    }else{//下载到指定路径
        
        NSURLRequest *request = nil;
        if (bodyData) {
            NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
            mRequest.HTTPBody = bodyData;
            mRequest.HTTPMethod = @"POST";
            request = mRequest;
        } else {
            request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
        }
        
        AFHTTPSessionManager *manager = iSOMSDownLoad ? DownloadManager : [self getSessionManager:url];
        NSURLSessionDownloadTask *downloadTask
        = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progressBlock) {
                progressBlock(downloadProgress.fractionCompleted);
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:filePath];;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (error) {
                if (failedBlock) {
                    failedBlock(error);
                }
            }else{
                if (successBlock) {
                    NSString *responseCode = KQC_FORMAT(@"%ld", (long)[(NSHTTPURLResponse*)response statusCode]);
                    successBlock(responseCode, [responseCode dataUsingEncoding:NSUTF8StringEncoding]);
                }
                
            }
        }];
        [downloadTask resume];
    }
    
}

- (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
          uploadProgress:(void (^)(double progress))progressBlock
              ignoreCert:(BOOL)ignoreCert {
    [self downloadFileFrom:url bodyData:nil toFile:filePath successBlock:successBlock failBlock:failedBlock uploadProgress:progressBlock ignoreCert:ignoreCert];
}

- (void)safeStrategy:(AFURLSessionManager*)safeManager{
    if (self.ignoreCert) {
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES;
        policy.validatesDomainName = NO;
        safeManager.securityPolicy = policy;
    } else {
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
        policy.validatesDomainName = NO;
        SecCertificateRef digiCertGlobalRootEnc = AFUTHTTPBinOrgCertificate(@"digiCertGlobalRootEnc");
        SecCertificateRef digSerEnc = AFUTHTTPBinOrgCertificate(@"digSerEnc");
        SecCertificateRef oldPubilcSign = AFUTHTTPBinOrgCertificate(@"pubilcSign");
        SecCertificateRef digiCertGlobalRootNew = AFUTHTTPBinOrgCertificate(@"digiCertGlobalRootNew");
        SecCertificateRef serverMiddleNew = AFUTHTTPBinOrgCertificate(@"serverMiddleNew");
        policy.pinnedCertificates = [NSSet setWithObjects:
                                     (__bridge_transfer id)SecCertificateCopyData(digiCertGlobalRootEnc),
                                     (__bridge_transfer id)SecCertificateCopyData(digSerEnc),
                                     (__bridge_transfer id)SecCertificateCopyData(oldPubilcSign),
                                     (__bridge_transfer id)SecCertificateCopyData(digiCertGlobalRootNew),
                                     (__bridge_transfer id)SecCertificateCopyData(serverMiddleNew),
                                     nil];
        safeManager.securityPolicy = policy;
        CFRelease(digiCertGlobalRootEnc);
        CFRelease(digSerEnc);
        CFRelease(oldPubilcSign);
        CFRelease(digiCertGlobalRootNew);
        CFRelease(serverMiddleNew);
    }
}

#pragma mark - OMSATS标准校检
- (void)calibrationCertificate{
    DownloadManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    DownloadManager.securityPolicy.allowInvalidCertificates = NO;
    DownloadManager.securityPolicy.validatesDomainName = NO;
}

@end
