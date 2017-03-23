//
//  XLRequest.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLRequest.h"
#import "XLNetworkPrivate.h"

@interface XLRequest ()

@property (strong, nonatomic) id cacheJson;

@end

@implementation XLRequest {
    BOOL _dataFromCache;
}

#pragma mark - public

- (id)cacheJson {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        NSString *path = [self cacheFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
            _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
        return _cacheJson;
    }
}

- (BOOL)isDataFromCache {
    return _dataFromCache;
}

- (void)startWithoutCache {
    [super start];
}

/**
 手动将其他请求的JsonResponse写入该请求的缓存
 */
- (void)saveJsonResponseToCacheFile:(id)jsonResponse {
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        NSDictionary *json = jsonResponse;
        if (json != nil) {
            //归档
            [NSKeyedArchiver archiveRootObject:json toFile:[self cacheFilePath]];
        }
    }
}

#pragma mark - For subclass to overwrite

- (NSInteger)cacheTimeInSeconds {
    return -1;   //默认不缓存 <= 0
}

#pragma mark - privite

- (NSString *)cacheFileName {
    //请求地址
    NSString *requestUrl = [self requestUrl];
    //根路径
    NSString *baseUrl = self.baseUrl;
    //请求参数
    id argument = [self requestArgument];
    //请求方式、根路径、请求地址、请求参数、app版本号拼接再MD5作为缓存的文件名
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@ AppVersion:%@",
                             (long)[self requestMethod], baseUrl, requestUrl, argument, [XLNetworkPrivate appVersionString]];
    NSString *cacheFileName = [XLNetworkPrivate md5StringFromString:requestInfo];
    return cacheFileName;
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        XLLog(@"create cache directory failed, error = %@", error);
    } else {
        [XLNetworkPrivate addDoNotBackupAttribute:path];
    }
}

- (NSString *)cacheBasePath {
    
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];
    
    [self checkDirectory:path];
    
    return path;
}


- (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (NSString *)cacheFilePath {
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

/**
 获取文件上次修改时刻到现在的时间
 */
- (int)cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // get file attribute
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        XLLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }
    
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    
    return seconds;
}

#pragma mark - override

- (void)start {
    if (self.ignoreCache) {
        //如果忽略缓存 -> 网络请求
        [super start];
        return;
    }
    
    // check cache time
    if ([self cacheTimeInSeconds] < 0) {
        //验证缓存有效时间 -> 网络请求
        [super start];
        return;
    }
    
    // check cache existance
    NSString *path = [self cacheFilePath];  //
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        //根据文件路径，验证缓存是否存在，不存在 -> 网络请求
        [super start];
        return;
    }
    
    // check cache time 上次缓存文件时刻距离现在的时长 与 缓存有效时间 对比
    int seconds = [self cacheFileDuration:path];
    if (seconds < 0 || seconds > [self cacheTimeInSeconds]) {
        //上次缓存文件时刻距离现在的时长 > 缓存有效时间
        [super start];
        return;
    }
    
    // load cache
    _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (_cacheJson == nil) {    //取出缓存，如果没有 -> 网络请求
        [super start];
        return;
    }
    
    _dataFromCache = YES;
    //缓存请求成功后的数据
    
    [self requestCompleteHandler];   //调用成功代理方法
    
    XLRequest *strongSelf = self;
    
    [strongSelf.delegate requestSucceed:strongSelf];
    
    if (strongSelf.successCompletionBlock) {    //block回调
        strongSelf.successCompletionBlock(strongSelf);
    }
    
    [strongSelf clearCompletionBlock];
}

- (id)responseJSONObject {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        return [super responseJSONObject];
    }
}

#pragma mark - Network Request Delegate
//请求成功缓存数据
- (void)requestCompleteHandler {
    [super requestSucceedHandler];
    [self saveJsonResponseToCacheFile:[super responseJSONObject]];
}

@end
