//
//  KQBOmsCardModel.h
//  KQBusiness
//
//  Created by pengkang on 2017/6/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQBOmsCardModel : NSObject<NSCoding>

@property (nonatomic, strong) UIColor  *bgColor;
@property (nonatomic, strong) UIColor  *textColor;

@property (nonatomic, strong) NSString *iconDiretory;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *isShowIcon;
@property (nonatomic, strong) NSString *jumpMode;
@property (nonatomic, strong) NSString *jumpTarget;
@property (nonatomic, strong) NSString *textContent;
@property (nonatomic, strong) NSString *subTextContent;     //副标题内容对应的M330接口字段
@property (nonatomic, strong) NSString *subTextContentValue;//实际副标题值
@property (nonatomic, strong) UIColor  *subTextColor;

- (instancetype)initWithDic:(NSDictionary *)configDic;

@end
