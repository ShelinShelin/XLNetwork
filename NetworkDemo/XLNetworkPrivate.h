//
//  XLNetworkPrivate.h
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLBaseRequest.h"

@interface XLNetworkPrivate : NSObject

+ (NSString*)responseObjectToJSONStr:(id)object;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)appVersionString;

@end

#pragma mark - YTKBaseRequest 分类

@interface XLBaseRequest (RequestAccessory)    //插件机制

- (void)accessoriesWillStartCallBack;
- (void)accessoriesWillStopCallBack;
- (void)accessoriesDidStopCallBack;

@end

