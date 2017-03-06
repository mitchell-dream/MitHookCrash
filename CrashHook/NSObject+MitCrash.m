//
//  NSObject+MitCrash.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/2.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+MitCrash.h"
#import "NSObject+MethodSwizz.h"
#import "MitCrashHandler.h"
#import <objc/runtime.h>
#import "MitZombieCatcher.h"
@implementation NSObject (MitCrash)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //dealloc
        [NSObject swizzleMethod:[self class] origin:NSSelectorFromString(@"dealloc") new:@selector(MitCrash_dealloc)];
        //添加观察者
        [NSObject swizzleMethod:[self class] origin:@selector(addObserver:forKeyPath:options:context:) new:@selector(mitCrash_addObserver:forKeyPath:options:context:)];
        //移除观察者
        [NSObject swizzleMethod:[self class] origin:@selector(removeObserver:forKeyPath:) new:@selector(mitCrash_removeObserver:forKeyPath:)];
        //unrecogniseMethod
        [NSObject swizzleMethod:[self class] origin:@selector(forwardingTargetForSelector:) new:@selector(mitCrash_forwardingTargetForSelector:)];
        
        //僵尸对象
        NSError * err = nil;
        [self swizzleClassMethod:@selector(allocWithZone:) withClassMethod:@selector(MitCrash_allocWithZone:) error:&err];
        

    });
}

static  NSString * kZombieKey = @"kZombieKey";
static  NSString * kZombieValue = @"kZombieValue";

+ (instancetype)MitCrash_allocWithZone:(struct _NSZone *)zone{
    if ([self conformsToProtocol:@protocol(MitCrashZombieDelegate)]) {
        objc_setAssociatedObject(self, &kZombieKey, kZombieValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [self MitCrash_allocWithZone:zone];
}

#pragma mark action 修补 unRecognized crash
-(id)mitCrash_forwardingTargetForSelector:(SEL)aSelector{
    if ([self isKindOfClass:[NSObject class]]&&![NSStringFromClass([self class]) containsString:@"_"]) {
        //给 selector 动态添加一个实现
        /*
         其中types参数为"i@:@“，按顺序分别表示：
         i：返回值类型int，若是v则表示void
         @：参数id(self)
         :：SEL(_cmd)
         @：id(str)
         v:void
         */
        class_addMethod([MitCrashHandler class], aSelector,(IMP)MithandleUnRecognise, "v#:@");
        MitCrashHandler * instance = [MitCrashHandler new];
        [MitCrashHandler handleCrashCls:[self class] Sel:aSelector];
        return instance;
        
    } else {
        return [self mitCrash_forwardingTargetForSelector:aSelector];
    }
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


#pragma mark action dealloc
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
