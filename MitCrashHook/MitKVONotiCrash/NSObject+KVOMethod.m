//
//  NSObject+KVOMethod.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/2/27.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+KVOMethod.h"
#import "NSObject+MitCrashSwizz.h"
#import "MitCrashHandler.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
@implementation NSObject (KVOMethod)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //添加观察者
        [NSObject swizzleMethod:[self class] origin:@selector(addObserver:forKeyPath:options:context:) new:@selector(mitCrash_addObserver:forKeyPath:options:context:)];
        //移除观察者
        [NSObject swizzleMethod:[self class] origin:@selector(removeObserver:forKeyPath:) new:@selector(mitCrash_removeObserver:forKeyPath:)];
    });

}
#pragma mark action 添加观察者
-(void)mitCrash_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    NSString * key = [NSString stringWithFormat:@"%@%@",observer,keyPath];
    if ([[MitCrashHandler sharedManager].KVOHashMaps objectForKey:key]!=nil) {
        [MitCrashHandler handleCrashCls:[self class] message:[NSString stringWithFormat:@"重复添加观察者：%@%@",observer,keyPath] sel:_cmd];
        
    } else if([[observer class] conformsToProtocol:@protocol(MitCrashKVODelegate)]) {
        id con;
        if (context) {
            con = (__bridge id)(context);
        }else{
            con = @"nil";
        }
        NSDictionary * dict = @{@"observer":observer,@"keyPath":keyPath,@"options":@(options),@"context":con};
        [[MitCrashHandler sharedManager].KVOHashMaps setObject:dict forKey:key];
        [self mitCrash_addObserver:observer forKeyPath:keyPath options:options context:context];
        //添加方法
        Class cls = [observer class];
        if(class_addMethod(cls, @selector(mitCrash_observeValueForKeyPath:ofObject:change:context:),class_getMethodImplementation(cls, @selector(mitCrash_observeValueForKeyPath:ofObject:change:context:)), "v#@#^v")){
            //原来的方法
            Method dis_originalMethod = class_getInstanceMethod(cls,@selector(observeValueForKeyPath:ofObject:change:context:));
            //现在的方法
            Method dis_swizzledMethod = class_getInstanceMethod(cls, @selector(mitCrash_observeValueForKeyPath:ofObject:change:context:));
            //交换实现
            method_exchangeImplementations(dis_originalMethod, dis_swizzledMethod);
        }
    } else {
        [self mitCrash_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}
#pragma mark action 移除观察者
- (void)mitCrash_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    NSString * key = [NSString stringWithFormat:@"%@%@",observer,keyPath];
    __weak id obj = nil;
    if ([[MitCrashHandler sharedManager].KVOHashMaps objectForKey:key]!=nil) {
        obj = [[MitCrashHandler sharedManager].KVOHashMaps objectForKey:key];
        [self mitCrash_removeObserver:observer forKeyPath:keyPath];
        [[MitCrashHandler sharedManager].KVOHashMaps removeObjectForKey:key];
    } else {
        [MitCrashHandler handleCrashCls:[self class] message:[NSString stringWithFormat:@"重复删除观察者：%@%@",observer,keyPath] sel:_cmd];

    }
}

#pragma mark action 观察者回调
- (void)mitCrash_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSString * key = [NSString stringWithFormat:@"%@%@",object,keyPath];
    if ([[MitCrashHandler sharedManager].KVOHashMaps objectForKey:key]) {
        [self mitCrash_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {
        [MitCrashHandler handleCrashCls:[self class] message:[NSString stringWithFormat:@"没有观察者：%@%@",object,keyPath] sel:_cmd];
    }
}

@end
