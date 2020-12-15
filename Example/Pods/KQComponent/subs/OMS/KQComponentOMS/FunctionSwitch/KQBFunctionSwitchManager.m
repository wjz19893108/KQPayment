//
//  KQFunctionSwitchManager.m
//  kuaiQianbao
//
//  Created by 徐昱 on 16/2/16.
//
//

#import "KQBFunctionSwitchManager.h"
#import <objc/runtime.h>
#import "KQBH5HostManager.h"
#import "KQBCacheManager.h"

@interface KQBFunctionSwitchManager()
@end

@implementation KQBFunctionSwitchManager

+ (KQBFunctionSwitchManager *)sharedManager{
    static KQBFunctionSwitchManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initializeData];
        self.omsResType = KQBResManagerTypeFunctionSwitch;
        [self resetData];
    }
    return self;
}

- (void)initializeData{
    self.regProtocolIsChecked = @"1";
    self.settingFloatVisible = @"1";
    self.depositBank = @"";
    self.bindCardErrorCodesForAlert = @"LG";
    self.showIncreaseCreditTipWhenApply = @"1";
    self.showIncreaseCreditInMore = @"1";
    self.partTransferCheckedLimit = @"50000";
    self.partTransferVisible = @"0";
    self.upgradeRemindTimes = @"1";
    self.upgradeRemindInterval = @"0";
    self.professionAlertVisible = @"1";
    self.idCardAlertVisible = @"1";
    self.promotionAfterRegister = @"";
    self.umengStat = @"1";
    self.kuaiqianStat = @"0"; // 默认不上送
    self.inviteFriendVisible = @"0";
    self.statUrl = @"";
    self.statRCUrl = @"";
    self.statPolicy = @"batch";
    self.statWifiOnly = @"0";
    self.branchInfoJsonForKLLQuick = @"{}";
    self.branchInfoJsonForForCommon = @"{\"CEB\":3,\"CIB\":3,\"HXB\":3}";
    self.professionList = @"各类专业、技术人员,国家机关、党群组织、企事业单位的负责人,办事人员和有关人员,商业工作人员,服务性工作人员,农林牧渔劳动者,生产工作、运输工作和部分体力劳动者,不便分类的其他劳动者";
    self.professionIdList = @"1A,1B,1C,1D,1E,1F,1G,1H";
    self.searchVoucherDefaultAmount = @"1000000";
    self.payFinishVCJsonByOrderTypeNew = @"{\"130001\":\"请在交易明细 - 消费中，查看订单详情\",\"270001\":\"请在我的－我的保单，查看认购详情\",\"270002\":\"请在我的－理财资产 – 保险理财中查看认购详情\"}";
    self.statFirstUploadDelay = @"0";
    self.fingerPrintVisible = @"0";
    self.idCardAlertForceVisible = @"0";
    self.remitMinimumLimit = @"100000";
    self.remitSupportBankListForIOS = @"{\"BCOM\":\"https://itunes.apple.com/cn/app/jiao-tong-yin-xing/id337876534?mt=8\",\"ICBC\":\"https://itunes.apple.com/cn/app/zhong-guo-gong-shang-yin-xing/id423514795?mt=8\"}";
    self.quickRolloutTime = @" {\"3\":\"GDB,PSBC,ICBC,ABC,BOC,CCB,BCOM,CMB,SPDB,CMBC,CEB,CIB,CITIC\",\"12\":\"SDB,HXB,PAB\"}";
    self.attractionTicketVisible = @"1";
    self.lifeConvenienceVisible = @"1";
    self.sodukoItemsPerRow = @"3";
    self.digitalSignEnabled = @"0";
    self.apisNeedTWSign = @"M250";
    self.errCodesCVV2InPay = @"H02P59Z,H14P57Z";
    self.errCodesChangeCardInfoInPay = @"H02P60Z,H14P58Z";
    self.errCodesSwitchPayMothedInPay = @"H02P61Z,H14P59Z";
    self.cScanBMaximumLimit = @"200000";
    self.insuranceFinancingEnabled = @"1";
    self.kuaililaiPlusVisble = @"0";
    self.pEVisible = @"0";
    self.fundNeedWhiteList = @"1";
    self.kljVisible = @"1";
    self.transferVisible = @"1";
    self.transferToSelfEnabled = @"0";
    self.transferNeedWhiteList = @"1";
    self.giftTextInRegisterVisible = @"1";
    self.associatedCardEnabeld = @"11";
    self.defaultLoginMode = @"0";
    self.myExperienceMoneyVisible = @"0";
    self.anYiHuaVisible = @"0";
    
    self.iOS_Latest_Version = @"3.0.1";
    self.m271ChangePayModeErrorCode = @"30,31,32,33,35";
    self.bankCardInsuranceNeedWhiteList = @"1";
    self.kyhProductShowVisible = @"{\"quota\":\"1\",\"free\":\"1\"}";
    self.bannerIDForOrderTypesInPay = @"{\"110001\":\"118\",\"110002\":\"118\",\"110003\":\"118\",\"110004\":\"119\",\"110005\":\"119\",\"110006\":\"118\",\"110007\":\"118\",\"110008\":\"120\",\"120001\":\"118\",\"130001\":\"118\",\"130002\":\"118\",\"140001\":\"120\",\"140002\":\"120\",\"150001\":\"117\",\"150002\":\"117\",\"160001\":\"119\",\"170001\":\"119\",\"180001\":\"118\",\"190001\":\"118\",\"240001\":\"120\",\"240002\":\"118\",\"240003\":\"120\",\"240004\":\"120\",\"250001\":\"120\",\"260001\":\"120\",\"270001\":\"117\",\"280001\":\"118\"}";
    self.freeSingleSumList = @"50,100,200,500,1000";
    self.mineVerionCheckVisible = @"0";
    self.scanTrustList = @"https://www.99bill.com/seashell/webapp/merchantapp/cashier/default.html#!/p/open-ffcard.html?agentNo=";
    self.keyBoardOutOfOrder = YES;
    self.quickLoginVisible = @"1";
    self.showNativePaySuccessPageList = @"120001,130001,130002";
    
    //3.1.3
    self.hotSearchList = @"iPhone,手环,OPPO手机,耳机,洛可可,笔记本,施华洛世奇,行车记录仪,毛绒玩具,单反";
    //3.1.4
    self.withdrawVisible = @"1";
    //3.1.4
    self.addressSearchLimit = @"100";
    self.bankStatementNumLimit = @"30";
    //3.1.6
    self.educationCertificationVisible = @"0";
    self.driverLicenseCertificationVisible = @"0";
    self.dynamicAllocationUseDefault = @"0";
    
    self.pollingNumLImit = @"100";
    self.pollingInterval = @"2";
    self.QRcodePayModeIncludingBalance = @"0";
    self.uploadPhotoMaxSize = @"800";
    self.regExValidMobile = @"{\"register\":\"^((13[0-9])|(14[0-9])|(15[0-9])|(16[5-6])|(17[1-9])|(18[0-9])|(191)|(19[8-9]))\\\\d{8}$\",\"common\":\"^((13[0-9])|(14[0-9])|(15[0-9])|(16[5-6])|(17[0-9])|(18[0-9])|(191)|(19[8-9]))\\\\d{8}$\"}";
    self.billNameForTypes = @"{\"B001\":\"全部\",\"B002\":\"网购\",\"B003\":\"线下消费\",\"B004\":\"转账\",\"B005\":\"充值提现\",\"B006\":\"还款\",\"B007\":\"缴费\",\"B008\":\"手机充值\",\"B009\":\"有退款\"}";
    
    if ([KQCApplication environmentType] == KQCAppEnvironmentTypePro) {
        self.orderTypesForH5BillDetail = @"{\"250110,250120,250210,250220,250310,250320\":\"https://cardh5.ffan.com/ffantWeb/lifePay/orderDetail.html?tradeOrderNo=\",\"250410,2505X0\":\"https://cardh5.ffan.com/ffantWeb/recharge/index.html#/order/\",\"250610,250710\":\"https://cardh5.ffan.com/ffantWeb/buscard/orderDel.html?orderNo=\"}";
    }else {
        self.orderTypesForH5BillDetail = @"{\"250110,250120,250210,250220,250310,250320\":\"https://cardh5.sit.ffan.com/ffantWeb/lifePay/orderDetail.html?tradeOrderNo=\",\"250410,2505X0\":\"https://cardh5.sit.ffan.com/ffantWeb/recharge/index.html#/order/\",\"250610,250710\":\"https://cardh5.sit.ffan.com/ffantWeb/buscard/orderDel.html?orderNo=\"}";
    }
    
    self.seedUpdateThreshold = @"36000";
    self.syncTimeCycle = @"604800";
    self.faceCertificationVisible = @"0";
    self.offlineQRCodeAvailable = @"0";
    
    if ([KQCApplication environmentType] == KQCAppEnvironmentTypePro) {
        self.wimiUrl = @"https://api.wimift.com/h5/BZBmicrofinance/bangnihuan/bangnihuanIndex.html?access_org=kq&access_org_app=KQQB";
    }else {
        self.wimiUrl = @"http://119.145.28.254:18081/h5/BZBmicrofinance/bangnihuan/bangnihuanIndex.html?access_org=kq&access_org_app=KQQB";
    }
    self.feePackageVisible = @"0";
    self.changePhoneEnter = @"0";
    self.inviteShareVisible = @"0";
    self.inviteShareUrl = @"";
    self.dataPointDepth = @"2";
    
    self.riskAssessEntry = @"0";
    self.inviteShareTimes = @"5";
    self.snInputFlag = @"0";
    
    self.sqBannerList = @"";
    self.s0time = @"";
    self.s0Flag = @"0";
    
    self.businessLicenseCertificationVisible = @"0";
    self.tradeModeVisible = @"0";
    self.rateDisplayMode = @"0";
    self.merchantNameVisible = @"0";
    self.errorCodeList = @"CS1042";
    self.tradeReachUrl = @"https://www.99bill.com/seashell/webapp/kpos-trade-reach/index.html#/?merchantId=";
    self.multiStoreVisible = @"1";
    self.minAmountForDelayInsurance = @"20000";
    self.delayInsuranceCacheTime = @"86400";
    self.promotionTabVisible = @"0";
    self.creditCardTabVisible = @"0";
    self.certificateAmount = @"100";
    self.freeLoginEnter = @"0";
    self.unionPayCloudEnter = @"0";
    self.unionPayCloudUrl = @"";
    self.agreementList = @"[{ \"agreementName\": \"《快钱商户服务协议》、\", \"agreementUrl\": \"https://www.99bill.com/seashell/webapp/agreement/kqs-shanghufuwu.html\" }, { \"agreementName\": \"《快钱商户隐私保护政策》、\", \"agreementUrl\": \"https://www.99bill.com/seashell/webapp/agreement/kqs-shanghuyinsi.html\" }, { \"agreementName\": \"《快钱平台用户服务协议》\", \"agreementUrl\": \"https://www.99bill.com/seashell/webapp/agreement/kqs-yonghufuwu.html\"}]";
    self.imageMinLimit = @"50";
    self.kqsAliWtPayEntranceConfig = @"0";
    self.imageMaxLimit = @"1024";
    self.adviertisementSwitch = @"0";
    self.sgjBannerVisible = @"0";
    self.delayInsuranceVisible = @"1";
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}

- (NSString *)replaceNewLineWord:(NSString *)srcStr{
    return [srcStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (NSString *)replaceWrapperWord:(NSString *)srcStr{
    return [srcStr stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
}

- (void)loadCache{
    [super loadCache];
    if (!self.resDic) {
        self.resDic = [NSMutableDictionary dictionary];
    }
    [self updateData:self.resDic  resId:nil resHome:nil];
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if (msgContent.count == 0) {
        [self initializeData];
        return;
    }
    
    //开关配置
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([KQBFunctionSwitchManager class], &count);
    for (int i = 0; i < count; ++i) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *keyName = KQC_FORMAT(@"%s", name);
        if ([keyName isEqualToString:@"resDic"]) {
            continue;
        }
        
        if ([keyName isEqualToString:@"omsResType"]) {
            continue;
        }
        
        NSString *keyValue = [msgContent objectForKey:keyName];
        if ([NSString kqc_isBlank:keyValue]) {
            continue;
        }
        [self setValue:keyValue forKey:keyName];
    }
    
    if ([self.secureHostsEnabled isEqualToString:@"1"]) {
        [H5HostManager updateData:self.resDic[@"hostList"]];
    } else {
        H5HostManager.isAllowAllUrl = YES;
    }
    
    [KQBCacheManager saveObject:msgContent cacheType:KQCacheTypeFunctionSwitch];
    [[NSNotificationCenter defaultCenter] postNotificationName:KQComponentConfigUpdateNotification object:msgContent];
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeFunctionSwitch;
}
@end
