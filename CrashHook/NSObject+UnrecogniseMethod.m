//
//  NSObject+UnrecogniseMethod.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/2/25.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+UnrecogniseMethod.h"
#import "NSObject+MethodSwizz.h"
#import "MitCrashHandler.h"
#import <objc/runtime.h>
@implementation NSObject (UnrecogniseMethod)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzleMethod:[self class] origin:@selector(forwardingTargetForSelector:) new:@selector(mitCrash_forwardingTargetForSelector:)];

    });
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




////程序找不到所调用的方法之前，可以通过重写这四个方法来拦截调用
//+(BOOL)resolveClassMethod:(SEL)sel{
//    
//}
//
//+(BOOL)resolveInstanceMethod:(SEL)sel{
//    //需要在类的本身上动态添加它本身不存在的方法
//    
//}
//
//-(id)forwardingTargetForSelector:(SEL)aSelector{
//    //可以将消息转发给一个对象，开销较小，并且被重写的概率较低。
//}
//
//-(void)forwardInvocation:(NSInvocation *)anInvocation{
//    //将消息转发给多个对象，但是消耗大
//}


@end
