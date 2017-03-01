//
//  MitTimerSubOBJ.h
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^CallBack)(BOOL isInvalidate);

@interface MitTimerSubOBJ : NSObject

/**  target */
@property(nonatomic, weak)id  target;
/**  selector */
@property(nonatomic, weak)NSString * selector;
/**  userinfo */
@property(nonatomic, weak)id userInfo;

/** 回调 */
@property(nonatomic, copy) CallBack callBack;

- (void)forward;
@end
