//
//  KQComponentOMS.h
//  KQComponentOMS
//
//  Created by xy on 2017/12/8.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KQComponentOMS.
FOUNDATION_EXPORT double KQComponentOMSVersionNumber;

//! Project version string for KQComponentOMS.
FOUNDATION_EXPORT const unsigned char KQComponentOMSVersionString[];

#if __has_include(<KQComponent/KQComponent.h>)
#import <KQComponent/KQBFunctionSwitchManager.h>

#import <KQComponent/KQBDescriptionManager.h>

#import <KQComponent/KQBH5ResourceManager.h>
#import <KQComponent/KQBH5HostManager.h>

#import <KQComponent/KQBBannerManager.h>
#import <KQComponent/KQBBannerModel.h>
#import <KQComponent/KQBOmsBannerModel.h>

#import <KQComponent/KQBCardManager.h>
#import <KQComponent/KQBCardModel.h>
#import <KQComponent/KQBOmsCardModel.h>

#import <KQComponent/KQBCreditProductManager.h>
#import <KQComponent/KQBCreditProductModel.h>
#import <KQComponent/KQBOmsCreditProductModel.h>

#import <KQComponent/KQBFallManager.h>
#import <KQComponent/KQBFallModel.h>
#import <KQComponent/KQBOmsFallModel.h>

#import <KQComponent/KQBFinancialProductManager.h>
#import <KQComponent/KQBFinancialProductModel.h>
#import <KQComponent/KQBOmsFinancialProductModel.h>

#import <KQComponent/KQBImageManager.h>
#import <KQComponent/KQBImageModel.h>
#import <KQComponent/KQBOmsImageModel.h>

#import <KQComponent/KQBMatrixManager.h>
#import <KQComponent/KQBMatrixModel.h>
#import <KQComponent/KQBOmsMatrixModel.h>

#import <KQComponent/KQBOmsPageHeaderModel.h>
#import <KQComponent/KQBPageHeaderManager.h>
#import <KQComponent/KQBPageHeaderModel.h>

#import <KQComponent/KQBPageManageDelegate.h>
#import <KQComponent/KQBPageManager.h>
#import <KQComponent/KQBOmsPageItemHeaderModel.h>
#import <KQComponent/KQBOmsPageModel.h>
#import <KQComponent/KQBPageCard.h>
#import <KQComponent/KQBPageModel.h>

#import <KQComponent/KQBOmsSodukoModel.h>
#import <KQComponent/KQBSodukoManager.h>
#import <KQComponent/KQBSodukoModel.h>

#import <KQComponent/KQBOmsAdvPageModel.h>
#import <KQComponent/KQBStartupPageManager.h>
#import <KQComponent/KQBStartupPageModel.h>

#import <KQComponent/KQBOmsTabModel.h>
#import <KQComponent/KQBTabManager.h>
#import <KQComponent/KQBTabsModel.h>

#import <KQComponent/KQBBaseResModel.h>
#import <KQComponent/KQBOmsBaseModel.h>
#import <KQComponent/KQBOmsConfigData.h>
#import <KQComponent/KQBBaseOmsResManager.h>

#import <KQComponent/KQPOmsMacro.h>
#import <KQComponent/KQPOmsManager.h>
#import <KQComponent/KQPOmsTool.h>

#import <KQComponent/UIImageView+OMS.h>

#else

#import <KQComponentOMS/KQBFunctionSwitchManager.h>

#import <KQComponentOMS/KQBDescriptionManager.h>

#import <KQComponentOMS/KQBH5ResourceManager.h>
#import <KQComponentOMS/KQBH5HostManager.h>

#import <KQComponentOMS/KQBBannerManager.h>
#import <KQComponentOMS/KQBBannerModel.h>
#import <KQComponentOMS/KQBOmsBannerModel.h>

#import <KQComponentOMS/KQBCardManager.h>
#import <KQComponentOMS/KQBCardModel.h>
#import <KQComponentOMS/KQBOmsCardModel.h>

#import <KQComponentOMS/KQBCreditProductManager.h>
#import <KQComponentOMS/KQBCreditProductModel.h>
#import <KQComponentOMS/KQBOmsCreditProductModel.h>

#import <KQComponentOMS/KQBFallManager.h>
#import <KQComponentOMS/KQBFallModel.h>
#import <KQComponentOMS/KQBOmsFallModel.h>

#import <KQComponentOMS/KQBFinancialProductManager.h>
#import <KQComponentOMS/KQBFinancialProductModel.h>
#import <KQComponentOMS/KQBOmsFinancialProductModel.h>

#import <KQComponentOMS/KQBImageManager.h>
#import <KQComponentOMS/KQBImageModel.h>
#import <KQComponentOMS/KQBOmsImageModel.h>

#import <KQComponentOMS/KQBMatrixManager.h>
#import <KQComponentOMS/KQBMatrixModel.h>
#import <KQComponentOMS/KQBOmsMatrixModel.h>

#import <KQComponentOMS/KQBOmsPageHeaderModel.h>
#import <KQComponentOMS/KQBPageHeaderManager.h>
#import <KQComponentOMS/KQBPageHeaderModel.h>

#import <KQComponentOMS/KQBOmsPageItemHeaderModel.h>
#import <KQComponentOMS/KQBOmsPageModel.h>
#import <KQComponentOMS/KQBPageCard.h>
#import <KQComponentOMS/KQBPageModel.h>

#import <KQComponentOMS/KQBOmsSodukoModel.h>
#import <KQComponentOMS/KQBSodukoManager.h>
#import <KQComponentOMS/KQBSodukoModel.h>

#import <KQComponentOMS/KQBOmsAdvPageModel.h>
#import <KQComponentOMS/KQBStartupPageManager.h>
#import <KQComponentOMS/KQBStartupPageModel.h>

#import <KQComponentOMS/KQBOmsTabModel.h>
#import <KQComponentOMS/KQBTabManager.h>
#import <KQComponentOMS/KQBTabsModel.h>

#import <KQComponentOMS/KQBBaseResModel.h>
#import <KQComponentOMS/KQBOmsBaseModel.h>
#import <KQComponentOMS/KQBOmsConfigData.h>
#import <KQComponentOMS/KQBBaseOmsResManager.h>

#import <KQComponentOMS/KQPOmsMacro.h>
#import <KQComponentOMS/KQPOmsManager.h>
#import <KQComponentOMS/KQPOmsTool.h>

#import <KQComponentOMS/UIImageView+OMS.h>

#endif


