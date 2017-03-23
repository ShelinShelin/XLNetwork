//
//  XLNetworkAgent.h
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "XLBaseRequest.h"

@interface XLNetworkAgent : NSObject

/**
 实例化
 */
+ (XLNetworkAgent *)sharedInstance;

/**
 添加请求到字典
 */
- (void)addRequest:(XLBaseRequest *)request;

/**
 取消某个请求
 */
- (void)cancelRequest:(XLBaseRequest *)request;

/**
 取消所有请求
 */
- (void)cancelAllRequests;

/**
 根据request构建url
 */
- (NSString *)buildRequestUrl:(XLBaseRequest *)request;

@end
