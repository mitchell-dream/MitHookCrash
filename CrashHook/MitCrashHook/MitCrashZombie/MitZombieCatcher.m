//
//  MitZombieCatcher.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/2.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitZombieCatcher.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import <Foundation/Foundation.h>
#import "MitCrashHandler.h"
@implementation MitZombieCatcher



- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"发现野指针：%s%@%@",class_getName(self.originCls),self,NSStringFromSelector(aSelector));
    class_addMethod([MitCrashHandler class], aSelector,(IMP)MithandleZombie, "v#:@");
    MitCrashHandler * instance = [MitCrashHandler new];
    [MitCrashHandler handleCrashCls:[self class] Sel:aSelector];
    return instance;
}



@end
