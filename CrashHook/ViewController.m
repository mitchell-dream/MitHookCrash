//
//  ViewController.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/2/25.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+UnrecogniseMethod.h"
#import "TestDemo.h"
#import "MitCrashHandler.h"
#import "ViewControllerTwo.h"
#import "MitCrashHeader.h"


@interface ViewController ()<MitCrashKVODelegate,MitCrashNotifyDelegate>

/**  <#Description#> */
@property(nonatomic, assign)NSInteger num;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"num" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"num" options:NSKeyValueObservingOptionNew context:nil];

    self.num = 0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterFore) name:UIApplicationWillEnterForegroundNotification object:nil];


    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 100, 100);
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    
    NSArray * arr = @[@"1",@"2"];
    
    NSLog(@"%@",[arr objectAtIndex:3]);
    NSMutableArray * arr2  =[NSMutableArray arrayWithObjects:@"3",@"4", nil];
    NSLog(@"%@",[arr2 objectAtIndex:3]);
    [arr2 insertObject:@"6" atIndex:4];
    [arr2 addObject:nil];
    [arr2 replaceObjectAtIndex:1 withObject:nil];
    
    NSDictionary *dic = @{@"1":@"11",@"2":@"22"};
    [dic valueForKey:nil];
    NSMutableDictionary * dic2 = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dic2 setObject:nil forKey:@"1"];
    [dic2 setObject:@"1" forKey:nil];

    
    
}

#pragma mark action 按钮点击
- (void)btnClick{
    ViewControllerTwo * vc = [ViewControllerTwo new];
    [self presentViewController:vc animated:true completion:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.num++;
    NSLog(@"点击 --- %ld",self.num);
    
}

- (void)enterBack{
    [self removeObserver:self forKeyPath:@"num"];
    [self removeObserver:self forKeyPath:@"num"];
    self.num++;
    NSLog(@"%ld",self.num);

}

- (void)enterFore{
    [self addObserver:self forKeyPath:@"num" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"num" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"num" options:NSKeyValueObservingOptionNew context:nil];

    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"收到 = %@",object);
}

-(void)dealloc{
    
    
}

@end
