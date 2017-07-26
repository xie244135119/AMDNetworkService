//
//  NSHttpRequest.m
//  AMDNetworkService
//
//  Created by SunSet on 2017/7/25.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "NSHttpRequest.h"

@interface NSHttpRequest()

@end

@implementation NSHttpRequest


- (void)dealloc
{
    self.requestParams = nil;
    self.urlPath = nil;
    self.completion = nil;
}



#pragma mark - private api

- (NSRequestType)type
{
    return (_type == 0)?NSRequestGET:_type;
}



@end








