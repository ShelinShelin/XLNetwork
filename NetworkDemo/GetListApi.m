//
//  GetListApi.m
//  NetworkDemo
//
//  Created by Shelin on 16/6/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "GetListApi.h"

@implementation GetListApi {
    NSString *_cityId;
    NSNumber *_page;
}

- (instancetype)initWithCityId:(NSString *)cityId page:(NSNumber *)page {
    if (self = [super init]) {
        _cityId = cityId;
        _page = page;
    }
    return self;
}

- (NSString *)baseUrl {
    return @"https://api.108tian.com";
}

- (NSString *)requestUrl {
    return @"/mobile/v3/Home";
}

- (id)requestArgument {
    return @{
             @"cityId" : _cityId,
             @"page" : _page
             };
}

- (id)treatedDataObject {
    
    XLLog(@"----- treating 处理JSON数据 -------");
    
    return self.responseString;
}

- (NSInteger)cacheTimeInSeconds {
    return 10;
}

@end
