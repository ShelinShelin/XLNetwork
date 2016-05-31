//
//  XLRequest.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLRequest.h"

@interface XLRequest ()

@property (strong, nonatomic) id cacheJson;

@end

@implementation XLRequest {
    BOOL _dataFromCache;
}

#pragma mark - public

- (id)cacheJson {
    return nil;
}

- (BOOL)isDataFromCache {
    return YES;
}

- (BOOL)isCacheVersionExpired {
    return YES;
}

- (void)startWithoutCache {
    
}

- (void)saveJsonResponseToCacheFile:(id)jsonResponse {

}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (long long)cacheVersion {
    return 0;
}

#pragma mark - privite



@end
