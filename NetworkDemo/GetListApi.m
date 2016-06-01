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

//?cityId=1&page=0"
- (NSString *)requestUrl {
    return @"https://api.108tian.com/mobile/v3/Home";
}

- (id)requestArgument {
    return @{
             @"cityId" : _cityId,
             @"page" : _page
             };
}

@end
