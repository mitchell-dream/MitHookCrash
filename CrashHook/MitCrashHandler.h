//
//  MitCrashHandler.h
//  CrashHook
//
//  Created by MENGCHEN on 2017/2/25.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>


//不能识别方法的函数指针
void MithandleUnRecognise ( SEL _cmd);


@protocol MitCrashKVODelegate <NSObject>



@end

@protocol MitCrashNotifyDelegate <NSObject>



@end


@interface MitCrashHandler : NSObject

/** 观察者map */
@property(nonatomic, strong)NSMutableDictionary * KVOHashMaps;

/** 通知 */
@property(nonatomic, strong)NSMutableDictionary * NotiMaps;


//单例
+ (instancetype)sharedManager;
// 处理不识别方法  crash
+ (void)handleCrashCls:(Class)cls Sel:(SEL)selector;
// 处理方法 message 消息
+ (void)handleCrashCls:(Class)cls message:(NSString *)msg sel:(SEL)selector;



@end
