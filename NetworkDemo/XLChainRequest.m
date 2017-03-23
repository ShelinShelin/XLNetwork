//
//  XLChainRequest.m
//  NetworkDemo
//
//  Created by Shelin on 16/6/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLChainRequest.h"
#import "XLNetworkPrivate.h"
#import "XLChainRequestAgent.h"

@interface XLChainRequest () <XLRequestDelegate>

@property (strong, nonatomic) NSMutableArray *requestArray;
@property (strong, nonatomic) NSMutableArray *requestCallbackArray;
@property (assign, nonatomic) NSUInteger nextRequestIndex;
@property (strong, nonatomic) ChainCallback emptyCallback;

@end

@implementation XLChainRequest

#pragma mark - init

- (id)init {
    self = [super init];
    if (self) {
        _nextRequestIndex = 0;
        _requestArray = [NSMutableArray array];
        _requestCallbackArray = [NSMutableArray array];
        _emptyCallback = ^(XLChainRequest *chainRequest, XLBaseRequest *baseRequest) {
            // do nothing
        };
    }
    return self;
}

#pragma mark - public

- (void)start {
    if (_nextRequestIndex > 0) {
        XLLog(@"Error! Chain request has already started.");
        return;
    }
    
    if ([_requestArray count] > 0) {
        [self requestPluginWillStartCallBack];
        [self startNextRequest];
        [[XLChainRequestAgent sharedInstance] addChainRequest:self];
    } else {
        XLLog(@"Error! Chain request array is empty.");
    }
}

- (void)stop {
    [self requestPluginWillStopCallBack];
    [self clearRequest];
    [[XLChainRequestAgent sharedInstance] removeChainRequest:self];
    [self requestPluginDidStopCallBack];
}

- (void)addRequest:(XLBaseRequest *)request callback:(ChainCallback)callback {
    [_requestArray addObject:request];
    if (callback != nil) {
        [_requestCallbackArray addObject:callback];
    } else {
        [_requestCallbackArray addObject:_emptyCallback];
    }
}

- (NSArray *)requestArray {
    return _requestArray;
}


#pragma mark - private

- (BOOL)startNextRequest {
    if (_nextRequestIndex < [_requestArray count]) {
        XLBaseRequest *request = _requestArray[_nextRequestIndex];
        _nextRequestIndex++;
        request.delegate = self;
        [request start];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Network Request Delegate

- (void)requestFinished:(XLBaseRequest *)request {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    ChainCallback callback = _requestCallbackArray[currentRequestIndex];
    callback(self, request);
    if (![self startNextRequest]) {
        [self requestPluginWillStopCallBack];
        if ([_delegate respondsToSelector:@selector(chainRequestSucceed:)]) {
            [_delegate chainRequestSucceed:self];
            [[XLChainRequestAgent sharedInstance] removeChainRequest:self];
        }
        [self requestPluginDidStopCallBack];
    }
}

- (void)requestFailed:(XLBaseRequest *)request {
    [self requestPluginWillStopCallBack];
    if ([_delegate respondsToSelector:@selector(chainRequestFailed:failedBaseRequest:)]) {
        [_delegate chainRequestFailed:self failedBaseRequest:request];
        [[XLChainRequestAgent sharedInstance] removeChainRequest:self];
    }
    [self requestPluginDidStopCallBack];
}

- (void)clearRequest {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    if (currentRequestIndex < [_requestArray count]) {
        XLBaseRequest *request = _requestArray[currentRequestIndex];
        [request stop];
    }
    [_requestArray removeAllObjects];
    [_requestCallbackArray removeAllObjects];
}

#pragma mark - Request Accessoies

- (void)addRequestPlugin:(id<XLRequestPlugin>)plugin {
    if (!self.requestPlugins) {
        self.requestPlugins = [NSMutableArray array];
    }
    [self.requestPlugins addObject:plugin];
}

@end
