//
//  KQBUserInfo.h
//  KQBusiness
//
//  Created by xy on 2016/10/24.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQFaceAuthorizationStatus) {
    KQFaceAuthorizationStatusUnknow = 0, // 状态未知
    KQFaceAuthorizationStatusAuthorized,    // 通过人脸识别
    KQFaceAuthorizationStatusDenied,     // 未通过人脸识别
};

typedef NS_ENUM(NSInteger, KQWhiteListStatus) {
    KQWhiteListStatusUnknown = 0,   // 状态未知
    KQWhiteListStatusTrue,          // 是白名单
    KQWhiteListStatusFalse          // 非白名单
};

FOUNDATION_EXTERN NSNotificationName const KQBUserSignOutNotification;                      // 用户登出通知
FOUNDATION_EXTERN NSNotificationName const KQBUserNeedLoginInNotification;                  // 用户需要登录通知

@interface KQBUserInfo : NSObject

@property (nonatomic, assign) KQFaceAuthorizationStatus faceAuthorizationStatus; // 人脸识别状态
@property (nonatomic, assign) KQWhiteListStatus creditWhiteListStatus;  // 征信白名单状态
@property (nonatomic, assign) KQWhiteListStatus financeWhiteListStatus; // 理财白名单状态

@property (nonatomic, strong) NSString *userMebCode;                // 用户会员号
@property (nonatomic, strong) NSString *secretUserMebCode;          // 用户会员号密文
@property (nonatomic, strong) NSString *userId;                     // 用户客户端唯一标示
@property (nonatomic, strong) NSString *loginToken;                 // 用户登陆的token
@property (nonatomic, strong) NSString *refreshToken;               // 开发给第三方服务的用户唯一标示

@property (nonatomic, strong) NSString *userName;                   // 用户账号
@property (nonatomic, strong) NSString *name;                       // 用户姓名
@property (nonatomic, strong) NSString *password;                   // 用户登录密码
@property (nonatomic, strong) NSString *identitycardid;             // 用户身份证号
@property (nonatomic, strong) NSString *email;                      // 用户邮箱
@property (nonatomic, strong) NSString *securityQuestion;           // 安全问题

@property (nonatomic, assign) BOOL isBindPhone;                     // 是否绑定手机号
@property (nonatomic, strong) NSString *phoneNo;                    // 用户手机号
@property (nonatomic, strong) NSString *shortPhone;                 // 用户短手机号
@property (nonatomic, copy)   NSString *userAddress;                // 用户常住地址

@property (nonatomic ,strong) NSString *mergeConflictFlag;          // 飞凡通账户 合并冲突标志
@property (nonatomic, strong) NSString *payPwdResetFlag;            // 飞凡通账户 是否需要合并密码
@property (nonatomic, strong) NSString *payPwdValidateFlag;         // 飞凡通 是否验证支付密码
@property (nonatomic, strong) NSString *idCardValidateFlag;         // 飞凡通 是否验证身份证
@property (nonatomic, strong) NSArray *conflictAcc;                 // 飞凡通 冲突数组

@property (nonatomic, assign) BOOL isLogin;                         // 用户是否登录
@property (nonatomic, assign) BOOL isFirstLogin;                    // 是否首次登陆
@property (nonatomic, assign) BOOL isRealName;                      // 是否实名
@property (nonatomic, assign) BOOL isBindPan;                       // 是否绑卡
@property (nonatomic, assign) BOOL isHasBalance;                    // 是否有余额
@property (nonatomic, assign) BOOL isHasSafeQuestion;               // 是否有安全卡
@property (nonatomic, assign) BOOL isFastRegister;                  // 是否快捷注册
@property (nonatomic, assign) BOOL isExistPayPassword;              // 是否存在支付密码

@property (nonatomic, strong) NSString *touchIdPayStatus;           // 指纹支付状态，YES/NO/nil
@property (nonatomic, assign) BOOL isTouchIdPayTipped;              // 统一支付完成后是否提示过可以开启指纹支付，YES/NO


/**
 用户展示到界面上的格式

 @return 显示的值
 */
- (NSString *)displayAccount;

@end
