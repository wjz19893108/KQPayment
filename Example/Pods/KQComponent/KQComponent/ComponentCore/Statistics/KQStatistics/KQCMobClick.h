//
//  KQCMobClick.h
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import <Foundation/Foundation.h>
#import "StatisticsModel.h"

@interface KQCMobClick : NSObject

/** 开启自建埋点统计,默认以KQCATCH方式发送log.
 @param staModel 传入产品相关数据.
 */
+ (void)startWithData:(StatisticsModel *)staModel;

///---------------------------------------------------------------------------------------
/// @name  页面计时
///---------------------------------------------------------------------------------------

/** 页面时长统计,记录某个view被打开多长时间,可以自己计时也可以调用beginLogPageView,endLogPageView自动计时
 
 @param pageName 需要记录时长的view名称.
 */
+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;


#pragma mark event logs


///---------------------------------------------------------------------------------------
/// @name  事件统计
///---------------------------------------------------------------------------------------

/** 自定义事件,数量统计.
 */
+ (void)event:(NSString *)eventId; //等同于 event:eventId label:eventId;

/** 自定义事件,数量统计.
 @param  eventId 网站上注册的事件Id.
 @param  label 分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比,为nil或空字符串时后台会生成和eventId同名的标签.
 */
+ (void)event:(NSString *)eventId label:(NSString *)label; // label为nil或@""时，等同于 event:eventId label:eventId;
/** 自定义事件,数量统计.
 */
+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes;

/**
 无视上传策略实时上传的自定义事件

 @param eventId 事件id
 @param attributes 事件属性
 */
+ (void)realTimeEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;
@end
