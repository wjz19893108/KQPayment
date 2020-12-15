//
//  KQBUserInfo.m
//  KQBusiness
//
//  Created by xy on 2016/10/24.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBUserInfo.h"

NSNotificationName const KQBUserSignOutNotification = @"UserSignOutNotification";
NSNotificationName const KQBUserNeedLoginInNotification = @"UserNeedLoginInNotification";

@implementation KQBUserInfo

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(self.faceAuthorizationStatus) forKey:@"faceAuthorizationStatus"];
    [aCoder encodeObject:self.securityQuestion forKey:@"securityQuestion"];
    [aCoder encodeObject:@(self.isRealName) forKey:@"isRealName"];
    [aCoder encodeObject:@(self.isBindPhone) forKey:@"isBindPhone"];
    [aCoder encodeObject:self.userMebCode forKey:@"userMebCode"];
    [aCoder encodeObject:self.identitycardid forKey:@"identitycardid"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.phoneNo forKey:@"phoneNo"];
    [aCoder encodeObject:self.loginToken forKey:@"loginToken"];
    [aCoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:@(self.isTouchIdPayTipped) forKey:@"isTouchIdPayTipped"];
    [aCoder encodeObject:@(self.isExistPayPassword) forKey:@"isExistPayPassword"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        // 仅保存这些需要这些
        self.faceAuthorizationStatus = [[aDecoder decodeObjectForKey:@"faceAuthorizationStatus"] integerValue];
        self.securityQuestion = [aDecoder decodeObjectForKey:@"securityQuestion"];
        self.isRealName = [[aDecoder decodeObjectForKey:@"isRealName"] boolValue];
        self.isBindPhone = [[aDecoder decodeObjectForKey:@"isBindPhone"] boolValue];
        self.userMebCode = [aDecoder decodeObjectForKey:@"userMebCode"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.identitycardid = [aDecoder decodeObjectForKey:@"identitycardid"];
        self.phoneNo = [aDecoder decodeObjectForKey:@"phoneNo"];
        self.loginToken = [aDecoder decodeObjectForKey:@"loginToken"];
        self.refreshToken = [aDecoder decodeObjectForKey:@"refreshToken"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.isTouchIdPayTipped = [[aDecoder decodeObjectForKey:@"isTouchIdPayTipped"] boolValue];
        self.isExistPayPassword = [[aDecoder decodeObjectForKey:@"isExistPayPassword"] boolValue];
    }
    return self;
}

- (NSString *)displayAccount{
    NSString *phoneNo = self.phoneNo;
    if (phoneNo.length > 7) {
        phoneNo = [NSString stringWithFormat:@"%@****%@", [phoneNo substringToIndex:3], [phoneNo substringFromIndex:7]];
        return phoneNo;
    }
    
    NSString *email = self.email;
    if ([NSString kqc_isBlank:email]) {
        return nil;
    }
    
    NSUInteger index = [email rangeOfString:@"@"].location;
    if (index == NSNotFound) {
        return nil;
    }
    
    NSMutableString *acValue;
    if (index > 4) {
        acValue = [NSMutableString stringWithString:[email substringToIndex:3]];
        for (int i = 3; i < index -1; i++) {
            [acValue appendString:@"*"];
        }
        [acValue appendString:[email substringFromIndex:index-1]];
        return acValue;
    } else {
        return email;
    }
}

- (void)dealloc{
//    DLog(@"%@ dealloc", self);
}

@end
