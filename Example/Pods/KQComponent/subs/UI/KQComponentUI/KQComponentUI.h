//
//  KQComponentUI.h
//  KQComponentUI
//
//  Created by xy on 2017/12/5.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentUI.
FOUNDATION_EXPORT double KQComponentUIVersionNumber;

//! Project version string for KQComponentUI.
FOUNDATION_EXPORT const unsigned char KQComponentUIVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KQComponentUI/PublicHeader.h>

#if __has_include(<KQComponent/KQComponent.h>)
#import <KQComponent/KQBFlowBaseViewController.h>
#import <KQComponent/KQBFlowController.h>
#import <KQComponent/KQBFlowDataModel.h>
#import <KQComponent/KQBBaseViewController.h>
#import <KQComponent/KQBBaseWebVC.h>
#import <KQComponent/KQPJSErrorCode.h>
#import <KQComponent/KQBJSBridge.h>
#import <KQComponent/KQPJSBridge.h>

#import <KQComponent/KQBColor.h>
#import <KQComponent/KQBFont.h>

#import <KQComponent/UIButton+KQBAddition.h>
#import <KQComponent/UIButton+KQNavgationButton.h>
#import <KQComponent/UILabel+KQBAddition.h>
#import <KQComponent/UITextField+KQBAddition.h>
#import <KQComponent/UIView+KQBAddition.h>

#import <KQComponent/KQKeyboardView.h>
#import <KQComponent/KQPayKeyboardView.h>
#import <KQComponent/KQSecureKeyboard.h>

#import <KQComponent/KQBRightBarButtonItemPopView.h>

#import <KQComponent/KQBStepsIndicatorView.h>

#import <KQComponent/KQBaseTextField.h>
#import <KQComponent/KQPhoneTextField.h>
#import <KQComponent/KQSecureTextField.h>

#import <KQComponent/KQBToastView.h>
#import <KQComponent/KQBWaitingView.h>
#import <KQComponent/KQErrorAlertView.h>
#import <KQComponent/KQBLoadingViewManager.h>

#import <KQComponent/KQBViewAnimation.h>
#else
#import <KQComponentUI/KQBFlowBaseViewController.h>
#import <KQComponentUI/KQBFlowController.h>
#import <KQComponentUI/KQBFlowDataModel.h>
#import <KQComponentUI/KQBBaseViewController.h>
#import <KQComponentUI/KQBBaseViewControllerStatistics.h>
#import <KQComponentUI/KQBBaseWebVC.h>
#import <KQComponentUI/KQPJSErrorCode.h>
#import <KQComponentUI/KQBJSBridge.h>
#import <KQComponentUI/KQPJSBridge.h>

#import <KQComponentUI/KQBColor.h>
#import <KQComponentUI/KQBFont.h>

#import <KQComponentUI/UIButton+KQBAddition.h>
#import <KQComponentUI/UIButton+KQNavgationButton.h>
#import <KQComponentUI/UILabel+KQBAddition.h>
#import <KQComponentUI/UITextField+KQBAddition.h>
#import <KQComponentUI/UIView+KQBAddition.h>

#import <KQComponentUI/KQKeyboardView.h>
#import <KQComponentUI/KQPayKeyboardView.h>
#import <KQComponentUI/KQSecureKeyboard.h>

#import <KQComponentUI/KQBRightBarButtonItemPopView.h>

#import <KQComponentUI/KQBStepsIndicatorView.h>

#import <KQComponentUI/KQBaseTextField.h>
#import <KQComponentUI/KQPhoneTextField.h>
#import <KQComponentUI/KQSecureTextField.h>

#import <KQComponentUI/KQBToastView.h>
#import <KQComponentUI/KQBWaitingView.h>
#import <KQComponentUI/KQErrorAlertView.h>
#import <KQComponentUI/KQBLoadingViewManager.h>

#import <KQComponentUI/KQBViewAnimation.h>
#endif

