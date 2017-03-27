//
//  NSMutableDictionary+MitCrash.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSMutableDictionary+MitCrash.h"
#import "MitCrashHandler.h"
#import "NSObject+MitCrashSwizz.h"
#import "MitCrashConfig.h"


@implementation NSMutableDictionary (MitCrash)
+ (void)load{
    
    //container
    if ([[MITCRASHMANAGER.handleConfig objectForKey:MitCrash_CONTAIN_KEY] boolValue]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSObject swizzleMethod:NSClassFromString(@"__NSDictionaryM") origin:@selector(setValue:forKey:) new:@selector(MitCrash_setValue:forKey:)];
            [NSObject swizzleMethod:NSClassFromString(@"__NSDictionaryM") origin:@selector(setObject:forKey:) new:@selector(MitCrash_setObject:forKey:)];
        });
    }
}

-(void)MitCrash_setValue:(id)value forKey:(NSString *)key{
    
    if (!key) {
        [MitCrashHandler handleCrashCls:[self class] message:@"没有 key" sel:_cmd];
    }else{
        [self MitCrash_setValue:value forKey:key];
    }
}
-(void)MitCrash_setObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (!anObject) {
        [MitCrashHandler handleCrashCls:[self class] message:@"没有 obj" sel:_cmd];
        return;
    }
    if (!aKey) {
        [MitCrashHandler handleCrashCls:[self class] message:@"没有 key" sel:_cmd];
        return;
    }
    [self MitCrash_setObject:anObject forKey:aKey];
}




@end
