//
//  MitPointerChecker.h
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/5.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

extern BOOL isRunningWildPointerCheck;

void startWildPointerCheck();

void stopWildPointerCheck();
