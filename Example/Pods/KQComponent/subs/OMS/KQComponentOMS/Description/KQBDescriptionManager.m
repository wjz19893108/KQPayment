//
//  KQDescriptionManager.m
//  kuaiQianbao
//
//  Created by xy on 15/12/19.
//KQBusiness.framework
//

#import "KQBDescriptionManager.h"
#import <objc/runtime.h>
#import "KQBFunctionSwitchManager.h"
#import "KQBH5ResourceManager.h"
#import "KQBCacheManager.h"

@implementation KQBDescriptionManager

+ (KQBDescriptionManager *)sharedManager{
    static KQBDescriptionManager *instance = nil;
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
        self.omsResType = KQBResManagerTypeDescription;
        [self resetData];
    }
    return self;
}

- (void)initializeData{
    self.BC012T000001 = @"自动扣款将在还款当日0:00-12:00之间进行；还款方式变更对当日应还款交易无效，当日应还款交易遵照原有方式还款；在23:30--次日00:30之间不能主动还款";
    self.BC012T000002 = @"快易花自动分期，省心省力！只要使用快易花消费，金额达到100元分期条件时即可自动分期12期";
    self.BC012T000003 = @"智慧身份认证是基于人的脸部特征信息进行身份识别的一种生物识别技术，快钱致力于采用先进的技术手段保证您的资产信息安全。";
    self.BC012T000005 = @"设置默认分期后，每笔交易将按此收取手续费。可在快易花>更改分期修改。如遇手续费变更，我们会以短信通知。";
    self.BC012T000006 = @"提额小助手";
    self.BC012T000007 = @"您的额度申请已提交，是否要去完成提额小任务";
    self.BC012T000009 = @"做小任务，提升信用";
    self.BC012T000010 = @"●开启自动还款，系统将在订单到期日前一天自动扣款\n●仅支持借记卡还款";
    self.BC012T000012 = @"";//默认文案为空
    self.BC012T000013 = @"http://www.99-ss.com/billstore/public/index.php/wap/list.html?cat_id=25";
    self.BC012T000014 = @"推荐商品";
//    self.BC012T000016 = @"重要提示：使用快易花消费后请及时还款，避免逾期影响您的人行信用。";
    self.BC012T000018 = @"我要花钱";
    self.BC016T000001 = @"您的飞凡实体卡申请已被受理。卡片将于申请当日起10个工作日内送达您的申请地址。收到卡片后请及时绑卡，刷卡专享多种特权。如果您对收到实体卡有疑问，请联系客服：95069 或 400 615 5799";
    self.BC016T000002 = @"请设置系统的全局默认付款顺序：\n消费时将根据以下排列顺序扣款（飞凡卡消费暂不支持信用卡扣款）";
    self.BC016T000003 = @"{\"0\":\"是否保存本次更改\",\"1\":\"确定更改系统默认付款顺序么？\\n（注：飞凡卡消费暂不支持信用卡扣款）\"}";
    self.BC010T000001 = @"单账户日限额5万元，到账时效参考下表";
    self.BC010T000002 = @"普通转出无限额\n工作日12:00前转出，当日18:00前到账；其他时间转出，下个工作日18:00前到账";
    self.BC002T000001 = @"工作日提现将在3个工作日到账，遇节假日顺延";
    self.BC000T000010 = @"仅能验证大专以上学历，在读学校无法完成验证，请如实填写您的学历信息，每个自然月最多认证3次。";
    self.BC000T000011 = @"您目前的安全等级过低，为了您的账户安全更有保障，请完成更多身份认证";
    self.BC000T000037 = @"请如实填写您的驾照信息，每个自然月最多可认证3次。";
    self.BC000T000038 = @"请检查您的驾照信息是否正确，每个自然月最多可认证3次。";
    self.BC000T000014 = @"完成实名认证，体验高收益理财产品！";
    self.BC000T000005 = @"据央行规定，快钱已全面升级账户安全系统，请您至少完成下列%d项认证，保障您的账户安全！";
    self.BC000T000006 = @"快钱已经全面升级账户安全系统,为了账户更有安全保障,您还需要完成下列至少%d项认证。";
    self.BC000T000007 = @"可认证多家银行卡提高安全等级";
    self.BC000T000008 = @"仅支持国内大专及以上学历";
    self.BC000T000009 = @"背景简介、不要逆光、摘掉眼镜";
    self.BC000T000036 = @"补全驾照信息完成认证";
    self.BC000T000012 = @"快钱将一如既往保障您的账户安全,感谢您对我们的支持!";
    self.BC000T000042 = @"您已使用过快钱支付服务，可使用手机号直接登录";
    
    self.BC017T000001 = @"最高5万 最低月费率0.65%";
    self.BC017T000002 = @"6分钟极速放款";
    self.BC017T000003 = @"7天免息太给力";
    self.BC017T000008 = @"https://www.99bill.com/mobsup/notice/kuaisudai.html";
    
    self.BC900T000001 = @"信贷";
    self.BC900T000002 = @"理财";
    self.BC900T000003 = @"特惠";
    self.BC900T000004 = @"首页";
    self.BC900T000005 = @"信贷";
    self.BC900T000006 = @"理财";
    self.BC900T000007 = @"特惠";
    self.BC000T000035 = @"信用客服热线：400-6155-799 转 4";
    
    self.BC000T000015 = @"单笔50万，单日500万，免手续费";
    self.BC000T000016 = @"已起息的余额在募集期享受快利来收益";
    self.BC000T000017 = @"大额刷卡支付";
    self.BC000T000018 = @"8-16位字母、数字或特殊符号组合，区分大小写";
    self.BC000T000046 = @"8-16位字母、数字或特殊符号组合，区分大小写";
    self.BC011T000001 = @"近十日转让记录";
    self.BC011T000003 = @"请在%s 24:00前，使用此卡通过专业版网银、手机银行或柜台进行转账汇款";
    self.BC011T000004 = @"汇款后的下一工作日内";
    self.BC011T000005 = @"您可在交易明细或短信中查看汇款详情，如需帮助可咨询在线客服或拨打理财客服热线：";
    self.BC011T000006 = @"400-888-8888";
    self.BC011T000007 = @"转入成功即可购买固定期限产品，转入金额%s元及以上建议选择付款方式为转账汇款。";
    self.BC011T000008 = @"（大额转入建议转账汇款）";
    self.BC011T000009 = @"资金限额请咨询发卡银行";
    self.BC011T000010 = @"转入成功即可购买固定期限产品";
    self.BC011T000011 = @"确认订单，并于提交48小时内完成转账";
    self.BC011T000012 = @"推荐使用手机银行，可复制订单信息至银行APP\n仅限于以下银行卡进行转账";
    self.BC011T000014 = @"大额购买请提前转入快利来";
    self.BC011T000015 = @"您可在交易明细或短信中查看汇款详情，如需帮助可咨询在线客服或拨打理财客服热线：";
    self.BC011T000016 = @"转账完成，预计1个工作日内订单支付成功\n如购买失败，已支付款项预计5个工作日内退回原卡\n短信通知：转入成功后，系统自动发送短信通知\n自助查询：点击快钱刷首页-交易明细查询详情";
    self.BC011T000017 = @"收益发放当天到账";
    self.BC011T000018 = @"收益发放后3工作日内到账";
    self.BC011T000019 = @"转让被购买后1工作日内到账";
    self.BC011T000020 = @"转让被购买后4工作日内到账";
    self.BC000T000020 = @"登录密码与用户名不能相似";
    self.BC000T000019 = @"您可以登录官网www.99bill.com查看账户，或拨打400-615-5799寻求帮忙";
    self.BC000T000021 = @"400-615-5799";
    self.BC000T000022 = @"密码设置格式有误，请重新输入";
    
    self.BC000T000029 = @"快钱刷功能已升级，为确保您的账户安全，请补全职业信息和身份证照认证";
    self.BC000T000030 = @"取消后您可以到“我的>设置>账户详情”中完成相关操作";
    
    self.BC000T000024 = @"快钱刷功能已升级，为确保您的账户安全，请完成身份证照认证";
    self.BC000T000023 = @"取消后您可以到“我的>设置>账户详情>身份证照认证”中完成相关认证";
    
    self.BC000T000025 = @"快钱刷功能已升级，为确保您的账户安全，请补全职业信息";
    self.BC000T000026 = @"取消后您可以到“我的>设置>账户详情>职业”中完成信息补全";
    
    self.BC000T000028 = @"您的身份证照信息未通过审核或已过期，请重新进行认证";
    
    self.BC000T000027 = @"您在使用飞凡App时已自动生成快钱账号，为了保障您的账户安全，请通过“找回密码”设置您的快钱刷登录密码。";
    self.BC011T000002 = @"您购买的产品适合%s及以上投资者，超过了您的风险承受能力[%s]\n\n若您继续购买本产品，则视为您已认识并愿意承担可能存在的风险";
    self.BC000T000031 = @"账户年累计支付：是您使用快钱账户余额进行支付结算的年度总金额，不包含银行卡支付金额。（同一身份信息下所有快钱支付账户额度不可累计）";
    self.BC000T000032 = @"{\"0\":\"您尚未开通支付账户，上传身份证照并通过认证即可使用\",\"2\":\"您的支付账户暂时关闭，完成身份证照认证即可激活\"}";
    self.BC000T000033 = @"您尚未升级最新版本，无法使用扫码功能";
    self.BC000T000034 = @"输入金额：0~200000";
    self.BC000T000039 = @"《基础账户用户服务协议》和《快钱账户服务协议》";
    self.BC000T000040 = @"使用电脑访问www.99bill.com查询更多记录";
    self.BC000T000047 = @"此页面仅展示近一周记录";
    self.BC000T000041 = @"飞凡通卡";
    self.BC100T000001 = @"注册成功即享新手礼包";
    self.BC000P000008 = @"slogen_login";
    self.BC012T000015 = @"最高5万可分期";
    
    self.BC000T000043 = @"亲爱的用户，快钱刷升级啦，请您在AppStore中更新最新版本。";
    self.BC000T000044 = @"亲爱的用户，您所使用的已经是最新版本。";
    
    self.BC022T000001 = @"特惠返现";
    self.BC022T000002 = @"累计返现%s元";
    
    //3.0.3版本
    self.BC012T000019 = @"我要现金";
    self.BC012T000020 = @"请选择线下商户消费默认分期期数（扫一扫、付款码、飞凡卡交易）";
    self.BC012T000021 = @"1、申请快易花临时额度的客户在学尔森教育、乐浩教育、自立教育等指定商户消费时，可享受0手续费免息分期，详情请到店咨询；\n2、现金取现、信用卡代还费率以交易时显示的为准；\n3、商城消费分期费率见具体商品。";
    
    //3.1.0版本
    self.BC012T000022 = @"良好的还款记录有助于提升快易花额度，完善个人信用。请您注意还款时间，及时还款。";
    
    //3.1.3版本
    self.BC022T000003 = @"iPhone7";
    self.BC012T000023 = @"{\"1\":\"工作日\\n9:00-18:00\",\"2\":\"工作日\\n9:00-18:00\",\"3\":\"工作日\\n9:00-18:00\"}";
    
    //3.1.7版本
    self.BC012T000024 = @"";
    self.BC012T000025 = @"请确保您的还款卡余额充足";
    
    //5.2.2
    self.BC050T000001 = @"1. 贷记卡交易支持实时结算，智能收款模式实时结算不收费，店面收银模式实时结算收费（0.03%，最低0.2元，1元封顶）2．借记卡交易将会在T+1日为您结算（节假日顺延，工作日预计14点到账）";
    self.BC050T000002 = @"免提现手续费";
    self.BC050T000003 = @"免提现手续费";
    self.BC050T000004 = @""; // 默认为空
    self.BC050T000005 = @"套餐立减3元";
    self.BC050P000002 = @"";
    self.BC050T000006 = @"手续费默认使用贷记卡费率估算";
    self.BC050T000007 = @"00:00-23:00内的贷记卡交易支持实时结算";
    self.BC050T000008 = @"1.手续费=交易费率+提现费;默认贷记卡费率估算\n2.实时结算：支持交易时间在0:00-23:00的贷记卡交易\n3.不在0:00-23:00时间范围内的贷记卡交易与全部借记卡交易,将会在T+1日为您结算";
    self.BC050T000009 = @"6:00-23:00内的贷记卡交易支持实时结算，5分钟内到账";
    self.BC050T0000010 = @"工作日隔天到账，无提现费";
    self.BC050T000011 = @"设备换绑成功后，交易前请进入POS机管理菜单重新初始化！";
    self.BC050T000012 = @"";
    self.BC050T000014 = @"95069";
    
    self.BC050T000013 = @"";
    self.BC050T000015 = @"";
    self.BC050T000016 = @"温馨提示：\n1、需提前准备营业执照原件、经营者身份证原件\n2、营业执照要求清晰彩色、需年检章齐全（当年注册除外\n3、仅支持个体工商户或企业商户提交持有统一社会信用代码的营业执照认证注册\n4、天津市、大连市、宁波市、广西壮族自治区、宁夏回族自治区仅支持经营者本人申请认证\n注意：提交营业执照认证后，将只能使用店面收银模式交易，请谨慎提交！";
    self.BC050P000015 = @"";
    self.BC050P000015 = @"";
    self.BC050T000017 = @"开启后贷记卡刷卡、贷记卡银二、支付宝、微信支持实时结算，手续费费率0.03%（最低0.2元，1元封顶），但借记卡的交易仍按T+1日为您结算，不支持实时结算";
    self.BC050T000018 = @"温馨提示：\n1. 每类资质最少上传1张，最多上传5张图片\n2. 企业商户必须上传开户许可证或印鉴卡，个体工商户无需提交该资质。";
    self.BC050T000019 = @"银联云闪付：免密免签，挥卡交易，单笔最高限额1000元";
    self.BC050T000020 = @"";
    self.BC050T000021 = @"您可以先补齐门店照片，审核通过后，能够获得更高的额度~ 如已提交，请忽略";
}

- (void)loadCache{
    [super loadCache];
    if (!self.resDic) {
        self.resDic = [NSMutableDictionary dictionary];
    }
    [self updateData:self.resDic resId:nil resHome:nil];
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if (msgContent.count == 0) {
        [self initializeData];
        return;
    }
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
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
        
        if ([keyValue isEqualToString:@"OMS_TEXT_DELETED"]) {//快易花配置空文案
            [self setValue:@"" forKey:keyName];
            continue;
        }
        
        if ([keyName isEqualToString:@"BC016T000003"]) {
            [self setValue:keyValue forKey:keyName];
            continue;
        }
        [self setValue:[self replaceWrapperWord:keyValue] forKey:keyName];
    }
    [KQBCacheManager saveObject:msgContent cacheType:KQCacheTypeDescription];
}

- (NSString *)replaceWrapperWord:(NSString *)srcStr{
    return [srcStr stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    DLog(@"KQDescriptionManager do not have key:%@", key);
}

- (KQBResManagerType)omsResType{
    return  KQBResManagerTypeDescription;
}
@end
