//
//  ViewController.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/10.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "ViewController.h"
#import "GetListApi.h"

@interface ViewController () <XLRequestDelegate, XLRequestAccessory>

@end

@implementation ViewController {
    NSInteger _currentPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    GetListApi *api = [[GetListApi alloc] initWithCityId:@"1" page:@(_currentPage)];
    
    api.delegate = self;
//    [api addAccessory:self];
    [api start];
    
    _currentPage++;
    
    /*
    [api startWithCompletionBlockWithSuccess:^(XLBaseRequest *request) {
        XLLog(@"------ %ld --------", request.responseStatusCode);
    } failure:^(XLBaseRequest *request) {
        
    }];
     */
}



#pragma mark - XLRequestDelegate

- (void)requestFinished:(XLBaseRequest *)request {
    
    XLLog(@"------ %@ --------", request.responseJSONObject);
}

- (void)requestFailed:(XLBaseRequest *)request {

}

#pragma mark - XLRequestAccessory

- (void)requestWillStart:(id)request {
    XLLog(@"requestWillStart");
}

- (void)requestWillStop:(id)request {
    XLLog(@"requestWillStop");
}

- (void)requestDidStop:(id)request {
    XLLog(@"requestDidStop");
}

@end
