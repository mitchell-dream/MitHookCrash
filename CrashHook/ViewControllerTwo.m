//
//  ViewControllerTwo.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/1.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "ViewControllerTwo.h"
#import "NSTimer+MitCrash.h"
@interface ViewControllerTwo ()

@end

@implementation ViewControllerTwo

- (void)viewDidLoad {
    [super viewDidLoad];

    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(click) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
}
- (void)click{
    NSLog(@"aaaaa");
}



-(void)dealloc{
    
    NSLog(@"dealloc");
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
