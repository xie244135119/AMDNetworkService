# AMDNetworkService
network request 

通用封装的网络请求模块

Cocoapods 安装
pod 'AMDNetworkService'


请求实例:

        
      [NSApi registerHostUrl:[NSURL URLWithString:@"http://www.sojson.com"]];
      [NSApi registerUserAgent:@{@"wdwd": @"1.0.0"}];
      
    NSHttpConfiguration *configuration = [[NSHttpConfiguration alloc]init];
    configuration.animated = YES;
    configuration.animateView = self.view;
    NSHttpRequest *request = [[NSHttpRequest alloc]initWithConfiguration:configuration];
    //request.type = NSRequestPOST;
    //request.requestParams = @{@"data":@""};
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
