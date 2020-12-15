//
//  KQBScreenJumpModel.m
//  kuaiQianbao
//
//  Created by xy on 16/4/19.
//
//

#import "KQBScreenJumpModel.h"

@implementation KQBScreenJumpModel

+ (instancetype)jumpModelWithJumpMode:(NSString *)jumpModeStr jumpTarget:(NSString *)jumpTarget{
    return [KQBScreenJumpModel jumpModelWithJumpMode:jumpModeStr jumpTarget:jumpTarget isNeedLogin:NO isNeedRealName:NO];
}

+ (instancetype)jumpModelWithJumpMode:(NSString *)jumpModeStr jumpTarget:(NSString *)jumpTarget isNeedLogin:(BOOL)isNeedLogin isNeedRealName:(BOOL)isNeedRealName{
    KQBScreenJumpModel *jumpModel = [[KQBScreenJumpModel alloc] init];
    if ([jumpModeStr isEqualToString:@"1"]) {
        jumpModel.jumpMode = KQPScreenJumpModeTypeNative;
    } else if ([jumpModeStr isEqualToString:@"2"]) {
        jumpModel.jumpMode = KQPScreenJumpModeTypeH5;
    } else {
        jumpModel.jumpMode = KQPScreenJumpModeTypeNone;
    }
    
    jumpModel.jumpTarget = jumpTarget;
    jumpModel.isNeedLogin = isNeedLogin;
    jumpModel.isNeedRealName = isNeedRealName;
    return jumpModel;
}

+ (instancetype)jumpModelWithJumpMode:(NSString *)jumpModeStr
                           jumpTarget:(NSString *)jumpTarget
                         jumpPageType:(NSString *)jumpPageType
                            targetDic:(NSDictionary *)targetDic{
    return [KQBScreenJumpModel jumpModelWithJumpMode:jumpModeStr jumpTarget:jumpTarget jumpPageType:jumpPageType targetDic:targetDic isNeedLogin:NO isNeedRealName:NO];
}

+ (instancetype)jumpModelWithJumpMode:(NSString *)jumpModeStr
                           jumpTarget:(NSString *)jumpTarget
                         jumpPageType:(NSString *)jumpPageType
                            targetDic:(NSDictionary *)targetDic
                          isNeedLogin:(BOOL)isNeedLogin
                       isNeedRealName:(BOOL)isNeedRealName{
    KQBScreenJumpModel *jumpModel = [KQBScreenJumpModel jumpModelWithJumpMode:jumpModeStr jumpTarget:jumpTarget];
    
    jumpModel.jumpPageType = jumpPageType;
    jumpModel.targetDic = targetDic;
    jumpModel.isNeedLogin = isNeedLogin;
    jumpModel.isNeedRealName = isNeedRealName;
    return jumpModel;
}

@end
