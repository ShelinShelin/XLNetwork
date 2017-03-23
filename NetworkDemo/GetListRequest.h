//
//  GetListRequest
//  NetworkDemo
//
//  Created by Shelin on 16/6/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLRequest.h"

//

@interface GetListRequest : XLRequest

- (instancetype)initWithCityId:(NSString *)cityId
                          page:(NSNumber *)page;

@end
