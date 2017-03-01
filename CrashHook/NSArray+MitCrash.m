//
//  NSArray+MitCrash.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSArray+MitCrash.h"
#import "NSObject+MethodSwizz.h"
#import "MitCrashHandler.h"
@implementation NSArray (MitCrash)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzleMethod:NSClassFromString(@"__NSArrayI") origin:@selector(objectAtIndex:) new:@selector(MitCrash_objectAtIndex:)];

    });
}

#pragma mark action 获取第几个元素
- (id)MitCrash_objectAtIndex:(NSUInteger)index{
    if (index > self.count-1) {
        [MitCrashHandler handleCrashCls:[self class] message:@"数组越界" sel:_cmd];
        return nil;
    } else {
        return [self MitCrash_objectAtIndex:index];
    }
}







@end
