//
//  NSNotificationCenter+MitCrash.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSNotificationCenter+MitCrash.h"
#import "NSObject+MethodSwizz.h"
#import "MitCrashHandler.h"
@implementation NSNotificationCenter (MitCrash)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzleMethod:[self class] origin:@selector(addObserver:selector:name:object:) new:@selector(MitCrash_addObserver:selector:name:object:)];

    });
}


- (void)MitCrash_addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject{
    [self MitCrash_addObserver:observer selector:aSelector name:aName object:anObject];
    if ([self conformsToProtocol:@protocol(MitCrashNotifyDelegate)]) {
        [[MitCrashHandler sharedManager].NotiMaps setValue:anObject forKey:[NSString stringWithFormat:@"%@%@%@",observer,NSStringFromSelector(aSelector),aName]];
    }
}

@end
