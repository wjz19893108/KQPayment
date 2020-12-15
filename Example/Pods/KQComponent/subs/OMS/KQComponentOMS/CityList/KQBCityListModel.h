//
//  KQBCityListModel.h
//  KQBusiness
//
//  Created by building wang on 2017/12/7.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQBCityListModel : NSObject<NSCoding>

/**
 城市Id
 */
@property (nonatomic, strong, nullable) NSString *cityId;

/**
 城市名称
 */
@property (nonatomic, strong, nullable) NSString *cityName;

/**
 城市拼音
 */
@property (nonatomic, strong, nullable) NSString *cityPinYin;

- (instancetype _Nullable )initWithDic:(NSDictionary *_Nullable)configDic;
@end
