//
//  StatisticsManager.h
//  kuaishua
//
//  Created by xuyue on 14/11/27.
//
//

#import <Foundation/Foundation.h>

#define KQStatisticsManager [KQCStatisticsManager sharedKQCStatisticsManager]

@interface UIButton (StatisticsManager)
@property (nonatomic, strong) NSString *eventID;
@end

@class StatisticsModel;
@protocol KQStatisticsUserDelegate;
@protocol KQStatisticsNetworkDelegate;

@interface KQCStatisticsManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(KQCStatisticsManager);

@property (nonatomic, weak) id<KQStatisticsUserDelegate> userDelegate;
@property (nonatomic, weak) id<KQStatisticsNetworkDelegate> networkDelegate;



/**
 注册埋点所需要的数据

 @param config 埋点唯一的APP KEY
 @param valueDic 界面对应的埋点值
 */
+ (void)registerStatistics:(StatisticsModel *)config valueDic:(NSDictionary *)valueDic;

+ (void)beginLogPageView:(NSObject *)screen;

+ (void)endLogPageView:(NSObject *)screen;

+ (void)logEvent:(NSString *)eventID button:(UIButton *)button;

+ (void)logEvent:(NSString *)eventID;

//按照不同的标签统计同一个事件
+ (void)logEvent:(NSString *)eventID label:(NSString*)label;

+ (void)logEvent:(NSString *)eventID attributes:(NSDictionary*)dic;

+ (void)logPageName:(NSString *)pageName; // 直接纪录某个特殊页面

+ (void)logEventForRC:(NSString *)eventID;  //自建风控埋点实时上送，上送行为数据

+ (void)logLoginEventForRC:(NSString *)eventID;  //自建登陆风控埋点实时上送，上送行为数据

@end
