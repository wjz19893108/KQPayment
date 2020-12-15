//
//  KQBFlowDataModel.h
//  kuaiQianbao
//
//  Created by xy on 16/3/31.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQBFlowType) {
    KQBFlowTypeUnknow = 0,                   // 未知，可以通过此值来判断是否在流程里
    KQBFlowTypeRealName,                     // 未实名未绑卡，走实名流程
    KQBFlowTypeForgetPayPasswordUnBindCard,  // 已实名未绑卡，走实名绑卡绑卡
    KQBFlowTypeForgetPayPasswordHasBindCard  // 已实名已绑卡，银行卡鉴权流程
};

@interface KQBFlowDataModel : NSObject

@property (nonatomic, strong) NSString *viewControllerName;   // 界面名称
@property (nonatomic, strong) NSString *title;                // 界面标题
@property (nonatomic, strong) NSDictionary *paramDic;         // 界面参数

+ (instancetype)flowDataModelWithName:(NSString *)viewControllerName title:(NSString *)title;

+ (instancetype)flowDataModelWithName:(NSString *)viewControllerName title:(NSString *)title paramDic:(NSDictionary *)paramDic;

@end
