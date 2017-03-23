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
    XLNetworkReachabilityUnknown = -1,
    XLNetworkReachabilityNotReachable = 0,
    XLNetworkReachabilityWWAN = 1,
    XLNetworkReachabilityWifi = 2
};

// 监听网络状态通知
static NSString *const XLNetworkStatusChangeNotification = @"NetworkDidChangeNotification";

@interface XLNetworkPrivate : NSObject

+ (NSString*)responseObjectToJSONStr:(id)object;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)appVersionString;

/**
 网络是否可用
 */
+ (BOOL)checkNetworkStatus;

/**
 获取当前网络状态
 */
+ (XLNetworkReachabilityStatus)currentNetworkStatus;

/**
 获取设备型号
 */
+ (NSString *)getCurrentDeviceModel;

@end

#pragma mark - XLBaseRequest 分类

@interface XLBaseRequest (RequestPlugin)    //插件机制

- (void)requestPluginWillStartCallBack;
- (void)requestPluginWillStopCallBack;
- (void)requestPluginDidStopCallBack;

@end

#pragma mark - XLChainRequest 分类

@interface XLChainRequest (RequestPlugin)

- (void)requestPluginWillStartCallBack;
- (void)requestPluginWillStopCallBack;
- (void)requestPluginDidStopCallBack;

@end

