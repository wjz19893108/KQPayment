//
//  KQURLConnection.h
//  kuaiQianbao
//
//  Created by wangping on 16/7/26.
//
//  backup:  规避iOS 7系统，NSURLSession 会去除Content-length。chunked，造成图片上传，服务器无法解析的Bug
//           该类只在iOS 8以下系统调用
//           https://github.com/AFNetworking/AFNetworking/issues/1398
//

#import <Foundation/Foundation.h>

@interface KQCURLConnection : NSObject
{
}

+ (void)cancel;

/**
 *   构建Connection
 *
 *  @param request           请求对象
 *  @param completionHandler 成功返回事件
 *
 *  @return 当前类实例
 */
- (instancetype)initWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

/**
 *  开始发起请求
 */
- (void)start;

/**
 *  关闭请求
 */
- (void)stop;

@end
