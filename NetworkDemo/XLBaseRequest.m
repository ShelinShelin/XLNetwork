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
    [self requestPluginWillStartCallBack];
    
    [[XLNetworkAgent sharedInstance] addRequest:self];
}

- (void)stop {
    [self requestPluginWillStopCallBack];
    
    self.delegate = nil;
    [[XLNetworkAgent sharedInstance] cancelRequest:self];
    
    [self requestPluginDidStopCallBack];
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
- (void)requestSucceedHandler {

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
    return XLRequestMethodGet;  //默认GET
}

/**
 请求的SerializerType
 */
- (XLRequestSerializerType)requestSerializerType {
    return XLRequestSerializerTypeHTTP;   //默认HTTP
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

/**
 是否有加载动画，默认NO
 */
- (BOOL)isLoadingAnimation {
    return NO;
}

/**
 *  返回的message code 是否正确，默认服务器1000为正确code
 */
- (BOOL)isMessageCodeCorrect {
    if ([self.responseJSONObject[@"code"] isEqual:@1000]) {
        return YES;
    }
    return NO;
}

/**
 *  自定义错误code提示消息，默认提示服务器返回message
 */
- (NSString *)customErrorMessage {
    return @"";
}

/**
 *  自定义正确成功提示消息，默认空字符串
 */
- (NSString *)customSuccessMessage {
    return @"";
}

- (id)treatedDataObject {
    return self.responseJSONObject;    //默认返回原始数据
}

#pragma mark - Request Accessoies

- (void)addRequestPlugin:(id<XLRequestPlugin>)plugin {
    if (!self.requestPlugins) {
        self.requestPlugins = [NSMutableArray array];
    }
    [self.requestPlugins addObject:plugin];
}


@end
