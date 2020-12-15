//
//  KQOmsBaseModel.h
//  kuaiQianbao
//  json文件中的某个对象的模型
//  Created by pengkang on 16/1/4.
//
//

#import <Foundation/Foundation.h>

#define NeedRealName @"1"

@interface KQBOmsBaseModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *resId;         //默认图片
@property (nonatomic, strong) NSString *resHome;             //资源文件主目录
@property (nonatomic, strong) NSString *position;            //使用位置
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *jumpModel;
@property (nonatomic, strong) NSString *jumpTarget;
@property (nonatomic, strong) NSString *resUrl;
@property (nonatomic, strong) NSString *resType;
@property (nonatomic, strong) NSString *resNeedRealName;       //是否需要实名
@property (nonatomic, strong) NSString *resName;
@property (nonatomic, strong) NSString *resDiretory;
@property (nonatomic, strong) NSString *isNeedLogin;          //是否需要登录
@property (nonatomic, strong) NSString *placeHolder;         //默认图片
@property (nonatomic, assign) BOOL isAvailable;         //是否过期

/**
 *  初始化Model
 *
 *  @param configDic : configDic 配置信息字典
 */
- (instancetype)initWithDic:(NSDictionary *)configDic;

- (void)encodeWithCoder:(NSCoder *)aCoder;

- (id)initWithCoder:(NSCoder *)aDecoder;

@end
