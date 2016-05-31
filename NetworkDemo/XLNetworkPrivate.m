//
//  XLNetworkPrivate.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/31.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLNetworkPrivate.h"

@implementation XLNetworkPrivate

@end

@implementation XLBaseRequest (RequestAccessory)

//从数组中取出遵循代理的对象，执行代理方法

- (void)accessoriesWillStartCallBack {
    
    for (id<XLRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestWillStart:)]) {
            [accessory requestWillStart:self];
        }
    }
}

- (void)accessoriesWillStopCallBack {
    for (id<XLRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestWillStop:)]) {
            [accessory requestWillStop:self];
        }
    }
}

- (void)accessoriesDidStopCallBack {
    for (id<XLRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestDidStop:)]) {
            [accessory requestDidStop:self];
        }
    }
}


@end
