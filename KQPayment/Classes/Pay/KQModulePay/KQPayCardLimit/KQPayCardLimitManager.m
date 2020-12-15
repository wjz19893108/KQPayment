//
//  KQPayCardLimitManager.m
//  kuaiQianbao
//
//  Created by zouf on 16/3/7.
//
//

#import "KQPayCardLimitManager.h"

@interface KQPayCardLimitManager ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *cardLimitDic;    //[bankId][cardType][productCode]

@end

@implementation KQPayCardLimitManager

SYNTHESIZE_SINGLETON_FOR_CLASS(KQPayCardLimitManager);


- (id)init{
    self = [super init];
    if (self) {
        self.cardLimitDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)findCardLimitObj:(NSString* __nullable)bankId cardType:(NSString* __nullable)cardType productCode:(NSString* __nullable)productCode completion:(FindCardLimit __nullable)findCardLimitBlock
{
    if (([NSString kqc_isBlank:bankId])||([NSString kqc_isBlank:cardType])||([NSString kqc_isBlank:productCode])) {
        if (findCardLimitBlock) {
            findCardLimitBlock(nil);
        }
    }
    KQPayCardLimitData *data = [self searchCardLimitObj:bankId cardType:cardType productCode:productCode];
    if (!data) {
        //验证密码
        NSDictionary *m237Dic = @{@"bankId":bankId,
                                  @"cardType":cardType,
                                  @"productCode":productCode};
        __weak typeof(&*self) weakSelf = self;
        [KQHttpService request:m237Dic bizType:@"M237" successBlock:^(Content *response) {
            [response.bankLimitAmountDto enumerateObjectsUsingBlock:^(ContentBankLimitAmountDto*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                KQPayCardLimitData *pdata = [KQPayCardLimitData getPayCardLimitDataFromObj:obj];
                if (pdata) {
                    [weakSelf insertCardLimitObj:pdata];
                }
            }];
            KQPayCardLimitData *fdata = [weakSelf searchCardLimitObj:bankId cardType:cardType productCode:productCode];
            if (findCardLimitBlock) {
                findCardLimitBlock(fdata);
            }
        } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
            [KQBToastView show:errorMessage];
            if (findCardLimitBlock) {
                findCardLimitBlock(nil);
            }
        }];
    }
    else {
        if (findCardLimitBlock) {
            findCardLimitBlock(data);
        }
    }
}

- (KQPayCardLimitData*)searchCardLimitObj:(NSString* __nullable)bankId cardType:(NSString* __nullable)cardType productCode:(NSString* __nullable)productCode
{
    if (([NSString kqc_isBlank:bankId])||([NSString kqc_isBlank:cardType])||([NSString kqc_isBlank:productCode])) {
        return nil;
    }
    NSMutableDictionary *bankIdDic = [self.cardLimitDic objectForKey:bankId];
    if (!bankIdDic) {
        bankIdDic = [NSMutableDictionary dictionary];
        [self.cardLimitDic setObject:bankIdDic forKey:bankId];
    };
    NSMutableDictionary *cardTypeDic = [bankIdDic objectForKey:cardType];
    if (!cardTypeDic) {
        cardTypeDic = [NSMutableDictionary dictionary];
        [bankIdDic setObject:cardTypeDic forKey:cardType];
    }
    KQPayCardLimitData *data = [cardTypeDic objectForKey:productCode];
    return data;
}

- (void)insertCardLimitObj:(KQPayCardLimitData*)obj
{
    NSMutableDictionary *bankIdDic = [self.cardLimitDic objectForKey:obj.bankId];
    if (!bankIdDic) {
        bankIdDic = [NSMutableDictionary dictionary];
        [self.cardLimitDic setObject:bankIdDic forKey:obj.bankId];
    };
    NSMutableDictionary *cardTypeDic = [bankIdDic objectForKey:obj.cardType];
    if (!cardTypeDic) {
        cardTypeDic = [NSMutableDictionary dictionary];
        [bankIdDic setObject:cardTypeDic forKey:obj.cardType];
    }
    [cardTypeDic setObject:obj forKey:obj.productCode];
}

@end
