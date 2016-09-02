//
//  ViewController.m
//  GCDSemaphoreDemo
//
//  Created by jjyy on 16/8/24.
//  Copyright © 2016年 Arthur. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

#define kUrlString @"http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json"    //新浪接口
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self requestUsingGroup];
    
//    [self requestUsingSemaphore];
    
    /**
     *  this method is created on 2016.09.02
     */
    [self requestUsingSemaphoreUpdate];
}

- (void)requestUsingGroup {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //request 1
    dispatch_group_async(group, queue, ^{
        [[AFHTTPSessionManager manager] POST:kUrlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSLog(@"the first request responseObject:%@",responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error:%@",error.localizedDescription);
        }];
    });
    //request 2
    dispatch_group_async(group, queue, ^{
        [[AFHTTPSessionManager manager] POST:kUrlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSLog(@"the second request responseObject:%@",responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error:%@",error.localizedDescription);
        }];
    });
    //
    dispatch_group_notify(group, queue, ^{
        NSLog(@"all requests completed");
    });
    
    /**
     *  log:
     *  all requests completed
     *  the second request responseObject:{data}
     *  the first request responseObject:{data}
     */
    
}

- (void)requestUsingSemaphore {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        //request 1
        [[AFHTTPSessionManager manager] POST:kUrlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"the first request responseObject: %@",responseObject);
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error : %@",error.localizedDescription);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //request 2
        [[AFHTTPSessionManager manager] POST:kUrlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"the second request responseObject: %@",responseObject);
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error : %@",error.localizedDescription);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"all requests completed");
        });
    });
    /**
     *  log
     *  the first request responseObject:{data}
     *  the second request responseObject:{data}
     *  all requests completed
     */
}

//*****************************     2016.09.02 update  **************************************
//******************************     create the method `- (void)requestUsingSemaphoreUpdate`   *************************************
//*******************************************************************

- (void)requestUsingSemaphoreUpdate {
    
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //request 1
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [[AFHTTPSessionManager manager] POST:kUrlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"the first request responseObject: %@",responseObject);
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error : %@",error.localizedDescription);
        }];
        //request 2
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [[AFHTTPSessionManager manager] POST:kUrlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"the second request responseObject: %@",responseObject);
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error : %@",error.localizedDescription);
        }];
        //
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"all requests completed");
            dispatch_semaphore_signal(semaphore);
        });
    });
    /**
     *  log
     *  the first request responseObject:{data}
     *  the second request responseObject:{data}
     *  all requests completed
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
