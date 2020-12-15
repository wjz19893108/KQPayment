 //
//  KQLocationManager.m
//  KuaiQianBao
//
//  Created by 张蓓 on 15-1-28.
//  Copyright (c) 2015年 Emily. All rights reserved.
//

#import "KQCLocationEngine.h"
#import <CoreLocation/CoreLocation.h>
#import "KQCLocationAddress.h"

@interface KQCLocationEngine()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, copy) void (^resultBlock)(BOOL isSuccess);

@end

@implementation KQCLocationEngine

NSNotificationName const KQCLocationCurrentCityChangedNotification = @"LocationCurrentCityChangedNotification";

static NSString *AppleLanguagesKey = @"AppleLanguages";

SYNTHESIZE_SINGLETON_FOR_CLASS(KQCLocationEngine);

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)startLocationService{
    [self startLocationService:NULL];
}

- (void)startLocationService:(void(^)(BOOL success))resultBlock{
    if (![self checkStatus]) {
        [self treatUpdateLocation:NO];
        return;
    }
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];//创建位置管理器
        _locationManager.delegate = self;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 1000.0f;
    }
    
    self.locateState = KQCLocationStateUnknow;
    self.resultBlock = resultBlock;
    [_locationManager startUpdatingLocation];
}

- (BOOL)checkStatus{
    if ([CLLocationManager locationServicesEnabled]
        && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied){
        return YES;
    }
    return NO;
}

- (void)treatUpdateLocation:(BOOL)isSuccess{
    @synchronized (self.locationManager) {
        [_locationManager stopUpdatingLocation];
        
        if (self.resultBlock) {
            self.locateState = isSuccess ? KQCLocationStateSuccess : KQCLocationStateFailed;
            self.resultBlock(isSuccess);
            self.resultBlock = NULL; // 回调一次，直接销毁
        }
    }
}

#pragma mark --CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    _currentLocation = [locations lastObject];
    [self parseAddressLocation:_currentLocation];
}

- (void)parseAddressLocation:(CLLocation *)loc{
    self.longitude = KQC_FORMAT(@"%@", @(_currentLocation.coordinate.longitude));
    self.latitude = KQC_FORMAT(@"%@", @(_currentLocation.coordinate.latitude));
    [self treatUpdateLocation:YES];
    
    NSArray *userDefaultLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:AppleLanguagesKey];
    // 强制 成 简体中文
    [[NSUserDefaults standardUserDefaults] setObject:@[@"zh-hans"] forKey:AppleLanguagesKey];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        // 还原Device 的语言
        [[NSUserDefaults standardUserDefaults] setObject:userDefaultLanguages forKey:AppleLanguagesKey];
        if (error) {
            DLog(@"reverseGeocodeLocation error:%@", error);
            return;
        }
        
        NSDictionary *addressDic = nil;
        if ([placemarks count] > 0) {
            addressDic = [placemarks[0] addressDictionary];
        }
        [self parseAddress:addressDic];
    }];
}

- (void)parseAddress:(NSDictionary *)addressDic{
    if (!addressDic) {
        DLog(@"Location address is nil");
        [self treatUpdateLocation:NO];
        return;
    }
    
    self.address = [[KQCLocationAddress alloc] init];
    self.address.country = addressDic[@"Country"];
    self.address.state = addressDic[@"State"];
    self.address.city = addressDic[@"City"];
    self.address.subLocality = addressDic[@"SubLocality"];
    self.address.detailAddress = addressDic[@"FormattedAddressLines"][0];
    self.address.street = addressDic[@"Street"];
    self.address.name = addressDic[@"Name"];
    
    if ([self.address.city hasSuffix:@"市"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KQCLocationCurrentCityChangedNotification object:self.address.city];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self treatUpdateLocation:NO];
}

@end
