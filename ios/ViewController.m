//
//  ViewController.m
//  ios
//
//  Created by SunSet on 2017/7/25.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "ViewController.h"
#import "NSApi.h"
#import "Prism_IOS.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self test];
    [self testSign];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)test
{
    [NSApi registerHostUrl:[NSURL URLWithString:@"http://openapi.sandbox.wdwd.com"]];
    [NSApi registerPrismKey:@"msubxgez" secret:@"3dhx34sm7ryr6x22lvsj"];
    [NSApi registerUserAgent:@{@"wdwd": @"1.0.0"}];
    
    NSHttpConfiguration *configuration = [[NSHttpConfiguration alloc]init];
    configuration.animated = YES;
    configuration.animateView = self.view;
    NSHttpRequest *request = [[NSHttpRequest alloc]initWithConfiguration:configuration];
    request.type = NSRequestGET;
//    request.requestParams = @{@"data":@""};
    request.urlPath = @"/api/nova-shop/admin/shop/register-phone/verify-code";
    request.completion = ^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@" 错误提示:%@ ", error.localizedDescription);
            return ;
        }
        
        NSLog(@" 请求到的数据 %@",responseObject);
    };
    [[NSApi shareInstance] sendReq:request];
}


- (void)testSign
{
//    NSString *signtime = @"1501044346";
    NSString *clientid = @"msubxgez";
    NSString *secret = @"3dhx34sm7ryr6x22lvsj";
    NSString *urlpath = @"/nova-shop/admin/shop/register-phone/verify-code";
    Prism_IOS *prism = [[Prism_IOS alloc]initWithAppKey:clientid appSecret:secret];
    NSDictionary *sign = [prism assembleParams:nil headers:nil urlPath:urlpath httpRequestType:1];
    NSLog(@" 签名:%@ ",sign);
    
}




@end
