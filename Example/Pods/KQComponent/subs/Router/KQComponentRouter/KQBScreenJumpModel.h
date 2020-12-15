//
//  KQBScreenJumpModel.h
//  kuaiQianbao
//
//  Created by xy on 16/4/19.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQPScreenJumpModeType) {
    KQPScreenJumpModeTypeNone = 0,  // 不跳转，默认
    KQPScreenJumpModeTypeNative,    // 跳native
    KQPScreenJumpModeTypeH5,        // 跳转H5
};

@interface KQBScreenJumpModel : NSObject

@property (nonatomic, assign) KQPScreenJumpModeType jumpMode;
@property (nonatomic, strong) NSString *jumpTarget; // 跳转Url或者是跳转native界面的业务编码。可选，没有值则不跳转。
@property (nonatomic, strong) NSString *jumpPageType; // 跳转Native业务首页还是详情页。
@property (nonatomic, strong) NSDictionary *targetDic; // 跳转详情页参数。
@property (nonatomic, assign) BOOL isNeedLogin;        // 是否需要登录
@property (nonatomic, assign) BOOL isNeedRealName;        // 是否需要实名

/**
 *  初始化界面跳转数据模型
 *
 *  @param jumpModeStr 跳转模式的字符串格式
 *  @param jumpTarget  跳转的目标链接
 *
 *  @return 跳转数据对象
 */
+ (instancetype)jumpModelWithJumpMode:(NSString *)jumpModeStr jumpTarget:(NSString *)jumpTarget;

/**
 *  初始化界面跳转数据模型
 *
 *  @param jumpModeStr      跳转模式的字符串格式
 *  @param jumpTarget       跳转的目标链接
 *  @param isNeedLogin      是否需要登录
 *  @param isNeedRealName   是否需要实名
 *
 *  @return 跳转数据对象
 */
+ (instancetype)jumpModelWithJumpMode:(NSString *)jumpModeStr jumpTarget:(NSString *)jumpTarget isNeedLogin:(BOOL)isNeedLogin isNeedRealName:(BOOL)isNeedRealName;

/**
 *  初始化界面跳转数据模型
 *
 *  @param jumpModeStr 跳转模式的字符串格式
 *  @param jumpTarget  跳转的目标链接
 *  @param jumpPageType  跳转首页还是详情页
 *  @param targetDic  详情页参数
 *
 *  @return 跳转数据对象
 */
+ (instancetype)jumpModelWithJumpMode:(NSString *)jumpModeStr
                           jumpTarget:(NSString *)jumpTarget
                         jumpPageType:(NSString *)jumpPageType
                            targetDic:(NSDictionary *)targetDic;

/**
 *  初始化界面跳转数据模型
 *
 *  @param jumpModeStr      跳转模式的字符串格式
 *  @param jumpTarget       跳转的目标链接
 *  @param jumpPageType     跳转首页还是详情页
 *  @param targetDic        详情页参数
 *  @param isNeedLogin      是否需要登录
 *  @param isNeedRealName   是否需要实名
 *
 *  @return 跳转数据对象
 */
+ (instancetype)jumpModelWithJumpMode:(NSString *)jumpModeStr
                           jumpTarget:(NSString *)jumpTarget
                         jumpPageType:(NSString *)jumpPageType
                            targetDic:(NSDictionary *)targetDic
                          isNeedLogin:(BOOL)isNeedLogin
                       isNeedRealName:(BOOL)isNeedRealName;

@end
