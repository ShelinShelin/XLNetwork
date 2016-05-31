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

+ (XLNetworkAgent *)sharedInstance;

- (void)addRequest:(XLBaseRequest *)request;

- (void)cancelRequest:(XLBaseRequest *)request;

- (void)cancelAllRequests;

/// 根据request和networkConfig构建url
- (NSString *)buildRequestUrl:(XLBaseRequest *)request;

@end
