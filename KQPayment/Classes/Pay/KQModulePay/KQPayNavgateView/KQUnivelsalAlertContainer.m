//
//  KQUnivelsalAlertContainer.m
//  kuaiQianbao
//
//  Created by zouf on 16/7/19.
//
//

#import "KQUnivelsalAlertContainer.h"

@interface KQUnivelsalAlertContainer ()

@property (nonatomic, strong) NSHashTable * hashTable;

@end

@implementation KQUnivelsalAlertContainer

SYNTHESIZE_SINGLETON_FOR_CLASS(KQUnivelsalAlertContainer);

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return self;
}

- (void)dismissAllUnivelsalAlert {
    @synchronized (@"KQUnivelsalAlertContainer") {
        NSEnumerator * enumerator = [self.hashTable objectEnumerator];
        id value;
        while (value = [enumerator nextObject]) {
            if ([value isKindOfClass:[UIAlertView class]]) {
                [(UIAlertView *)value dismissWithClickedButtonIndex:[(UIAlertView *)value cancelButtonIndex] animated:NO];
            }
        }
        [self.hashTable removeAllObjects];
    }
}

- (void)addUIAlertView:(UIAlertView * __nonnull)alertView {
    @synchronized (@"KQUnivelsalAlertContainer") {
        [self.hashTable addObject:alertView];
    }
}

@end
