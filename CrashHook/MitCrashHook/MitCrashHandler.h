//
//  MitCrashHandler.h
//  CrashHook
//
//  Created by MENGCHEN on 2017/2/25.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MITCRASHMANAGER [MitCrashHandler sharedManager]

//不能识别方法的函数指针
void MithandleUnRecognise ( SEL _cmd);
void MithandleZombie(SEL _cmd);
//观察者
@protocol MitCrashKVODelegate <NSObject>
@end
//通知
@protocol MitCrashNotifyDelegate <NSObject>
@end
//野指针
@protocol MitCrashZombieDelegate <NSObject>
@end
@interface MitCrashHandler : NSObject
/** 观察者map */
@property(nonatomic, strong)NSMutableDictionary * KVOHashMaps;
/** 通知map */
@property(nonatomic, strong)NSMutableDictionary * NotiMaps;
/** 处理配置 */
@property(nonatomic, strong)NSDictionary * handleConfig;

//init
+ (instancetype)sharedManager;

// 开始监控
- (void)startEngine;
// 处理不识别方法  crash
+ (void)handleCrashCls:(Class)cls Sel:(SEL)selector;
// 处理方法 message 消息
+ (void)handleCrashCls:(Class)cls message:(NSString *)msg sel:(SEL)selector;
@end
