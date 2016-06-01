//
//  XLChainRequestAgent.h
//  NetworkDemo
//
//  Created by Shelin on 16/6/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLChainRequest.h"

@interface XLChainRequestAgent : NSObject

+ (XLChainRequestAgent *)sharedInstance;

- (void)addChainRequest:(XLChainRequest *)request;

- (void)removeChainRequest:(XLChainRequest *)request;

@end
