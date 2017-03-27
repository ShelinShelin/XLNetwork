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

#pragma mark - 取消全部请求

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        XLBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

#pragma mark - 取消某个请求

- (void)cancelRequest:(XLBaseRequest *)request {
    [request.sessionDataTask cancel];
    [self removeSessionDataTask:request.sessionDataTask];
    [request clearCompletionBlock];
}

#pragma mark - 发起AFN网络请求

- (void)addRequest:(XLBaseRequest *)request {
    // 网络不可用
    if (![XLNetworkPrivate checkNetworkStatus]) {
        // 提示网络连接失败，请稍后再试！
        
    }
    
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
        
        if (request.isLoadingAnimation) {  // 执行加载动画
            [self loadingAnimationShow];
        }
        
        request.sessionDataTask = [_manager GET:requestUrl parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            XLLog(@"\n-------------------Success-------------------\n ***Method = GET\n ***URL = %@%@\n ***Params = %@\n ***Result = %@\n--------------------------------------\n", request.baseUrl, request.requestUrl, request.requestArgument,responseObject);
            
            // 隐藏加载动画
            [self loadingAnimationHiden];
            
            if (responseObject) {
                [request setValue:responseObject forKey:@"responseJSONObject"];
                [request setValue:[XLNetworkPrivate responseObjectToJSONStr:responseObject] forKey:@"responseString"];
            }
            [self handleRequestResult:task];

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            XLLog(@"\n-------------------Failure-------------------\n ***Method = GET\n ***URL = %@%@\n ***params =%@\n ***ErrorCode = %ld\n--------------------------------------\n",request.baseUrl, request.requestUrl, request.requestArgument, (long)request.responseStatusCode);
            
            // 隐藏加载动画
            [self loadingAnimationHiden];
            
            [self handleRequestResult:task];
            
        }];
    }else if (method == XLRequestMethodPost) {  //POST
        
        if (request.isLoadingAnimation) {  // 执行加载动画
            [self loadingAnimationShow];
        }
        
        request.sessionDataTask = [_manager POST:requestUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            XLLog(@"\n-------------------Success-------------------\n ***Method = POST\n ***URL = %@%@\n ***Params = %@\n ***Result = %@\n--------------------------------------\n", request.baseUrl, request.requestUrl, request.requestArgument,responseObject);
            
            // 隐藏加载动画
            [self loadingAnimationHiden];
            
            if (responseObject) {
                [request setValue:responseObject forKey:@"responseJSONObject"];
                [request setValue:[XLNetworkPrivate responseObjectToJSONStr:responseObject] forKey:@"responseString"];
            }
            [self handleRequestResult:task];

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            XLLog(@"\n-------------------Failure-------------------\n ***Method = POST\n ***URL = %@%@\n ***Params =%@\n ***ErrorCode = %ld\n--------------------------------------\n",request.baseUrl, request.requestUrl, request.requestArgument, (long)request.responseStatusCode);
            
            // 隐藏加载动画
            [self loadingAnimationHiden];
            
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

// 处理请求回调结果

- (void)handleRequestResult:(NSURLSessionDataTask *)sessionDataTask {
    //先从字典中取
    NSString *key = [self requestHashKey:sessionDataTask];
    XLBaseRequest *request = _requestsRecord[key];
    
    if (request) {
        //验证状态码
        if ([request statusCodeValidator]) {    //请求成功
            
            if ([request isMessageCodeCorrect]) { // 服务端code正确
                if (request.customSuccessMessage.length) { // 有自定义成功提示
                    // HUD
                }
            } else { // code error
                
                if (!request.customErrorMessage.length ) { // 无自定义错误提示
                    // HUD code
                } else {
                    // HUD request.customErrorMessage
                    
                    //HFShowTextHUD
                }
            }

            
            //调用动画插件
            [request requestPluginWillStopCallBack];
            [request requestSucceedHandler];
            
            if (request.delegate != nil) {
                [request.delegate requestSucceed:request];
            }
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request);
            }
            
            [request requestPluginDidStopCallBack];
        } else {    //请求失败
            
            [request requestPluginWillStopCallBack];
            [request requestFailedHandler];
            
            if (request.delegate != nil) {
                [request.delegate requestFailed:request];
            }
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            
            [request requestPluginDidStopCallBack];
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

#pragma mark - loading animation

- (void)loadingAnimationShow {
    
}

- (void)loadingAnimationHiden {
    
}


@end
