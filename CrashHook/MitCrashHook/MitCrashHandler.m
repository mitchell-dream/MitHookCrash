//
//  MitCrashHandler.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/2/25.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitCrashHandler.h"
#import "MitPointerChecker.h"
#import "MitCrashConfig.h"
@implementation MitCrashHandler
#pragma mark action 处理异常类，方法
+(void)handleCrashCls:(Class)cls Sel:(SEL)selector{
    //打印调用栈
    NSLog(@"%@",[NSThread callStackSymbols]);
    NSLog(@"class %@ call unRecognized function %@",NSStringFromClass(cls),NSStringFromSelector(selector));
}

#pragma mark action 处理类和消息
+ (void)handleCrashCls:(Class)cls message:(NSString *)msg sel:(SEL)selector{
    NSLog(@"class %@ | sel:%@ | message: %@",NSStringFromClass(cls),msg,NSStringFromSelector(selector));
}

void MithandleUnRecognise ( SEL _cmd){
    NSLog(@" call unRecognised function %@",NSStringFromSelector(_cmd));
}
void MithandleZombie ( SEL _cmd){
    NSLog(@" find wild Pointer  %@",NSStringFromSelector(_cmd));
}


+ (instancetype)sharedManager{
    static MitCrashHandler * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MitCrashHandler alloc]init];
    });
    return manager;
}


- (instancetype)init{
    if (self = [super init]) {
        self.KVOHashMaps = [NSMutableDictionary dictionary];
        self.NotiMaps = [NSMutableDictionary dictionary];
        NSLog(@"%@",self.handleConfig);
    }
    return self;
}

#pragma mark action 开始引擎
- (void)startEngine{
    if ([[self.handleConfig objectForKey:MitCrash_ZOBIE_KEY] boolValue]) {
        startWildPointerCheck();
    }
}


#pragma mark create 读取配置
- (NSDictionary *)handleConfig{
    if (!_handleConfig) {
        NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MitCrashConfig" ofType:@"plist"]];
        _handleConfig = dataDict;
    }
    return _handleConfig;
}
@end
