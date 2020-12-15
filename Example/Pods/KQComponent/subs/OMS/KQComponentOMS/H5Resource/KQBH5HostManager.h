//
//  KQH5HostManager.h
//  kuaiQianbao
//
//  Created by xy on 16/6/3.
//
//

#import <Foundation/Foundation.h>

#define KuaiqianScheme      @"bill99app"
#define KuaiqianSchemeHost  @"kuaiqianbao"

#define H5HostManager       [KQBH5HostManager sharedManager]

@interface KQBH5HostInfo : NSObject

@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSArray *jsMethodArray; // 如果为nil或者空，认为所有的js都能访问

+ (instancetype)hostInfo:(NSString *)host jsMethodArray:(NSArray *)methodArray;

@end

@interface KQBH5HostManager : NSObject

+ (KQBH5HostManager *)sharedManager;

@property (nonatomic, assign) BOOL isAllowAllUrl; // 是否允许所有的url访问

/**
 *  待访问链接
 *
 *  @param url 待访问的url
 *
 *  @return YES：允许
 */
- (BOOL)isAllowUrl:(NSURL *)url;

/**
 *  设置数据
 *
 *  @param dataDic 原始数据
 */
- (void)updateData:(NSDictionary *)dataDic;

@end
