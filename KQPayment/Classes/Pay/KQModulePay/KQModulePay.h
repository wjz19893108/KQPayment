//
//  KQModulePay.h
//  KQModulePay
//
//  Created by xy on 2018/1/9.
//  Copyright © 2018年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQModulePay.
FOUNDATION_EXPORT double KQModulePayVersionNumber;

//! Project version string for KQModulePay.
FOUNDATION_EXPORT const unsigned char KQModulePayVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQModulePay/PublicHeader.h>

#if __has_include(<KQModule/KQModule.h>)
#import <KQModule/KQPaymentManager.h>
#import <KQModule/KQPayManagerDelegate.h>
#import <KQModule/KQPayOrderDataProcess.h>
#import <KQModule/KQPayOrderData.h>
#import <KQModule/KQPaymentMacro.h>
#import <KQModule/KQPaymentInfoBaseVC.h>
#import <KQModule/KQPayResultView.h>
#import <KQModule/KQPayCardLimitManager.h>
#import <KQModule/UIImage+KQProcessPay.h>
#import <KQModule/KQPayUIManager.h>
#import <KQModule/KQBasePayHalfView.h>
//#import <KQModule/KQFidoSDKDataModel.h>
#else
#import <KQModulePay/KQPaymentManager.h>
#import <KQModulePay/KQPayManagerDelegate.h>
#import <KQModulePay/KQPayOrderDataProcess.h>
#import <KQModulePay/KQPayOrderData.h>
#import <KQModulePay/KQPaymentMacro.h>
#import <KQModulePay/KQPaymentInfoBaseVC.h>
#import <KQModulePay/KQPayResultView.h>
#import <KQModulePay/KQPayCardLimitManager.h>
#import <KQModulePay/UIImage+KQProcessPay.h>
#import <KQModulePay/KQPayUIManager.h>
#import <KQModulePay/KQBasePayHalfView.h>
//#import <KQModulePay/KQFidoSDKDataModel.h>
#endif
