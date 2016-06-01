//
//  XLBaseRequest.h
//  NetworkDemo
//
//  Created by Shelin on 16/5/10.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *日志输出
 */
#ifdef DEBUG

#define XLLog(...) NSLog(__VA_ARGS__)

#else

#define XLLog(...)

#endif


#import "AFNetworking.h"

@class XLBaseRequest;

typedef NS_ENUM(NSInteger , XLRequestMethod) {
    XLRequestMethodGet = 0,
    XLRequestMethodPost,
};

typedef NS_ENUM(NSInteger , XLRequestSerializerType) {
    XLRequestSerializerTypeHTTP = 0,
    XLRequestSerializerTypeJSON,
};

typedef void (^XLRequestSuccessBlock)(XLBaseRequest *request);
typedef void (^XLRequestFailureBlcok)(XLBaseRequest *request);

#pragma mark - XLRequestDelegate    请求结果回调

@protocol XLRequestDelegate <NSObject>

@optional

- (void)requestFinished:(XLBaseRequest *)request;
- (void)requestFailed:(XLBaseRequest *)request;
- (void)clearRequest;

@end

#pragma mark - XLRequestAccessory   请求过程回调

//插件机制
@protocol XLRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

@interface XLBaseRequest : NSObject

@property (nonatomic, strong) NSString *baseUrl;

/** request delegate object */
@property (nonatomic, weak) id <XLRequestDelegate> delegate;

/** 请求头 */
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

/** JSON数据字符串 */
@property (nonatomic, strong, readonly) NSString *responseString;

/** JSON对象 */
@property (nonatomic, strong, readonly) id responseJSONObject;

/** 处理过后的JSON数据（模型化/格式化） */
@property (nonatomic, strong, readonly) id treatedDataObject;

/** HTTP状态码 */
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;

@property (nonatomic, copy) XLRequestSuccessBlock successCompletionBlock;

@property (nonatomic, copy) XLRequestFailureBlcok failureCompletionBlock;

/** 存放遵循代理的对象，插件 */
@property (nonatomic, strong) NSMutableArray *requestAccessories;

#pragma mark - public

- (void)start;

- (void)stop;

- (void)startWithCompletionBlockWithSuccess:(XLRequestSuccessBlock)success
                                    failure:(XLRequestFailureBlcok)failure;

- (void)clearCompletionBlock;

/**
 添加遵循XLRequestAccessory协议的对象到数组
 */
- (void)addAccessory:(id<XLRequestAccessory>)accessory;

#pragma mark - override for subclass

/**
 请求成功的回调
 */
- (void)requestCompleteHandler;

/**
 请求失败的回调
 */
- (void)requestFailedHandler;

/**
 请求的URL
 */
- (NSString *)requestUrl;

/**
 请求的BaseURL
 */
- (NSString *)baseUrl;

/**
 请求的连接超时时间，默认为60秒
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 请求的参数列表
 */
- (id)requestArgument;

/**
 Http请求的方法
 */
- (XLRequestMethod)requestMethod;

/**
 请求的SerializerType
 */
- (XLRequestSerializerType)requestSerializerType;

/**
 在HTTP报头添加的自定义参数
 */
- (NSDictionary *)requestHeaderFieldValueDictionary;

/**
 处理请求返回的原始数据
 */
- (id)treatedDataObject;


/**
 用于检查Status Code是否正常的方法
 */
- (BOOL)statusCodeValidator;

@end
