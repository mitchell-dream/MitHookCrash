//
//  MitTimer.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitTimer.h"

@implementation MitTimer


-(void)forward{
    if (self.target == nil) {
        if (self.callBack) {
            self.callBack(true);
        }
    }else if(self.selector){
        if ([self.target respondsToSelector:NSSelectorFromString(self.selector)]) {
            [self.target performSelector:NSSelectorFromString(self.selector) withObject:_userInfo];
        }
    }else{
        NSLog(@"没有 selector");
    }
    
}

@end
