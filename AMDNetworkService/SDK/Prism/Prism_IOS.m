//
//  PrismIOS.m
//  PrismIOS
//
//  Created by SunSet on 14-11-28.
//  Copyright (c) 2014年 SunSet. All rights reserved.
//

#import "Prism_IOS.h"
#import <CommonCrypto/CommonCrypto.h>
#import "Prism_Constants.h"
#import <UIKit/UIKit.h>

@interface Prism_IOS()

//@property(nonatomic,copy) NSString *hostIP ;        //主机ip

@end

@implementation Prism_IOS
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;

- (void)dealloc
{
//    self.hostIP = nil;
    _appKey = nil;
    _appSecret = nil;
    self.prismAccessToken = nil;
}

- (id)initWithAppKey:(NSString *)appkey
         appSecret:(NSString *)appsecret
{
    if (self = [super init]) {
//        self.hostIP = host;
        _appKey = appkey;
        _appSecret = appsecret;
    }
    return self;
}

- (NSMutableDictionary *)headers
{
    NSMutableDictionary *header = [[NSMutableDictionary alloc]init];
    if ([_prismAccessToken length] > 0) {
        [header setValue:[NSString stringWithFormat:@"Bearer %@",_prismAccessToken] forKey:@"Authorization"];
    }
    NSMutableString *ua = [[NSMutableString alloc]initWithFormat:@"PrismSDK/IOS;System/%@;DeviceModel/%@;DeviceVersion/%@;",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] localizedModel],[[UIDevice currentDevice] systemVersion]];
    [header setValue:ua forKey:@"User-Agent"];
    return header;
}

/**
 * http 需要走签名方式组装所有请求参数
 */
- (NSMutableDictionary *)assembleParams:(NSDictionary *)appParams
                             headers:(NSDictionary *)headers
                             urlPath:(NSString *)urlpath
                         httpRequestType:(NSInteger)type
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithObjects:@[self.appKey,[self currentTimeStamp]] forKeys:@[CLIENT_ID,SIGN_TIME]];
    if (appParams != nil) {
        [allParams addEntriesFromDictionary:appParams];
    }
    
    NSString *sign = [self sign:headers getParams:type==PrismHttpRequestGet||type==PrismHttpRequestDelete?allParams:nil postParams:type==PrismHttpRequestPUT||type==PrismHttpRequestPost?allParams:nil method:[self requestMethodWithType:type] path:urlpath];
    [allParams setObject:sign forKey:SIGN];
    return allParams;
}

/*
 * https安全传输方式---直接明值传输
 */
- (NSDictionary *)assembleGetParams:(NSDictionary *)appParams
{
    NSMutableDictionary *allparams = [NSMutableDictionary dictionaryWithObjects:@[self.appKey,self.appSecret] forKeys:@[CLIENT_ID,CLIENT_SECRET]];
    if (appParams != nil) {
        [allparams addEntriesFromDictionary:appParams];
    }
    return allparams;
}

/**
 * 执行签名
 * @param headerParams http头信息
 * @param getparams get参数 例如：将foo=1,bar=2,baz=3 排序为bar=2,baz=3,foo=1
 * @param postparams post参数
 * @param method http请求方式
 * @param path http请求path
 *
 */
- (NSString *)sign:(NSDictionary *)headerParams
         getParams:(NSDictionary *)getparams
        postParams:(NSDictionary *)postparams
            method:(NSString *)method
              path:(NSString *)path
{
    //header数据拼接字符串
    NSString *mixHeaderParams = [self mixHeaderParams:headerParams];
    //get数据拼接字符串
    NSString *mixGetParams = [self mixRequestParams:getparams];
    //post数据拼接字符串
    NSString *mixPostParams = [self mixRequestParams:postparams];
    //签名拼接字符串
    NSString *mixAllParams = [NSString stringWithFormat:@"%@&%@&%@&%@&%@&%@&%@",self.appSecret,method,[self encodeURL:path],[self encodeURL:mixHeaderParams],[self encodeURL:mixGetParams],[self encodeURL:mixPostParams],self.appSecret];
    
    return [[self encryptWithMD5:mixAllParams] uppercaseString];
}


/**
 * <p>根据参数名称将你的所有请求参数按照字母先后顺序排序:key + value .... key + value</p>
 * <p>对除签名和图片外的所有请求参数按key做的升序排列, value无需编码。
 * 例如：将foo=1,bar=2,baz=3 排序为bar=2,baz=3,foo=1
 * 参数名和参数值链接后，得到拼装字符串bar2baz3foo1</p>
 * @param headers 请求参数
 * @return 拼装字符串
 */
- (NSString *)mixHeaderParams:(NSDictionary *)headers
{
    if (headers == nil || headers.allKeys.count == 0) {
        return @"";
    }
    
    NSMutableString *query = [NSMutableString string];
    NSArray *headerKeys = [headers.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in headerKeys) {
        if ([key isEqualToString:@"Authorization"] || [key hasPrefix:@"X-Api-"]) {
            NSString *value = headers[key];
            [query appendFormat:@"%@=%@&",key,value];
        }
    }
    return query.length > 0?[query substringToIndex:query.length-1]:@"";
}

- (NSString *)mixRequestParams:(NSDictionary *)params
{
    if (params == nil || params.allKeys.count == 0) {
        return @"";
    }
    
    NSMutableString *query = [[NSMutableString alloc]init];
    NSArray *headerKeys = [params.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in headerKeys) {
        NSString *value = params[key];
        [query appendFormat:@"%@=%@&",key,value];
    }
    NSString *str = query.length > 0?[query substringToIndex:query.length-1]:@"";
    return str;
}


//URL编码
- (NSString*)encodeURL:(NSString *)string
{
    NSString *encodedValue = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,                                                                                                  (CFStringRef)string, nil, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    return encodedValue;
}


#pragma mark - GET
- (NSString *)appKey
{
    return _appKey.length>0?_appKey:@"";
}


- (NSString *)appSecret
{
    return _appSecret.length>0?_appSecret:@"";
}




#pragma mark - MD5加密
- (NSString *)encryptWithMD5:(NSString *)content
{
    const char *cStr = [content UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


#pragma mark - 相关处理
- (NSString *)currentTimeStamp
{
    NSString *timeSp = [[NSString alloc]initWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    return timeSp;
}


- (NSString *)requestMethodWithType:(NSInteger)type
{
    switch (type) {
        case PrismHttpRequestDelete:
            return @"DELETE";
            break;
        case PrismHttpRequestPUT:
            return @"PUT";
            break;
        case PrismHttpRequestPost:
            return @"POST";
            break;
        case PrismHttpRequestGet:
            return @"GET";
            break;
        default:
            return @"";
            break;
    }
}



@end











