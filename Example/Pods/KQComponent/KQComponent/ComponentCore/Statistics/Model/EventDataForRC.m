//
//  EventDataForRC.m
//  kuaiQianbao
//
//  Created by lihui on 16/5/16.
//
//

#import "EventDataForRC.h"

@implementation EventDataForRC

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.eventId forKey:@"eventId"];
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.time forKey:@"time"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.eventId = [aDecoder decodeObjectForKey:@"eventId"];
        self.deviceId = [aDecoder decodeObjectForKey:@"deviceId"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
    }
    return self;
}

- (instancetype)initWithEventId:(NSString *)eventId deviceInfo:(DeviceInfoData *)deviceInfo{
    self = [super init];
    if (self){
        self.eventId = eventId;
        self.deviceId = deviceInfo.deviceId;
        self.time = [KQCDate dateFormat:[NSDate date] destFormat:KQDateFormatAccurateMillisecondWithSpace];
    }
    return self;
}
@end
