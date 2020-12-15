//
//  KQSecureCertManager.h
//  kuaiQianbao
//
//  Created by xy on 16/6/20.
//
//

#import <Foundation/Foundation.h>

#define SecureCertManager           [KQBSecureCertManager sharedKQBSecureCertManager]

typedef NS_ENUM(NSInteger, KQSecureCertStatus) {
    KQSecureCertStatusUnknow = 0,  // 未知状态
    KQSecureCertStatusInstalled,   // 已安装
    KQSecureCertStatusUninstalled  // 未安装
};

@interface KQBSecureCertManager : NSObject
@property (nonatomic, strong) NSArray *secureCertApiArray;
@property (nonatomic, assign) BOOL isCertAvailable;

+ (KQBSecureCertManager *)sharedKQBSecureCertManager;

/**
 *  获取证书状态，使用网络连接
 *
 *  @param statusBlock 结果回调
 */
- (void)checkCertStatus:(void (^)(KQSecureCertStatus certStatus))statusBlock;

/**
 *  申请安装证书
 *
 *  @param resultBlock       结果回调
 */
- (void)installCert:(void (^)(BOOL success, NSString *errorMessage))resultBlock;

/**
 *  吊销证书
 */
- (void)revokeCert:(void (^)(BOOL success))resultBlock;

/**
 *  签名
 *
 *  @param srcStr 待签名字符串
 *
 *  @return 签名值，签名失败返回nil
 */
- (NSString *)sign:(NSString *)srcStr;

/**
 *  是否需要用数字证书加签
 *
 *  @param bizType 网络类型
 *
 *  @return YES：需要 NO：不需要
 */
- (BOOL)isNeedCertSign:(NSString *)bizType;

/**
 *  重置数据
 */
- (void)resetData;

/**
 *  初始化数据
 */
- (void)initData;
@end
