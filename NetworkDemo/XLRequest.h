//
//  XLRequest.h
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLBaseRequest.h"
#import "XLNetworkPrivate.h"

@interface XLRequest : XLBaseRequest

@property (nonatomic, assign) BOOL ignoreCache;

/**
 返回当前缓存的对象
 */
- (id)cacheJson;

/**
 是否当前的数据从缓存获得
 */
- (BOOL)isDataFromCache;

/**
 强制更新缓存，发起网络请求
 */
- (void)startWithoutCache;

/**
 手动将其他请求的JsonResponse写入该请求的缓存
 */
- (void)saveJsonResponseToCacheFile:(id)jsonResponse;

// For subclass to overwrite

/**
 缓存有效时间，单位s
 */
- (NSInteger)cacheTimeInSeconds;

@end
