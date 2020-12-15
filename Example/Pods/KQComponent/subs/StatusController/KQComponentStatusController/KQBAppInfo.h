//
//  KQBAppInfo.h
//  KQBusiness
//
//  Created by pengkang on 2016/12/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQBAppInfo : NSObject

@property (nonatomic, strong) NSString *appType;
@property (nonatomic, strong) NSString *latestAppVersionUrl;
@property (nonatomic, strong) NSString *appFlag;
@property (nonatomic, strong) NSString *gradientLaunchMessageTitle;
@property (nonatomic, strong) NSString *gradientLaunchMessageContent;
@property (nonatomic, strong) NSString *md5;

- (instancetype)initWithAppInfo:(id)response;

@end

@interface KQBConfigInfo: NSObject

@property (nonatomic, strong) NSString *lastRemindTime;
@property (nonatomic, strong) NSString *upgradeRemindTimes;
@property (nonatomic, strong) NSString *remainUpgradeTimes;
@property (nonatomic, strong) NSString *md5;

- (void)saveCache;
@end
