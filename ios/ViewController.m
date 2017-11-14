//
//  ViewController.m
//  ios
//
//  Created by SunSet on 2017/7/25.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "ViewController.h"
#import "NSApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self test];
//    [self testSign];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)clickTest:(id)sender
{
    [self test];
}


- (void)test
{
    [NSApi registerHostUrl:[NSURL URLWithString:@"https://openapi.wdwd.com"]];
//    [NSApi registerPrismKey:@"msubxgez" secret:@"3dhx34sm7ryr6x22lvsj"];
    [NSApi registerUserAgent:@{@"wdwd": @"1.0.0"}];
//    [NSApi registerHostUrl:[NSURL URLWithString:@"https://openapi.you.163.com/channel/api.json"]];
    
    NSHttpConfiguration *configuration = [[NSHttpConfiguration alloc]init];
    configuration.animated = YES;
    configuration.animateView = self.view;
    NSHttpRequest *request = [[NSHttpRequest alloc]initWithConfiguration:configuration];
    request.type = NSRequestPOST;
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


- (void)test2
{
    // http://www.sojson.com/open/api/weather/json.shtml?city=北京
    
    [NSApi registerHostUrl:[NSURL URLWithString:@"https://www.sojson.com"]];
    //    [NSApi registerPrismKey:@"msubxgez" secret:@"3dhx34sm7ryr6x22lvsj"];
    [NSApi registerUserAgent:@{@"wdwd": @"1.0.0"}];
    
    NSHttpConfiguration *configuration = [[NSHttpConfiguration alloc]init];
    configuration.animated = YES;
    configuration.animateView = self.view;
    NSHttpRequest *request = [[NSHttpRequest alloc]initWithConfiguration:configuration];
//    request.type = NSRequestPOST;
    //    request.requestParams = @{@"data":@""};
    request.urlPath = @"/open/api/weather/json.shtml?city=bj";
    request.completion = ^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@" 错误提示:%@ ", error.localizedDescription);
            return ;
        }
        
        NSLog(@" 请求到的数据 %@",responseObject);
    };
    [[NSApi shareInstance] sendReq:request];
}





@end
