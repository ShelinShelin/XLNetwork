//
//  XLNetworkPrivate.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLNetworkPrivate.h"
#import <CommonCrypto/CommonDigest.h>

@implementation XLNetworkPrivate

+ (void)load {
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
}

+ (NSString*)responseObjectToJSONStr:(id)object {
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)md5StringFromString:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+ (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        XLLog(@"error to set do not backup attribute, error = %@", error);
    }
}

+ (NSString *)appVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)checkNetworkStatus {
    
    XLNetworkReachabilityStatus status = [XLNetworkPrivate currentNetworkStatus];
    
    if (status == XLNetworkReachabilityNotReachable) {
        return NO;
    } else {
        return YES;
    }
}

+ (XLNetworkReachabilityStatus)currentNetworkStatus {
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    if (reachabilityManager.isReachable) {
        if ([AFNetworkReachabilityManager sharedManager].isReachableViaWWAN) {
            return XLNetworkReachabilityWWAN;
        }
        if (reachabilityManager.isReachableViaWiFi) {
            return XLNetworkReachabilityWifi;
        }
        return XLNetworkReachabilityUnknown;
    }else{
        return XLNetworkReachabilityNotReachable;
    }
}

@end




@implementation XLBaseRequest (requestPlugin)

//从数组中取出遵循代理的对象，执行代理方法

- (void)requestPluginWillStartCallBack {
    
    for (id<XLRequestPlugin> requestPlugin in self.requestPlugins) {
        
        if ([requestPlugin respondsToSelector:@selector(requestWillStart:)]) {
            [requestPlugin requestWillStart:self];
        }
    }
}

- (void)requestPluginWillStopCallBack {
    for (id<XLRequestPlugin> requestPlugin in self.requestPlugins) {
        if ([requestPlugin respondsToSelector:@selector(requestWillStop:)]) {
            [requestPlugin requestWillStop:self];
        }
    }
}

- (void)requestPluginDidStopCallBack {
    for (id<XLRequestPlugin> requestPlugin in self.requestPlugins) {
        if ([requestPlugin respondsToSelector:@selector(requestDidStop:)]) {
            [requestPlugin requestDidStop:self];
        }
    }
}

@end




@implementation XLChainRequest (RequestPlugin)

- (void)requestPluginWillStartCallBack {
    for (id<XLRequestPlugin> requestPlugin in self.requestPlugins) {
        if ([requestPlugin respondsToSelector:@selector(requestWillStart:)]) {
            [requestPlugin requestWillStart:self];
        }
    }
}

- (void)requestPluginWillStopCallBack {
    for (id<XLRequestPlugin> requestPlugin in self.requestPlugins) {
        if ([requestPlugin respondsToSelector:@selector(requestWillStop:)]) {
            [requestPlugin requestWillStop:self];
        }
    }
}

- (void)requestPluginDidStopCallBack {
    for (id<XLRequestPlugin> requestPlugin in self.requestPlugins) {
        if ([requestPlugin respondsToSelector:@selector(requestDidStop:)]) {
            [requestPlugin requestDidStop:self];
        }
    }
}


@end
