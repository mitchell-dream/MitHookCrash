//
//  NSObject+MethodSwizz.h
//  CrashHook
//
//  Created by MENGCHEN on 2017/2/25.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static inline void StaticSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)))
    {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@interface NSObject (MethodSwizz)


+ (void)swizzleMethod:(Class)cls origin:(SEL)selector new:(SEL)newSelector;
+ (BOOL)swizzleClassMethod:(SEL)originSelector withClassMethod:(SEL)swizzledSelector error:(NSError **)error;

@end
