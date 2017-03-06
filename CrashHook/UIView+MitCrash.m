//
//  UIView+MitCrash.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/4.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "UIView+MitCrash.h"
#import "NSObject+MethodSwizz.h"
@implementation UIView (MitCrash)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzleMethod:[self class] origin:@selector(setNeedsLayout) new:@selector(MitCrash_setNeedsLayout)];
        [NSObject swizzleMethod:[self class] origin:@selector(setNeedsDisplay) new:@selector(MitCrash_setNeedsDisplay)];
        [NSObject swizzleMethod:[self class] origin:@selector(setNeedsDisplayInRect:) new:@selector(MitCrash_setNeedsDisplayInRect:)];
    });
}

#pragma mark action 将一些方法放到主线程来进行
-(void)MitCrash_setNeedsLayout{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self MitCrash_setNeedsLayout];
    });
}
-(void)MitCrash_setNeedsDisplay{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self MitCrash_setNeedsDisplay];
    });
}

-(void)MitCrash_setNeedsDisplayInRect:(CGRect)rect{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self MitCrash_setNeedsDisplayInRect:rect];
    });
}

@end
