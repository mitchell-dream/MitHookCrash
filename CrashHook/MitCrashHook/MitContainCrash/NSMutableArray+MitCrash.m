//
//  NSMutableArray+MitCrash.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSMutableArray+MitCrash.h"
#import "NSObject+MitCrashSwizz.h"
#import "MitCrashHandler.h"
#import "MitCrashConfig.h"
@implementation NSMutableArray (MitCrash)
+ (void)load{
    //container
    if ([[MITCRASHMANAGER.handleConfig objectForKey:MitCrash_CONTAIN_KEY] boolValue]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            //取
            [NSObject swizzleMethod:NSClassFromString(@"__NSArrayM") origin:@selector(objectAtIndex:) new:@selector(MitCrash_objectAtIndex:)];
            //增
            [NSObject swizzleMethod:NSClassFromString(@"__NSArrayM") origin:@selector(addObject:) new:@selector(MitCrash_addObject:)];
            //插入
            [NSObject swizzleMethod:NSClassFromString(@"__NSArrayM") origin:@selector(insertObject:atIndex:) new:@selector(MitCrash_insertObject:atIndex:)];
            //替换
            [NSObject swizzleMethod:NSClassFromString(@"__NSArrayM") origin:@selector(replaceObjectAtIndex:withObject:) new:@selector(MitCrash_replaceObjectAtIndex:withObject:)];
        });
    }



}

#pragma mark action 获取
- (id)MitCrash_objectAtIndex:(NSUInteger)index{
    if (self.count-1<index) {
        [MitCrashHandler handleCrashCls:[self class] message:@"数组越界" sel:_cmd];
        return nil;
    } else {
        return [self MitCrash_objectAtIndex:index];
    }
}


#pragma mark action 增
- (void)MitCrash_addObject:(id)anObject{
    if (!anObject) {
        [MitCrashHandler handleCrashCls:[self class] message:@"插入元素为空" sel:_cmd];
        return;
    } else {
        [self MitCrash_addObject:anObject];
    }
}

#pragma mark action 插入
- (void)MitCrash_insertObject:(id)anObject atIndex:(NSUInteger)index{
    if (index>self.count) {
        [MitCrashHandler handleCrashCls:[self class] message:@"越界" sel:_cmd];
        return;
    }
    if (!anObject) {
        [MitCrashHandler handleCrashCls:[self class] message:@"没有元素" sel:_cmd];
        return;
    }
    [self MitCrash_insertObject:anObject atIndex:index];
}


#pragma mark action 替换
- (void)MitCrash_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    if (index>=self.count) {
        [MitCrashHandler handleCrashCls:[self class] message:@"越界" sel:_cmd];
        return;
    }
    if (!anObject) {
        [MitCrashHandler handleCrashCls:[self class] message:@"没有元素" sel:_cmd];
        return;
    }
    
    [self MitCrash_replaceObjectAtIndex:index withObject:anObject];    
}

@end
