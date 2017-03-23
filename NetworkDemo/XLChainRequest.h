//
//  XLChainRequest.h
//  NetworkDemo
//
//  Created by Shelin on 16/6/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLBaseRequest.h"

@class XLChainRequest;

typedef void (^ChainCallback)(XLChainRequest *chainRequest, XLBaseRequest *baseRequest);

@protocol XLChainRequestDelegate <NSObject>

@optional

- (void)chainRequestSucceed:(XLChainRequest *)chainRequest;

- (void)chainRequestFailed:(XLChainRequest *)chainRequest failedBaseRequest:(XLBaseRequest *)request;

@end


@interface XLChainRequest : NSObject

@property (weak, nonatomic) id<XLChainRequestDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *requestPlugins;

/**
 start chain request
 */
- (void)start;

/**
 stop chain request
 */
- (void)stop;

- (void)addRequest:(XLBaseRequest *)request callback:(ChainCallback)callback;

- (NSArray *)requestArray;

- (void)addRequestPlugin:(id<XLRequestPlugin>)plugin;


@end
