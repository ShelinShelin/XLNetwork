//
//  XLBaseRequest.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/10.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLBaseRequest.h"
#import "XLNetworkAgent.h"
#import "XLNetworkPrivate.h"

@implementation XLBaseRequest

#pragma mark - public

- (void)start {
    [self accessoriesWillStartCallBack];
    
    [[XLNetworkAgent sharedInstance] addRequest:self];
}

- (void)stop {
    [self accessoriesWillStopCallBack];
    
    self.delegate = nil;
    [[XLNetworkAgent sharedInstance] cancelRequest:self];
    
    [self accessoriesDidStopCallBack];
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (void)startWithCompletionBlockWithSuccess:(XLRequestSuccessBlock)success
                                    failure:(XLRequestFailureBlcok)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    
    [self start];
}

#pragma mark - getter

- (NSDictionary *)responseHeaders {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.sessionDataTask.response;
    return response.allHeaderFields;
}

- (NSInteger)responseStatusCode {
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.sessionDataTask.response;
    return response.statusCode;
}


#pragma mark - override for subclass

/**
 请求成功的回调
 */
- (void)requestCompleteHandler {

}

/**
 请求失败的回调
 */
- (void)requestFailedHandler {

}

/**
 请求的URL
 */
- (NSString *)requestUrl {
    return @"";
}

/**
 请求的BaseURL
 */
- (NSString *)baseUrl {
    return @"";
}

/**
 请求的连接超时时间，默认为60秒
 */
- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

/**
 请求的参数列表
 */
- (id)requestArgument {
    return nil;
}

/**
 Http请求的方法
 */
- (XLRequestMethod)requestMethod {
    return XLRequestMethodGet;
}

/**
 请求的SerializerType
 */
- (XLRequestSerializerType)requestSerializerType {
    return XLRequestSerializerTypeJSON;
}

/**
 在HTTP报头添加的自定义参数
 */
- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

/**
 用于检查Status Code是否正常的方法
 */
- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Request Accessoies

- (void)addAccessory:(id<XLRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}


@end
