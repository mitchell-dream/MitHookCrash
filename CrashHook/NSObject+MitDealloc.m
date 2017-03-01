//
//  NSObject+MitDealloc.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+MitDealloc.h"
#import "NSObject+MethodSwizz.h"
#import "MitCrashHandler.h"
@implementation NSObject (MitDealloc)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzleMethod:[self class] origin:NSSelectorFromString(@"dealloc") new:@selector(MitCrash_dealloc)];

    });
}

- (void)MitCrash_dealloc{
    
    if ([self conformsToProtocol:@protocol(MitCrashKVODelegate)]) {
        //KVO 防护
        if ([MitCrashHandler sharedManager].KVOHashMaps.count > 0) {
            [[MitCrashHandler sharedManager].KVOHashMaps removeAllObjects];
        }
    }
    if ([self conformsToProtocol:@protocol(MitCrashNotifyDelegate)]) {
        //Notification 防护
        if ([MitCrashHandler sharedManager].NotiMaps.count>0) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [[MitCrashHandler sharedManager].NotiMaps removeAllObjects];
        }
    }

    [self MitCrash_dealloc];
}

@end
