//
//  KQBJSBridge.m
//  KQBusiness
//
//  Created by pengkang on 2016/12/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBJSBridge.h"
#import "KQBBaseViewController.h"
#import "KQBBaseWebVC.h"

@interface KQBJSBridge()<UIImagePickerControllerDelegate>

@end

@implementation KQBJSBridge

#pragma mark - 获取AccessToken
- (void)getAccessToken:(NSDictionary *)dic{
    if ([ComponentManager.userStatusDelegate respondsToSelector:@selector(thirdIdentity)]) {
        NSString *accessToken = [ComponentManager.userStatusDelegate thirdIdentity];
        [self successCallback:dic message:@{@"accessToken":KQC_NON_NIL(accessToken)}];
    } else {
        NSDictionary *result = @{@"errorCode":@"获取用户身份失败"};
        [self failedCallback:dic message:result];
    }
}

#pragma mark - Toast提示
- (void)showToast:(NSDictionary *)dic{
    NSString *message = [dic objectForKey:@"message"];
    if (![NSString kqc_isBlank:message]) {
        [KQBToastView show:message];
    }
}

#pragma mark - 获取DEVICEID
- (void)getDeviceId:(NSDictionary *)dic{
    NSString *strDeviceID = [KQCDevice deviceId];
    if (strDeviceID) {
        NSDictionary *result = @{@"deviceId":strDeviceID};
        [self successCallback:dic message:result];
    }else{
        NSDictionary *result = @{@"errorCode":@"获取设备ID失败"};
        [self failedCallback:dic message:result];
    }
}

#pragma mark - 页面回退
- (void)goback:(NSDictionary *)dic{
    if ([KQC_Engine_UI topViewController].presentedViewController) {
        [[KQC_Engine_UI topViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        [KQC_Engine_UI popViewController];
    }
}


#pragma mark - 获取地理位置
- (void)getGeoPosition:(NSDictionary *)dic{
    BOOL isMustGetLocation = [dic[@"isMust"] isEqualToString:@"1"];
    
    if (isMustGetLocation &&![KQC_Engine_Location checkStatus]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"打开\"定位服务\"来允许\"快钱刷\"确定您的位置"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    
    if ([KQC_Engine_Location checkStatus]) {
        if (![NSString kqc_isBlank:KQC_Engine_Location.latitude] && ![NSString kqc_isBlank:KQC_Engine_Location.longitude] ) {
            
            NSDictionary *result = @{@"latitude":KQC_NON_NIL( KQC_Engine_Location.latitude),
                                     @"longitude":KQC_NON_NIL(KQC_Engine_Location.longitude),
                                     @"province":KQC_NON_NIL(KQC_Engine_Location.address.state),
                                     @"city":KQC_NON_NIL(KQC_Engine_Location.address.city),
                                     @"zone":KQC_NON_NIL(KQC_Engine_Location.address.subLocality)};
            [self successCallback:dic message:result];
            return;
        }
    }
    
    if ([KQC_Engine_Location checkStatus]) {
        [KQC_Engine_Location  startLocationService];
    }
    
    [self failedCallback:dic message:@{@"errorMsg":@"定位失败，请稍后再试"}];
    
    if (isMustGetLocation && ![KQC_Engine_Location checkStatus]) {
        __weak UIViewController *weakSelf = self.baseWebView.baseVC;
        if (KQC_SYSTEM_VRESION_8) {
            [RMUniversalAlert showAlertInViewController:weakSelf withTitle:nil message:@"定位服务未开启，请进入系统【设置】>【隐私】>【定位服务】中打开开关，并允许快钱刷使用定位服务" cancelButtonTitle:@"取消" destructiveButtonTitle:@"立即开启" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
            return;
        }
        [RMUniversalAlert showAlertInViewController:weakSelf withTitle:nil message:@"定位服务未开启，请进入系统【设置】>【隐私】>【定位服务】中打开开关，并允许快钱刷使用定位服务" cancelButtonTitle:@"知道了" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
        }];
    }
}

- (void)navigationBarMenu:(NSDictionary *)dic{
    // 空值不会退，当清除当前菜单处理
    // 在理财首页添加左边的菜单，关闭和返回按钮暂时不考虑
    //    NSString *showClose = dic[@"showClose"];    //0:不显示关闭按钮l; 1:显示关闭按钮
    //    NSString *showBack = dic[@"showBack"];      //0:不显示返回按钮l; 1:显示返回按钮
    NSString *positon = dic[@"positon"];        //left:左边菜单; right:右边菜单
    
    NSArray *menuArray = dic[@"menuList"];
    NSMutableArray *tempArray = [NSMutableArray array];
    [menuArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        KQBBaseWebVCMenuModel *menuModel = [[KQBBaseWebVCMenuModel alloc] init];
        menuModel.iconUrl = obj[@"iconUrl"];
        menuModel.name = obj[@"name"];
        menuModel.needRealName = [obj[@"needRealName"] isEqualToString:@"1"];
        menuModel.jumpModel = obj[@"jumpModel"];
        menuModel.jumpTarget = obj[@"jumpTarget"];
        menuModel.functionName = obj[@"functionName"];
        menuModel.needLogin = [obj[@"isNeedLogin"] isEqualToString:@"1"];
        [tempArray addObject:menuModel];
    }];
    
    if ([positon isEqualToString:@"left"]) {
        if ([self.baseWebView.baseVC respondsToSelector:@selector(addLeftButtonWithBannerArray:)]) {
            [(KQBBaseWebVC *)self.baseWebView.baseVC addLeftButtonWithBannerArray:tempArray];
        }
    } else {
        if ([self.baseWebView.baseVC respondsToSelector:@selector(addRightButtonWithBannerArray:)]) {
            [(KQBBaseWebVC *)self.baseWebView.baseVC addRightButtonWithBannerArray:tempArray];
        }
    }
}

#pragma mark - webView是否允许回弹开关
- (void)setWebviewBounce:(NSDictionary *)dic{
    NSString *flag = dic[@"enableBounce"];
    if ([NSString kqc_isBlank:flag]) {
        return;
    }
    self.baseWebView.scrollView.bounces = [flag isEqualToString:@"true"] ? YES : NO;
}

#pragma mark - webView是否允许滚动开关
- (void)setWebviewScroll:(NSDictionary *)dic{
    NSString *flag = dic[@"enableScroll"];
    if ([NSString kqc_isBlank:flag]) {
        return;
    }
    
    self.baseWebView.scrollView.scrollEnabled = [flag isEqualToString:@"true"] ? YES : NO;
}

#pragma mark - 打电话
- (void)tel:(NSDictionary *)dic{
    id phoneNO = dic[@"phoneNum"];
    if ([phoneNO isKindOfClass:[NSString class]]) {
        [self dial:phoneNO];
    } else if ([phoneNO isKindOfClass:[NSArray class]]) {
        NSMutableArray *phoneNODesc = [NSMutableArray arrayWithCapacity:((NSArray *)phoneNO).count];
        [phoneNO enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [phoneNODesc addObject:KQC_FORMAT(@"拨打电话：%@", obj)];
        }];
        
        [RMUniversalAlert showActionSheetInViewController:self.baseWebView.baseVC withTitle:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:phoneNODesc popoverPresentationControllerBlock:^(RMPopoverPresentationController * _Nonnull popover) {
        } tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
            if(buttonIndex < 2) {
                return;
            }
            [self dial:phoneNO[buttonIndex - 2]];
        }];
    }
}

- (void)dial:(NSString *)phoneNO{
    NSString *dialUrl = KQC_FORMAT(@"tel:%@", phoneNO);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialUrl]];
}

#pragma mark - 照相
- (void)camera:(NSDictionary *)dic{
    self.jsRequestDic[@"camera"] = dic;
    [self takePhoto];
}

-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing=NO;
    picker.sourceType=sourceType;
    [self.baseWebView.baseVC.navigationController presentViewController:picker animated:YES completion:nil];
}

-(void)saveImage:(UIImage*)image
{
    NSData *imageData;
    imageData = UIImageJPEGRepresentation(image, 0.1);
    
    NSString *base64Str = [imageData base64EncodedString];
    
    [self.baseWebView evaluateJavaScript:[NSString stringWithFormat:@"showPhoto('%@','%@')", self.jsRequestDic[@"camera"][@"token"],[base64Str kqc_urlEncodedString]] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
    [self.jsRequestDic removeObjectForKey:@"camera"];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelector:@selector(saveImage:) withObject:image afterDelay:0.5];
}

#pragma mark - 获取IP
- (void)getIPAddress:(NSDictionary *)dic{
    NSString *strDeviceIP = [KQCDevice deviceIPAddress];
    if (strDeviceIP) {
        NSDictionary *result = @{@"ipAddress":strDeviceIP};
        [self successCallback:dic message:result];
    }else{
        NSDictionary *result = @{@"errorCode":@"获取IP失败"};
        [self failedCallback:dic message:result];
    }
}

#pragma  mark - 设置title
- (void)setPageTitle:(NSDictionary *)dic{
    [(KQBBaseViewController *)self.baseWebView.baseVC setNavigationTitle:dic[@"title"]];
}

@end
