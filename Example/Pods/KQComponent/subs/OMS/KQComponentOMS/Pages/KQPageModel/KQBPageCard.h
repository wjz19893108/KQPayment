//
//  KQBPageCard.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/21.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQBOmsPageItemHeaderModel.h"
#import "KQBBaseResModel.h"
//Card类型 1:N行N列、2:九宫格、3:Banner、4:H5、5:信用头部、6:信用产品、7:瀑布流///

typedef NS_ENUM(NSInteger, KQBCardType){
    KQBCardTypeMatrix = 1,
    KQBCardTypeSoduko ,
    KQBCardTypeBanner ,
    KQBCardTypeH5 ,
    KQBCardTypeCreditHeader ,
    KQBCardTypeCreditProduct ,
    KQBCardTypeCreditFall
};

typedef NS_ENUM(NSInteger, KQBCardResFrom){
    KQBCardResFromZip = 0,
    KQBCardResFromInterface = 1
};

typedef NS_ENUM(NSInteger, KQBCardResStatus){
    KQBCardResStatusNone = 0,
    KQBCardResStatusSuccess = 1,
    KQBCardResStatusFail = 2
};

@interface KQBPageCardResInfo : NSObject<NSCoding>

@property (nonatomic, assign) KQBCardResFrom itemsFrom;      //卡片内容获取方式0:无路径 1:zip包 2：接口

@property (nonatomic, assign) NSInteger itemsResId;          //卡片内容如果为zip包，则对应zip包Id
@property (nonatomic, strong) NSString *itemsMd5;            //zip包MD5值

@property (nonatomic, strong) NSString *itemsInterface;      //卡片内容如果为zip包，则对应接口号“Mxxx”
@property (nonatomic, strong) NSArray *linkedInterface;      //数据关联接口

@end

@interface KQBPageCard : NSObject<NSCoding>

@property (nonatomic, assign) KQBCardType cardType;                     //卡片内容类型
@property (nonatomic, strong) NSString *cardStyle;                    //卡片内容样式
@property (nonatomic, strong) UIColor *backgroundColor;               //卡片背景色
@property (nonatomic, strong) NSString *backgroundImageUrl;           //卡片背景图
@property (nonatomic, strong) NSDictionary *parameters;               //卡片参数
@property (nonatomic, strong) KQBPageCardResInfo *resInfo;            //卡片内容信息
@property (nonatomic, strong) KQBOmsPageItemHeaderModel *itemHeader;  //卡片heaeder
@property (nonatomic, strong) KQBBaseResModel *resObj;                //卡片内容
@property (nonatomic, strong) NSString *resHome;                      //  资源根目录
@property (nonatomic, strong) NSString *resFrom;                      //  资源来源
@property (nonatomic, assign) KQBCardResStatus itemsStatus;           //  资源状态
@property (nonatomic, assign) NSUInteger businessStatus;
/**
 *  解析json文件中的配置信息
 *  @param configDic : zip 包中config文件的内容
 *  @param resHome : 资源本地根目录
 */
- (instancetype)initWithDic:(NSDictionary *)configDic
                    resHome:(NSString *)resHome;
@end
