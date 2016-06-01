//
//  XLChainRequestAgent.m
//  NetworkDemo
//
//  Created by Shelin on 16/6/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLChainRequestAgent.h"

@interface XLChainRequestAgent()

@property (strong, nonatomic) NSMutableArray *requestArray;

@end

@implementation XLChainRequestAgent

#pragma mark - public

+ (XLChainRequestAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)addChainRequest:(XLChainRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeChainRequest:(XLChainRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

#pragma mark - init

- (id)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

@end
