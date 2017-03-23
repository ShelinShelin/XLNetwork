//
//  ViewController.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/10.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "ViewController.h"
#import "GetListRequest.h"

@interface ViewController () <XLRequestDelegate, XLRequestPlugin>

@end

@implementation ViewController {
    NSInteger _currentPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChange:)
                                                 name:XLNetworkStatusChangeNotification
                                               object:nil];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    GetListRequest *request = [[GetListRequest alloc] initWithCityId:@"1" page:@(_currentPage)];
    request.delegate = self;
    [request addRequestPlugin:self];
    [request start];
    
    _currentPage++;
    
    
    /*
    [request startWithCompletionBlockWithSuccess:^(XLBaseRequest *request) {
        XLLog(@"------ %ld --------", request.responseStatusCode);
    } failure:^(XLBaseRequest *request) {
        
    }];
     */
}

#pragma mark - XLRequestDelegate

- (void)requestSucceed:(XLBaseRequest *)request {
    
}

- (void)requestFailed:(XLBaseRequest *)request {

}

#pragma mark - XLRequestplugin

- (void)requestWillStart:(id)request {
    XLLog(@"requestWillStart");
}

- (void)requestWillStop:(id)request {
    XLLog(@"requestWillStop");
}

- (void)requestDidStop:(id)request {
    XLLog(@"requestDidStop");
}

#pragma mark - XLNetworkStatusChangeNotification

- (void)networkStatusChange:(NSNotification *)notif {
    XLLog(@"-- %@ --", notif.object);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:XLNetworkStatusChangeNotification
                                                  object:nil];
}

@end
