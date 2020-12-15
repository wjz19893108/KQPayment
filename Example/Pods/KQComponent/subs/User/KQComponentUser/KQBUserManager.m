//
//  KQBUserManager.m
//  KQBusiness
//
//  Created by xy on 2016/10/26.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBUserManager.h"
#import "UIAlertView+Blocks.h"

@interface KQBUserManager()

@property (nonatomic, strong) NSMutableArray *cacheHistoryUserArray;
@property (nonatomic, strong) NSString *userKeyInKeychain;

@end

@implementation KQBUserManager

static NSString *kUserArray = @"userArray";
static NSString *kUserName = @"userName";
static NSString *kUserId = @"userId";

static int MAX_USER_NUM = 2;

SYNTHESIZE_SINGLETON_FOR_CLASS(KQBUserManager);

- (instancetype)init{
    self = [super init];
    if (self) {
//        KQP_Manager_Protocol.userInfoDelegate = self;
    }
    return self;
}

+ (BOOL)loadUserData{
    // 获取UserDefault、keychain里面的userId，如果一样，认为该用户有效
    NSString *userIdInPlist = [KQBCacheManager readUserId];
    
    NSArray *userArray = [KQBUserManager historyUserArray];
    NSString *userIdInKeychain = nil;
    if (userArray.count > 0) {
        userIdInKeychain = userArray[0][kUserId];
    }
    
    if ([NSString kqc_isBlank:userIdInKeychain]
        || [NSString kqc_isBlank:userIdInPlist]
        || ![userIdInPlist isEqualToString:userIdInKeychain]){
        return NO;
    }
    
    [KQBUserManager resetUserConfig:userIdInKeychain];
    KQBUserInfo *userInfo = [KQBCacheManager loadValueForKey:KQPageCacheUserInfoKey];
    if (![userInfo.userId isEqualToString:userIdInKeychain]) { // 缓存中的值不一样，也认为数据无效
        [KQBUserManager resetGlobalUser];
        return NO;
    }
   
    KQB_CurrentUser = userInfo;
//    return  [KQBUserManager resetUserClientPrivateKey:userInfo.clientPrivateKey serverPublicKey:userInfo.serverPublicKey];
    return YES;
}

- (KQBUserInfo *)userInfo{
    if (!_userInfo) {
        _userInfo = [[KQBUserInfo alloc] init];
    }
    return _userInfo;
}

// 是否是个人账号
+ (BOOL)isPersonalAccount:(NSString *)memberType{
    if ([memberType isEqualToString:@"1"]){
        return YES;
    }
    
    [UIAlertView showWithTitle:nil message:@"目前已关闭商户登录功能，您可以用个人账号登录快钱刷。如有疑问请拨打客服电话400-635-5799。" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KQBUserSignOutNotification object:nil];
        }
    }];

    return NO;
}

- (void)clearUserInfoCache{
    [KQBCacheManager clearValueForKey:KQPageCacheUserInfoKey cacheType:KQCacheTypeUserData];
}

//+ (BOOL)resetUserClientPrivateKey:(NSString *)clientPrivateKey serverPublicKey:(NSString *)serverPublicKey{
//   return [KQB_Manager_Secure resetClientPrivateKey:clientPrivateKey] &&
//    [KQB_Manager_Secure resetServerPublicKey:serverPublicKey];
//}

+ (void)resetUserConfig:(NSString *)userId{
    [KQBCacheManager resetUserFolder:userId];
    [KQB_Manager_Secure resetAESKey:userId];
}

+ (void)resetGlobalUser{
    KQB_CurrentUser = [KQBUserManager guestUserInfo];
    [KQBUserManager resetUserConfig:KQB_CurrentUser.userId];
//    [KQBUserManager resetUserClientPrivateKey:nil serverPublicKey:nil];
}

+ (KQBUserInfo *)guestUserInfo{
    KQBUserInfo *userInfo = [[KQBUserInfo alloc] init];
    userInfo.userId = @"token_guest";
    return userInfo;
}

- (BOOL)updateUserInfoByLoginSuccess:(Content *)msgContent{
    // 商户登陆，直接返回
    if (![KQBUserManager isPersonalAccount:msgContent.member.memberType]) {
        return NO;
    }
    
    // 公钥空值直接返回
//    if ([NSString kqc_isBlank:msgContent.publicKey]) {
//        return NO;
//    }
    
    KQBUserInfo *user = self.userInfo;
    if ([NSString kqc_isBlank:user.userId]) {
        if (![NSString kqc_isBlank:msgContent.member.creationDate]) {
            user.userId = [KQCSecure stringFromMD5:msgContent.member.creationDate];
        } else {
            user.userId = [KQCSecure stringFromMD5:user.userName];
        }
    }
//    user.serverPublicKey = msgContent.publicKey;
    
    // 创建公私钥不成功，直接返回
//    if (![KQBUserManager resetUserClientPrivateKey:user.clientPrivateKey serverPublicKey:user.serverPublicKey]){
//        return NO;
//    }
    
    // 设置对称密钥不成功，直接返回
    if (![KQB_Manager_Secure resetAESKey:self.userInfo.userId]) {
        return NO;
    }
    
    user.isFastRegister = [msgContent.flag isEqualToString:@"true"];
    user.payPwdValidateFlag = msgContent.member.payPwdValidateFlag;
    user.idCardValidateFlag = msgContent.member.idCardValidateFlag;
    user.conflictAcc = msgContent.member.conflictAcc;
    user.mergeConflictFlag = msgContent.member.mergeConflictFlag;
    user.payPwdResetFlag = msgContent.member.payPwdResetFlag;
    
    user.isBindPhone = [msgContent.bindPhoneFlg isEqualToString:@"1"];
    user.isFirstLogin = [msgContent.firstLoginFlg isEqualToString:@"0"]; // 是否首次登录

    user.userMebCode = [msgContent.mebCode kqb_decrypt];
    user.secretUserMebCode = [user.userMebCode kqb_encryptBeforeLogin];
    user.securityQuestion = [msgContent.securityQuestion stringByReplacingOccurrencesOfString:@" " withString:@""];// 安全问题是否存在
    user.isExistPayPassword = [@"T" isEqualToString:msgContent.payPassword];
    user.isRealName = [@"1" isEqualToString:msgContent.realNameFlg];
    user.identitycardid = msgContent.member.identitycardid;
    user.refreshToken = [msgContent.refreshToken kqb_decrypt];
    
    NSString *nameStr = msgContent.member.name;
    if (![@"手机用户" isEqualToString:nameStr]
        && user.isRealName) {
        user.name = nameStr;
    } else {
        user.name = nil;
    }
    
    // 先清空用户手机号与邮箱，防止脏数据
    user.phoneNo = nil;
    user.email = nil;
    NSArray *array = msgContent.memberIdentity;
    for (ContentMemberIdentity *member in array) {
        NSString *idTypeString = member.idType;
        NSString *idContentString = member.idContent;
        
        if ([idTypeString isEqualToString:@"2"]
            && ![NSString kqc_isBlank:idContentString]) {
            user.phoneNo = idContentString;
        } else {
            user.email = idContentString;
        }
    }

    [self updateCacheFolder];
    [self updateKeychainUserInfo];
    [self updateDiskUserInfo];
    
    return YES;
}

- (BOOL)updateUserInfoByM011:(Content *)msgContent{
    if (![KQBUserManager isPersonalAccount:msgContent.member.memberType]) {
        return NO;
    }
    
    KQBUserInfo *user = self.userInfo;
    user.conflictAcc = msgContent.member.conflictAcc;
    user.securityQuestion = [msgContent.securityQuestion stringByReplacingOccurrencesOfString:@" " withString:@""]; // 安全问题是否存在
    user.isRealName = [@"true" isEqualToString:msgContent.realNameFlg];
    user.isExistPayPassword = [@"true" isEqualToString:msgContent.payPassword];
    user.identitycardid = msgContent.member.identitycardid;
    user.payPwdResetFlag = msgContent.member.payPwdResetFlag;
    user.mergeConflictFlag = msgContent.member.mergeConflictFlag;
    user.payPwdValidateFlag = msgContent.member.payPwdValidateFlag;
    user.idCardValidateFlag = msgContent.member.idCardValidateFlag;
    user.conflictAcc = msgContent.member.conflictAcc;
    
    NSString *nameString = msgContent.member.name;
    if (![@"手机用户" isEqualToString:nameString]
        && user.isRealName) {
        user.name = nameString;
    } else {
        user.name = nil;
    }
    
    user.userMebCode = [msgContent.member.userMebCode kqb_decrypt];
    user.secretUserMebCode = [user.userMebCode kqb_encryptBeforeLogin];
    
    user.isBindPhone = [msgContent.bindPhoneFlg isEqualToString:@"1"];
    
    //memberIdentity
    NSArray *array = msgContent.memberIdentity;
    for (ContentMemberIdentity *member in array) {
        NSString *idTypeString = member.idType;
        NSString *phoneNoStr = member.idContent;
        if (![NSString kqc_isBlank:phoneNoStr]
            && [idTypeString isEqualToString:@"2"]) {
            user.phoneNo = phoneNoStr;
        }
    }
    
    [self updateDiskUserInfo];
    return YES;
}

- (void)updateCacheFolder{
    [KQBCacheManager saveUserId:self.userInfo.userId];
    [KQBCacheManager resetUserFolder:self.userInfo.userId];
//    [[KQBOmsManager sharedKQBOmsManager] resetData];
}

- (void)updateDiskUserInfo{
    [KQBCacheManager saveValue:self.userInfo forKey:KQPageCacheUserInfoKey cacheType:KQCacheTypeUserData];
}

- (void)updateKeychainUserInfo{
    [KQBUserManager saveHistoryUser:@{kUserName:self.userInfo.userName, kUserId:self.userInfo.userId}];
}

#pragma mark - refresh by network
- (void)refreshUserInfo:(void(^)(BOOL isSuccess, Content *content))resultBlock{
    NSDictionary *requestDic = @{};
    
    [KQHttpService request:requestDic bizType:@"M011" successBlock:^(id response) {
        BOOL result = [self updateUserInfoByM011:response];
        if (resultBlock) {
            resultBlock(result, response);
        }
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        //TODO:xy
//        [KQBToastView show:errorMessage];
        if (resultBlock) {
            resultBlock(NO, response);
        }
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
}

- (void)refreshCreditWhiteListFinishBlock:(void(^)(void))finishBlock{
    //征信白名单
    if (self.userInfo.creditWhiteListStatus != KQWhiteListStatusUnknown) {
        finishBlock();
        return;
    }
    [KQHttpService request:@{} bizType:@"M228" successBlock:^(Content *response) {
        if ([response.status isEqualToString:@"true"]) {
            self.userInfo.creditWhiteListStatus = KQWhiteListStatusTrue;
        }else{
            self.userInfo.creditWhiteListStatus = KQWhiteListStatusFalse;
        }
        finishBlock();
    }failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        finishBlock();
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
}

- (void)refreshFinanceWhiteListFinishBlock:(void(^)(void))finishBlock{
    //理财白名单
    if (self.userInfo.financeWhiteListStatus != KQWhiteListStatusUnknown) {
        finishBlock();
        return;
    }
    [KQHttpService request:@{} bizType:@"M331" successBlock:^(Content *response) {
        if ([response.status isEqualToString:@"true"]) {
            self.userInfo.financeWhiteListStatus = KQWhiteListStatusTrue;
        }else{
            self.userInfo.financeWhiteListStatus = KQWhiteListStatusFalse;
        }
        finishBlock();
    }failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        finishBlock();
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
}

//#pragma mark - user delegate
//- (NSString *)userName{
//    return self.userInfo.userName;
//}
//
//- (NSString *)loginToken{
//    return self.userInfo.loginToken;
//}
//
//- (void)loginTokenChanged:(NSString *)token{
//    self.userInfo.loginToken = token;
//}
//
//- (NSString *)userId{
//    return self.userInfo.userId;
//}
//
//- (void)userIdChanged:(NSString *)userId{
//    self.userInfo.userId = userId;
//}
//
//- (BOOL)isLogin{
//    return self.userInfo.isLogin;
//}

#pragma mark - save user info to keychain
+ (NSArray *)historyUserArray{
    if (!KQB_Manager_UserInfo.cacheHistoryUserArray) {
        KQB_Manager_UserInfo.cacheHistoryUserArray = [[KQCKeychain loadValue:KQB_Manager_UserInfo.userKeyInKeychain] mutableCopy];
        if (!KQB_Manager_UserInfo.cacheHistoryUserArray) {
            KQB_Manager_UserInfo.cacheHistoryUserArray = [NSMutableArray array];
        }
    }
    return KQB_Manager_UserInfo.cacheHistoryUserArray;
}

+ (void)saveHistoryUser:(NSDictionary *)userDic{
    NSMutableArray *users = (NSMutableArray *)[KQBUserManager historyUserArray];
    
    NSDictionary *tempDic = nil;
    for (NSDictionary *dic in users) {
        if ([dic[kUserName] isEqualToString:userDic[kUserName]]) {
            tempDic = dic;
            break;
        }
    }
    
    if (tempDic) {
        [users removeObject:tempDic];
    }
    
    while ([users count] > MAX_USER_NUM) {
        [users removeLastObject];
    }
    
    //add the user
    [users insertObject:userDic atIndex:0];
    
    [KQCKeychain saveValue:users key:KQB_Manager_UserInfo.userKeyInKeychain];
}

+ (void)deleteHistoryUser:(NSString *)userName{
    NSMutableArray *users = (NSMutableArray *)[KQBUserManager historyUserArray];
    if (users){
        //delete the same user
        NSDictionary *tempDic = nil;
        for (NSDictionary *dic in users) {
            if ([[dic objectForKey:kUserName] isEqualToString:userName]) {
                tempDic = dic;
            }
        }
        
        if (tempDic != nil) {
            [users removeObject:tempDic];
        }
        
        [KQCKeychain saveValue:users key:KQB_Manager_UserInfo.userKeyInKeychain];
    }
}

- (NSString *)userKeyInKeychain{
    if (_userKeyInKeychain) {
        return _userKeyInKeychain;
    }
    
    NSString *environmentName = [KQBCacheEngine environmentName];
    _userKeyInKeychain = [kUserArray stringByAppendingString:environmentName];
    return _userKeyInKeychain;
}
@end
