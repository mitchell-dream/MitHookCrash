//
//  NSDictionary+MitCrash.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSDictionary+MitCrash.h"
#import "NSObject+MethodSwizz.h"
#import "MitCrashHandler.h"
@implementation NSDictionary (MitCrash)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzleMethod:NSClassFromString(@"__NSDictionaryI") origin:@selector(objectForKey:) new:@selector(MitCrash_objectForKey:)];
    });
}

#pragma mark action 移除 key
- (id)MitCrash_objectForKey:(id)aKey{
    if (!aKey) {
        [MitCrashHandler handleCrashCls:[self class] message:@"没有 aKey" sel:_cmd];
        return nil;
    } else {
        return [self MitCrash_objectForKey:aKey];
    }
}



@end
