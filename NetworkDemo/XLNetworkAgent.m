//
//  XLNetworkAgent.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLNetworkAgent.h"
#import "XLNetworkPrivate.h"

@implementation XLNetworkAgent {
    NSMutableDictionary *_requestsRecord;   //key：NSURLSessionDataTask哈希字符串  value：XLBaseRequest
    AFHTTPSessionManager *_manager;
}

#pragma mark - public

+ (XLNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//取消全部请求
- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        XLBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

//取消某个请求
- (void)cancelRequest:(XLBaseRequest *)request {
    [request.sessionDataTask cancel];
    [self removeSessionDataTask:request.sessionDataTask];
    [request clearCompletionBlock];
}

- (void)addRequest:(XLBaseRequest *)request {
    
    //请求方式
    XLRequestMethod method = [request requestMethod];
    
    //请求地址
    NSString *requestUrl = [self buildRequestUrl:request];
    
    //请求参数
    id param = request.requestArgument;
    
    if (request.requestSerializerType == XLRequestSerializerTypeHTTP) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == XLRequestSerializerTypeJSON) {
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    //请求超时时间
    _manager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    //自定义请求头参数
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [_manager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                XLLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    //发起请求
    if (method == XLRequestMethodGet) { //GET
        
        request.sessionDataTask = [_manager GET:requestUrl parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [request setValue:responseObject forKey:@"responseJSONObject"];
            [request setValue:[XLNetworkPrivate responseObjectToJSONStr:responseObject] forKey:@"responseString"];
            [self handleRequestResult:task];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestResult:task];
            
        }];
    }else if (method == XLRequestMethodPost) {  //POST
        
        request.sessionDataTask = [_manager POST:requestUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [request setValue:responseObject forKey:@"responseJSONObject"];
            [request setValue:[XLNetworkPrivate responseObjectToJSONStr:responseObject] forKey:@"responseString"];
            [self handleRequestResult:task];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestResult:task];
            
        }];
    }
    
    [self addSessionDataTask:request];
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager = [AFHTTPSessionManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - privite
/**
 拼接URL
 */
- (NSString *)buildRequestUrl:(XLBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }else {
        return [NSString stringWithFormat:@"%@%@", request.baseUrl, detailUrl];
    }
}

//
- (void)handleRequestResult:(NSURLSessionDataTask *)sessionDataTask {
    //先从字典中取
    NSString *key = [self requestHashKey:sessionDataTask];
    XLBaseRequest *request = _requestsRecord[key];
    
    if (request) {
        //验证状态码
        if ([request statusCodeValidator]) {    //请求成功
            
            //调用动画插件
            [request accessoriesWillStopCallBack];
            [request requestCompleteHandler];
            
            if (request.delegate != nil) {
                [request.delegate requestFinished:request];
            }
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request);
            }
            
            [request accessoriesDidStopCallBack];
        } else {    //请求失败
            
            [request accessoriesWillStopCallBack];
            [request requestFailedHandler];
            
            if (request.delegate != nil) {
                [request.delegate requestFailed:request];
            }
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            
            [request accessoriesDidStopCallBack];
        }
    }
    
    //避免循环引用
    [request clearCompletionBlock];
}

/**
 _requestsRecord 字典中添加
 */
- (void)addSessionDataTask:(XLBaseRequest *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = [self requestHashKey:request.sessionDataTask];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

/**
 _requestsRecord 字典中移除
 */
- (void)removeSessionDataTask:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [self requestHashKey:sessionDataTask];
    @synchronized(self) {   //加锁，线程安全
        [_requestsRecord removeObjectForKey:key];
    }
    XLLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
}

//哈希
- (NSString *)requestHashKey:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[sessionDataTask hash]];
    return key;
}

@end
