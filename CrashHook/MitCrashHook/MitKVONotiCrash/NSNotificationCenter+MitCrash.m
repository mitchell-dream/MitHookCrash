//
//  NSNotificationCenter+MitCrash.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSNotificationCenter+MitCrash.h"
#import "NSObject+MitCrashSwizz.h"
#import "MitCrashHandler.h"
#import "MitCrashConfig.h"
@implementation NSNotificationCenter (MitCrash)

+ (void)load{
    //通知
    if ([[MITCRASHMANAGER.handleConfig objectForKey:MitCrash_NOTI_KEY] boolValue]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSObject swizzleMethod:[self class] origin:@selector(addObserver:selector:name:object:) new:@selector(MitCrash_addObserver:selector:name:object:)];
        });
    }
}


#pragma mark action 添加观察者
- (void)MitCrash_addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject{
    [self MitCrash_addObserver:observer selector:aSelector name:aName object:anObject];
    if ([self conformsToProtocol:@protocol(MitCrashNotifyDelegate)]) {
        [[MitCrashHandler sharedManager].NotiMaps setValue:anObject forKey:[NSString stringWithFormat:@"%@%@%@",observer,NSStringFromSelector(aSelector),aName]];
    }
}

@end
