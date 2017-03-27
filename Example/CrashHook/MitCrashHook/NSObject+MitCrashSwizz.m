//
//  NSObject+MitCrashSwizz.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/2/25.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+MitCrashSwizz.h"

@implementation NSObject (MethodSwizz)
+(void)swizzleMethod:(Class)cls origin:(SEL)originSelector new:(SEL)newSelector{
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzleMethod = class_getInstanceMethod(cls, newSelector);
    BOOL didAddMethod = class_addMethod(cls, originSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }else{
        method_exchangeImplementations(originMethod, swizzleMethod);
    }
}

+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector error:(NSError **)error
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    if (!originalMethod)
    {
        NSString *errStr = [NSString stringWithFormat:@"Swizzle : Original method %@ not found for class %@",NSStringFromSelector(originalSelector),NSStringFromClass([self class])];
        *error = [NSError errorWithDomain:@"NSCocoaErrorDomain"
                                     code:-1
                                 userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]];
        return NO;
    }
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    if (!swizzledMethod)
    {
        NSString *errStr = [NSString stringWithFormat:@"Swizzle : Swizzled method %@ not found for class %@",NSStringFromSelector(swizzledSelector),NSStringFromClass([self class])];
        *error = [NSError errorWithDomain:@"NSCocoaErrorDomain"
                                     code:-1
                                 userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]];
        return NO;
    }
    if (class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)))
    {
        class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}
+ (BOOL)swizzleClassMethod:(SEL)originSelector withClassMethod:(SEL)swizzledSelector error:(NSError **)error
{
    Class classInstance = object_getClass(self);
    return [classInstance swizzleMethod:originSelector withMethod:swizzledSelector error:error];
}

@end
