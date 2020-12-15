//
//  KQKeychain.m
//  kuaishua
//
//  Created by LiuBin on 14-7-28.
//
//

#import "KQCKeychain.h"

@implementation KQCKeychain

static NSString *KQC_APP_IN_KEYCHAIN_KEY = nil;
static NSMutableDictionary *KQC_KEYCHAIN_DIC = nil;

+ (void)initializeConfig:(NSString *)key{
    KQC_APP_IN_KEYCHAIN_KEY = KQC_FORMAT(@"%@.%@", [[NSBundle mainBundle] bundleIdentifier], @"allinfo");
    KQC_KEYCHAIN_DIC = [KQCKeychain load:KQC_APP_IN_KEYCHAIN_KEY];
    
    if (!KQC_KEYCHAIN_DIC && ![NSString kqc_isBlank:key]) {
        NSString *tempKey = KQC_FORMAT(@"%@.%@", key, @"allinfo");
        KQC_KEYCHAIN_DIC = [KQCKeychain load:tempKey];
    }
    
    if (!KQC_KEYCHAIN_DIC) {
        KQC_KEYCHAIN_DIC = [[NSMutableDictionary alloc] init];
        [KQCKeychain save:KQC_APP_IN_KEYCHAIN_KEY data:KQC_KEYCHAIN_DIC];
    }
}

+ (id)loadValue:(NSString *)key{
    if ([NSString kqc_isBlank:key]) {
        DLog(@"key is nil when load key chain");
        return nil;
    }
    
    return KQC_KEYCHAIN_DIC[key];
}

+ (void)saveValue:(id)data key:(NSString *)key{
    if ([NSString kqc_isBlank:key]) {
        DLog(@"key is nil when save key chain");
        return;
    }
    
    if (!data) {
        [KQCKeychain deleteValue:key];
        return;
    }
    
    KQC_KEYCHAIN_DIC[key] = data;
    [KQCKeychain save:KQC_APP_IN_KEYCHAIN_KEY data:KQC_KEYCHAIN_DIC];
}

+ (void)deleteValue:(NSString *)key{
    if ([NSString kqc_isBlank:key]) {
        DLog(@"key is nil when save key chain");
        return;
    }
    
    [KQC_KEYCHAIN_DIC removeObjectForKey:key];
    [KQCKeychain save:KQC_APP_IN_KEYCHAIN_KEY data:KQC_KEYCHAIN_DIC];
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            service, (__bridge_transfer id)kSecAttrService,
            service, (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            DLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
}  
@end
