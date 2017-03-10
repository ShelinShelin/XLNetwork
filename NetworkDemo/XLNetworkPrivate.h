//
//  XLNetworkPrivate.h
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLBaseRequest.h"
#import "XLChainRequest.h"

typedef NS_ENUM(NSInteger, XLNetworkReachabilityStatus) {
    XLNetworkReachabilityWifi,
    XLNetworkReachabilityUnknown,
    XLNetworkReachabilityWWAN,
    XLNetworkReachabilityNotReachable
};



@interface XLNetworkPrivate : NSObject

+ (NSString*)responseObjectToJSONStr:(id)object;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)appVersionString;
;
+ (BOOL)checkNetworkStatus;

+ (XLNetworkReachabilityStatus)currentNetworkStatus;

@end

#pragma mark - YTKBaseRequest 分类

@interface XLBaseRequest (RequestAccessory)    //插件机制

- (void)accessoriesWillStartCallBack;
- (void)accessoriesWillStopCallBack;
- (void)accessoriesDidStopCallBack;

@end

#pragma mark - XLChainRequest 分类

@interface XLChainRequest (RequestAccessory)

- (void)accessoriesWillStartCallBack;
- (void)accessoriesWillStopCallBack;
- (void)accessoriesDidStopCallBack;

@end

