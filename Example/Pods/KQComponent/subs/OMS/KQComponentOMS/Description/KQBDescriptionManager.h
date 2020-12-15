//
//  KQDescriptionManager.h
//  kuaiQianbao
//
//  Created by xy on 15/12/19.
//
//

#import <Foundation/Foundation.h>
#import "KQBBaseOmsResManager.h"


#define DescriptionManager  [KQBDescriptionManager sharedManager]

@interface KQBDescriptionManager : KQBBaseOmsResManager

@property (nonatomic, strong) NSString *BC012T000001;   // 信用_快易花还款设置页面 第一块
@property (nonatomic, strong) NSString *BC012T000002;   // 信用_快易花还款设置页面 第二块
@property (nonatomic, strong) NSString *BC012T000003;   // 智慧身份认证说明
@property (nonatomic, strong) NSString *BC012T000005;   // 信用_快易花申请确认页面 分期介绍文案
@property (nonatomic, strong) NSString *BC012T000006;   // 提额_更多_提额Tips入口文案
@property (nonatomic, strong) NSString *BC012T000007;   // 等待受理界面新增提额弹窗提醒文案
@property (nonatomic, strong) NSString *BC012T000009;   // 快易花提额助手按钮文案
@property (nonatomic, strong) NSString *BC012T000010;   // 自动还款银行卡设置页面说明文案
@property (nonatomic, strong) NSString *BC012T000012;   // 信用_快易花设置页面 默认分期下方预留文案
@property (nonatomic, strong) NSString *BC012T000013;   // 信用_快易花额度首页商品更多跳转链接
@property (nonatomic, strong) NSString *BC012T000014;   // 信用_快易花额度首页商品header名称
@property (nonatomic, strong) NSString *BC012T000016;   // 信用_额度首页重要提示文案
@property (nonatomic, strong) NSString *BC012T000018;   // 信用_额度首页场景分期标题
@property (nonatomic, strong) NSString *BC016T000001;   // 万达飞凡卡申领成功提示文案
@property (nonatomic, strong) NSString *BC016T000002;   // 默认付款顺序页面上端提示文案
@property (nonatomic, strong) NSString *BC016T000003;   // 默认付款顺序页面点击确定按钮弹得弹框提示文案
@property (nonatomic, strong) NSString *BC010T000001;   // 快利来快速转出说明文案
@property (nonatomic, strong) NSString *BC010T000002;   // 快利来普通转出说明文案
@property (nonatomic, strong) NSString *BC002T000001;   // 余额提现说明文案
@property (nonatomic, strong) NSString *BC000T000010;   // 学历认证页上方
@property (nonatomic, strong) NSString *BC000T000011;   // 学历认证成功页
@property (nonatomic, strong) NSString *BC000T000037;   // 驾照认证页上方
@property (nonatomic, strong) NSString *BC000T000038;   // 驾照认证失败弹窗
@property (nonatomic, strong) NSString *BC000T000014;   // 我的实名认证悬浮框提示
@property (nonatomic, strong) NSString *BC000T000005;   // 设置-身份认证首页顶部
@property (nonatomic, strong) NSString *BC000T000006;   // 首页账户升级弹框顶部
@property (nonatomic, strong) NSString *BC000T000007;   // 首页账户升级弹框绑卡
@property (nonatomic, strong) NSString *BC000T000008;   // 首页账户升级弹框学历认证
@property (nonatomic, strong) NSString *BC000T000009;   // 首页账户升级弹框人脸识别
@property (nonatomic, strong) NSString *BC000T000036;   // 首页账户升级弹框驾照识别
@property (nonatomic, strong) NSString *BC000T000012;   // 账户升级成功提示
@property (nonatomic, strong) NSString *BC017T000001;   // 快易还入口 介绍文案
@property (nonatomic, strong) NSString *BC017T000002;   // 快速贷入口 介绍文案
@property (nonatomic, strong) NSString *BC017T000003;   // 快逸贷入口 介绍文案
@property (nonatomic, strong) NSString *BC017T000008;   // 快速贷跳转链接
@property (nonatomic, strong) NSString *BC000T000002;   // mPos操作员
@property (nonatomic, strong) NSString *BC000T000003;   // mPos收单机构
@property (nonatomic, strong) NSString *BC000T000004;   // mPos批次号
@property (nonatomic, strong) NSString *BC000T000015;   // mPos支付弹窗大额支付说明
@property (nonatomic, strong) NSString *BC000T000016;   // mPos支付弹窗快利来余额说明
@property (nonatomic, strong) NSString *BC000T000017;   // mPos支付弹窗大额支付标题
@property (nonatomic, strong) NSString *BC000T000018;   // 注册短信验证码页面话术
@property (nonatomic, strong) NSString *BC000T000042;   //关联卡用户注册提示话术
@property (nonatomic, strong) NSString *BC000T000046;   // 注册短信验证码页面话术
@property (nonatomic, strong) NSString *BC900T000001;   // TAB-信用的NavTitle
@property (nonatomic, strong) NSString *BC900T000002;   // TAB-理财的NavTitle
@property (nonatomic, strong) NSString *BC900T000003;   // TAB-特惠的NavTitle
@property (nonatomic, strong) NSString *BC900T000004;   // TAB-首页底部的Title
@property (nonatomic, strong) NSString *BC900T000005;   // TAB-信用底部的Title
@property (nonatomic, strong) NSString *BC900T000006;   // TAB-理财底部的Title
@property (nonatomic, strong) NSString *BC900T000007;   // TAB-特惠底部的Title
@property (nonatomic, strong) NSString *BC000T000035;   // 信用频道最下方客服电话
@property (nonatomic, strong) NSString *BC011T000001;   // 理财转让纪录
@property (nonatomic, strong) NSString *BC011T000003;   // 线下汇款-汇款时间提示文案
@property (nonatomic, strong) NSString *BC011T000004;   // 线下汇款-预计收益到账提示文案
@property (nonatomic, strong) NSString *BC011T000005;   // 线下汇款-进度查询提示文案
@property (nonatomic, strong) NSString *BC011T000006;   // 线下汇款-进度查询客服电话
@property (nonatomic, strong) NSString *BC011T000007;   // 线下汇款-快利来转入页提示
@property (nonatomic, strong) NSString *BC011T000008;   // 线下汇款-快利来转入页上方提示（3.0.0版之后）
@property (nonatomic, strong) NSString *BC011T000009;   // 线下汇款-快利来转入页支付方式提示（3.0.0版之后）
@property (nonatomic, strong) NSString *BC011T000010;   // 线下汇款-快利来转入页下方提示（3.0.0版之后）
@property (nonatomic, strong) NSString *BC011T000011;   // 线下汇款-汇款时间提示文案（3.0.0版之后）
@property (nonatomic, strong) NSString *BC011T000012;   // 线下汇款-银行转账下方提示（3.0.0版之后）
@property (nonatomic, strong) NSString *BC011T000014;   // 理财-购买定期-上方提示  （3.0.0版之后）
@property (nonatomic, strong) NSString *BC011T000015;   // 线下汇款确认页－进度查询（3.0.0版之后）
@property (nonatomic, strong) NSString *BC011T000016;   // 线下汇款确认页－启动APP按钮下方  （3.0.0版之后）
@property (nonatomic, strong) NSString *BC011T000017;   // 本息发放至快利来到账时间文案-认购时或持有中
@property (nonatomic, strong) NSString *BC011T000018;   // 本息发放至银行卡到账时间文案-认购时或持有中
@property (nonatomic, strong) NSString *BC011T000019;   // 本息发放至快利来到账时间文案-转让
@property (nonatomic, strong) NSString *BC011T000020;   // 本息发放至银行卡到账时间文案-转让

@property (nonatomic, strong) NSString *BC000T000020;   // 登录密码错误提示 注册设置，忘记，重置登录密码
@property (nonatomic, strong) NSString *BC000T000019;   // 提示拨打客服电话弹窗
@property (nonatomic, strong) NSString *BC000T000021;   // 拨打客服电话号码
@property (nonatomic, strong) NSString *BC000T000022;   // 登录密码错误tost提示

@property (nonatomic, strong) NSString *BC000T000027;   // 统一账户快钱客户端对接注册提示语 静默注册


@property (nonatomic, strong) NSString *BC000T000029;   // 首页认证弹框提示语：均未上传
@property (nonatomic, strong) NSString *BC000T000030;   // 首页认证二次弹框提示语：均未上传

@property (nonatomic, strong) NSString *BC000T000024;   // 首页认证弹框提示语：身份证未上传
@property (nonatomic, strong) NSString *BC000T000023;   // 首页认证二次弹框提示语：身份证

@property (nonatomic, strong) NSString *BC000T000025;   // 首页认证弹框提示语：职业未上传
@property (nonatomic, strong) NSString *BC000T000026;   // 首页认证二次弹框提示语：职业

@property (nonatomic, strong) NSString *BC000T000028;   // 首页认证弹框提示语 身份证上传失败

@property (nonatomic, strong) NSString *BC011T000002;   // 理财产品－用户风险测评需求

@property (nonatomic, strong) NSString *BC000T000031;   // 账户详情：账户年累计支付
@property (nonatomic, strong) NSString *BC000T000032;   // 支付账户状态悬浮窗文案
@property (nonatomic, strong) NSString *BC000T000033;   // c扫b老版本扫描不支持的快钱二维码时的提示文案
@property (nonatomic, strong) NSString *BC000T000034;   // c扫b静态码金额输入页，金额输入框下方
@property (nonatomic, strong) NSString *BC000T000039;   // 注册协议名称
@property (nonatomic, strong) NSString *BC000T000040;   // 交易详情－账单最下方提示
@property (nonatomic, strong) NSString *BC000T000047;   // 交易详情－账单最下方提示
@property (nonatomic, strong) NSString *BC000T000041;   // 交易明细－飞凡通卡文案
@property (nonatomic, strong) NSString *BC000P000008;   // 首页logo图标
@property (nonatomic, copy)   NSString *BC100T000001;     // 新手注册送礼包的提示语言
@property (nonatomic, strong) NSString *BC012T000015;   // 快易花宣传语

@property (nonatomic, copy)   NSString *BC000T000043;   // 快钱刷非最新版的提示文案
@property (nonatomic, copy)   NSString *BC000T000044;   // 快钱刷已经是最新版的提示文案

@property (nonatomic, copy)   NSString *BC022T000001;   // 位置：首页-特惠区块 内容：特惠返现
@property (nonatomic, copy)   NSString *BC022T000002;   // 位置：首页-特惠区块 内容：累计返现%s元

//3.0.3版本
@property (nonatomic, strong) NSString *BC012T000019;   // 快易花首页我要现金标题
@property (nonatomic, strong) NSString *BC012T000020;   // 快易花分期方式设置页面上方文案
@property (nonatomic, strong) NSString *BC012T000021;   // 快易花分期方式设置页面下方文案

//3.1.0版本
@property (nonatomic, strong) NSString *BC012T000022;   // 快易花星期贷设置页面下方文案

//3.1.3版本
@property (nonatomic, copy)   NSString *BC022T000003;   // 位置：特惠-搜索默认文案 内容：iPhone7

//3.1.6版本
@property (nonatomic, copy) NSString *BC012T000023;     // 视频认证提示页服务开启时间文案配置 1为身份认证 2为快易花

//3.1.7版本
@property (nonatomic, strong) NSString *BC012T000024;   // 快易花还款页面跑马灯文案
@property (nonatomic, strong) NSString *BC012T000025;   // 快易花还款页面支付方式下端文案提示
//5.2.2
@property (nonatomic, copy) NSString *BC050T000001;     //商户收款模块顶部文字
@property (nonatomic, copy) NSString *BC050T000002;     //云闪付小额双免顶部文字
@property (nonatomic, copy) NSString *BC050T000003;     //云闪付二维码收款顶部文字
@property (nonatomic, copy) NSString *BC050T000004;     //设备绑定成功页面
// 5.2.7
@property (nonatomic, copy) NSString *BC050T000005;     // 未购买套餐用户展示“购买套餐，立减3元”
@property (nonatomic, copy) NSString *BC050P000002;     // 移动POS底部图片

// 5.2.8
@property (nonatomic, copy) NSString *BC050T000006;     // 刷卡收款页手续费提示文案
@property (nonatomic, copy) NSString *BC050T000007;     // 刷卡收款页结算方式提示文案
@property (nonatomic, copy) NSString *BC050T000008;     // 刷卡收款页注意事项
@property (nonatomic, copy) NSString *BC050T000009;     // 刷卡收款页到账方式-S0描述信息
@property (nonatomic, copy) NSString *BC050T0000010;    // 刷卡收款页到账方式-T1描述信息

// 5.3.0
@property (nonatomic, copy) NSString *BC050T000011;      // 大pos 换绑提示

// 5.3.1
@property (nonatomic, copy) NSString *BC050T000012;      // APP增加系统公告弹窗(快钱刷用户点击商户收款，APP显示系统公告弹窗)
@property (nonatomic, copy) NSString *BC050T000014;      // 联系客服电话

// 5.3.2
@property (nonatomic, copy) NSString *BC050T000013;      // 未提交正规商户申请状态时
@property (nonatomic, copy) NSString *BC050T000015;      // 人工审核成功状态时
@property (nonatomic, copy) NSString *BC050T000016;      // 营业执照介绍页温馨提示文案（防止仅支持经营者本人城市更新
@property (nonatomic, copy) NSString *BC050P000015;      // APP增加系统公告弹窗(快钱刷用户点击商户收款，APP显示系统公告弹窗)图片

@property (nonatomic, copy) NSString *BC050T000017;      // 店面收银结算设置描述

@property (nonatomic, copy) NSString *BC050T000018;      // 上传门头照温馨提示
@property (nonatomic, copy) NSString *BC050T000019;      // 银联云闪付注意事项
@property (nonatomic, copy) NSString *BC050T000020;      // 二维码收款注意事项
@property (nonatomic, copy) NSString *BC050T000021;      // APP申请受理中和审核成功上传门头照
+ (KQBDescriptionManager *)sharedManager;

@end
