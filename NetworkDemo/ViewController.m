//
//  ViewController.m
//  NetworkDemo
//
//  Created by Shelin on 16/5/10.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "ViewController.h"
#import "GetListApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    GetListApi *api = [[GetListApi alloc] initWithCityId:@"1" page:@0];
    
    [api startWithCompletionBlockWithSuccess:^(XLBaseRequest *request) {
        NSLog(@"------ %ld --------", request.responseStatusCode);
    } failure:^(XLBaseRequest *request) {
        
    }];

}

@end
