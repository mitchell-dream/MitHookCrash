//
//  MitPointerChecker.m
//  CrashHook
//
//  Created by MENGCHEN on 2017/3/5.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitPointerChecker.h"

#import "malloc/malloc.h"
#import "pthread.h"
#import "fishhook.h"
#import <objc/runtime.h>
#import "MitZombieCatcher.h"
#define MAX_UNFREE_POINTER 1024*1024*10  //10MB
#define MAX_UNFREE_MEM     1024*1024*100 //100MB
#define FREE_POINTER_NUM   100           //每次释放100个指针

//未释放成员结构体
typedef struct unfreeMem {
    void *p;
    struct unfreeMem *next;
}UNFREE_MEM, *MITFREE_MEM;

//未释放链表
typedef struct unfreeList {
    MITFREE_MEM header_list;
    MITFREE_MEM tail_list;
    size_t      unfree_count;
    size_t      unfree_size;
}UNFREE_LIST, *PUNFREE_LIST;

//原始方法
void (*orig_free)(void *);
//释放方法
void myfree(void *p);
//创建链表
PUNFREE_LIST createList();
//向链表中添加元素
void addUnFreeMemToListSync(PUNFREE_LIST unfreeList, void *p);
//释放链表中的元素
void freeMemInListSync(PUNFREE_LIST unfreeList, size_t freeNum);
//未释放元素链表
PUNFREE_LIST global_unfree_list = NULL;
//互斥锁
pthread_mutex_t global_mutex;
//类
Class global_zombie;
//类大小
size_t global_zombie_size;
//全局注册类集合
CFMutableSetRef global_registerdClasses;
//检测是否进行
BOOL isRunningWildPointerCheck = NO;


#pragma mark ACTION：开始野指针检测
void startWildPointerCheck()
{
    //获取已注册的类
    global_registerdClasses = CFSetCreateMutable(NULL, 0, NULL);
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    for (unsigned int i = 0; i < count; i++) {
        CFSetAddValue(global_registerdClasses, (__bridge const void *)(classes[i]));
    }
    free(classes);
    classes = NULL;
    //获取僵尸对象和其大小
    global_zombie = objc_getClass("MitZombieCatcher");
    global_zombie_size = class_getInstanceSize(global_zombie);
    //创建未释放内存的链表(带链表头)
    global_unfree_list = createList();
    //创建同步互斥量
    pthread_mutex_init(&global_mutex, NULL);
    //hook free
    rebind_symbols((struct rebinding[1]){{"free", myfree, (void *)&orig_free}}, 1);
    
    isRunningWildPointerCheck = YES;
}


#pragma mark ACTION：停止野指针检测
void stopWildPointerCheck()
{
    isRunningWildPointerCheck = NO;
}



#pragma mark ACTION：释放
void myfree(void *p)
{
    if (!isRunningWildPointerCheck) {
        orig_free(p);
        return;
    }
    
    if (global_unfree_list->unfree_count > MAX_UNFREE_POINTER * 0.9 || global_unfree_list->unfree_size > MAX_UNFREE_MEM) {
        freeMemInListSync(global_unfree_list, FREE_POINTER_NUM);
    }
    
    size_t size = malloc_size(p);
    if (size >= global_zombie_size) {
        __unsafe_unretained id obj = (__bridge id)p;
        Class originClass = object_getClass(obj);
        if (originClass && CFSetContainsValue(global_registerdClasses, (__bridge const void *)(originClass))) {
            memset(p, 0x55, size);
            memcpy(p, &global_zombie, sizeof(void *));
            
            MitZombieCatcher *zombie = (__bridge MitZombieCatcher *)p;
            zombie.originCls = originClass;
        } else {
            memset(p, 0x55, size);
        }
    } else {
        memset(p, 0x55, size);
    }
    
    addUnFreeMemToListSync(global_unfree_list, p);
}


#pragma mark ACTION：创建列表
PUNFREE_LIST createList()
{
    PUNFREE_LIST unfreeList = (PUNFREE_LIST)malloc(sizeof(UNFREE_LIST));
    unfreeList->header_list = (MITFREE_MEM)malloc(sizeof(UNFREE_MEM));
    unfreeList->header_list->p = NULL;
    unfreeList->header_list->next = NULL;
    unfreeList->tail_list = unfreeList->header_list;
    unfreeList->unfree_count = 0;
    unfreeList->unfree_size = 0;
    return unfreeList;
}


#pragma mark ACTION:向未释放链表中添加成员
void addUnFreeMemToListSync(PUNFREE_LIST unfreeList, void *p)
{
    pthread_mutex_lock(&global_mutex);
    if (!unfreeList || !p) {
        pthread_mutex_unlock(&global_mutex);
        return;
    }
    MITFREE_MEM unfreeMem = (MITFREE_MEM)malloc(sizeof(UNFREE_MEM));
    unfreeMem->p = p;
    unfreeMem->next = NULL;
    unfreeList->tail_list->next = unfreeMem;
    unfreeList->tail_list = unfreeMem;
    unfreeList->unfree_count++;
    unfreeList->unfree_size += malloc_size(p);
    pthread_mutex_unlock(&global_mutex);
}

#pragma mark ACTION:释放链表中的成员
void freeMemInListSync(PUNFREE_LIST unfreeList, size_t freeNum)
{
    pthread_mutex_lock(&global_mutex);
    if (!unfreeList || freeNum <= 0) {
        pthread_mutex_unlock(&global_mutex);
        return;
    }
    
    if (!unfreeList->header_list->next) {
        pthread_mutex_unlock(&global_mutex);
        return;
    }
    
    for (int i = 0; i < freeNum && unfreeList->header_list->next; i++) {
        MITFREE_MEM memToDelete = unfreeList->header_list->next;
        if (memToDelete == unfreeList->tail_list) {
            unfreeList->tail_list = unfreeList->header_list;
        }
        unfreeList->header_list->next = memToDelete->next;
        unfreeList->unfree_size -= malloc_size(memToDelete->p);
        unfreeList->unfree_count--;
        orig_free(memToDelete->p);
        orig_free(memToDelete);
    }
    pthread_mutex_unlock(&global_mutex);
}
