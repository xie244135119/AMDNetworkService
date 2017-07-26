//
//  NSHttpRequest.h
//  AMDNetworkService
//  基于AFNetwork的请求类<自带域名解析处理>
//  Created by SunSet on 2017/7/25.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSConstVar.h"


@interface NSHttpRequest : NSObject


#pragma mark - V1.0方案
// 请求类型
@property(nonatomic) NSRequestType type;
// 请求的参数类型
@property(nonatomic, strong) NSDictionary *requestParams;
// 请求的urlpath部分
@property(nonatomic, copy) NSString *urlPath;
// 请求完成事件
@property(nonatomic, copy) void(^completion)(id responseObject, NSError *error);




#pragma mark - 自定义域名相关
// 例如 https://openapi.wdwd.com 为nil时使用默认统一域名
@property(nonatomic, copy) NSString *customHost;



@end
























