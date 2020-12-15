//
//  KQBFlowDataModel.m
//  kuaiQianbao
//
//  Created by xy on 16/3/31.
//
//

#import "KQBFlowDataModel.h"

@implementation KQBFlowDataModel

+ (instancetype)flowDataModelWithName:(NSString *)viewControllerName title:(NSString *)title{
    return [KQBFlowDataModel flowDataModelWithName:viewControllerName title:title paramDic:nil];
}

+ (instancetype)flowDataModelWithName:(NSString *)viewControllerName title:(NSString *)title paramDic:(NSDictionary *)paramDic{
    KQBFlowDataModel *data = [[KQBFlowDataModel alloc] init];
    data.viewControllerName = viewControllerName;
    data.title = title;
    data.paramDic = paramDic;
    return data;
}

@end
