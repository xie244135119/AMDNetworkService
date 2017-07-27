//
//  NSApi.m
//  AMDNetworkService
//
//  Created by SunSet on 2017/7/25.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "NSApi.h"
#import "AFHTTPSessionManager+NSHttpCategory.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDNSPod.h"
#import "NSPrivateTool.h"
#import "PrismIOS.h"
#import <objc/objc.h>


// 固定的请求地址
static NSURL *_hostURL = nil;
// 固定的UserAgent
//static NSDictionary *_userAgentDict = nil;


@interface NSApi()
{
    NSDNSPod *_dnsPod;              //dns解析类
    NSDictionary *_userAgentDict;   //用户
}
// 请求类
@property(nonatomic, strong) AFHTTPSessionManager *httpSessionManager;
 // prism签名类
@property(nonatomic, strong) PrismIOS *prismIOS;
@end


@implementation NSApi

- (void)dealloc
{
    _dnsPod = nil;
    self.httpSessionManager = nil;
    self.prismIOS = nil;
}


+ (instancetype)shareInstance
{
    static NSApi *_api = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _api = [[NSApi alloc]init];
    });
    return _api;
}


#pragma mark - public api
//
- (BOOL)sendReq:(NSHttpRequest*)req
{
    // 加载动画
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [req performSelector:NSSelectorFromString(@"start") withObject:nil];
    
    
    // 处理完成事件
    __weak typeof(self) weakself = self;
    __block void (^completion)(id _Nonnull responseObject, NSError * _Nullable error)
    = ^(id _Nonnull responseObject, NSError * _Nonnull error){
        // prism错误提示语
        NSError *aerror = error;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"result"] isEqualToString:@"error"]) {
                NSDictionary *error = responseObject[@"error"];
//                NSInteger code = [error[@"code"] integerValue];
//                NSString *errordes = [weakself prismErrorFromCode:code];
                NSString *errordes = error[@"message"];
                aerror = [[NSError alloc]initWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:errordes}];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 关闭动画
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [req performSelector:NSSelectorFromString(@"end") withObject:nil];
            
            if (req.completion) {
                req.completion(responseObject, aerror);
            }
        });
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 请求参数
        NSDictionary *params = [weakself _completeParamsWithReq:req];
        // 请求地址
        NSString *url = [weakself _requestCompleteURLWithReq:req];
        // 发起请求
        [weakself _sendReq:req params:params url:url completion:completion];
    });
    
    
    return YES;
}

// 设置主机地址
+ (void)registerHostUrl:(NSURL *)hosturl
{
    // 固定请求地址
    if (_hostURL != hosturl) {
        _hostURL = hosturl;
    }
}

// 注册
+ (void)registerUserAgent:(NSDictionary *)userAgent
{
    NSApi *api = [NSApi shareInstance];
    api->_userAgentDict = userAgent;
}

//
+ (void)registerPrismKey:(NSString *)appKey
                secret:(NSString *)appSecret
{
    PrismIOS *prism = [NSApi shareInstance].prismIOS;
    [prism setValue:appKey forKey:@"appKey"];
    [prism setValue:appSecret forKey:@"appSecret"];
}



#pragma mark - private api
//
- (void)_sendReq:(NSHttpRequest *)req
          params:(NSDictionary *)params
             url:(NSString *)url
      completion:(void (^)(id _Nonnull responseObject, NSError * _Nullable error))completion
{
    switch (req.type) {
        case NSRequestPOST:          //请求方式
        {
            [self.httpSessionManager POST_AMD:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completion(responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error, id _Nonnull responseObject) {
                completion(responseObject, error);
            }];
        }
            break;
        case NSRequestPUT:          //请求方式
        {
            [self.httpSessionManager PUT_AMD:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completion(responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error, id _Nonnull responseObject) {
                completion(responseObject, error);
            }];
        }
            break;
        case NSRequestDelete:          //请求方式
        {
            [self.httpSessionManager DELETE_AMD:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completion(responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error, id _Nonnull responseObject) {
                completion(responseObject, error);
            }];
        }
            break;
        default:        //GEt
        {
            [self.httpSessionManager GET_AMD:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completion(responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error, id _Nonnull responseObject) {
                completion(responseObject, error);
            }];
        }
            break;
    }
}


// 完整的请求参数
- (NSDictionary *)_completeParamsWithReq:(NSHttpRequest *)req
{
    // 常规的参数 + 签名需要携带的参数 + 自定义的参数
//    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    // 签名的参数
    NSDictionary *signparam = nil;
    PrismIOS *_prism = self.prismIOS;
    if ([_hostURL.scheme isEqualToString:@"https"]) {
        signparam = [_prism assembleGetParams:req.requestParams];
    }
    else {
        signparam = [_prism assembleParams:req.requestParams headers:[_prism headers] urlPath:req.urlPath httpRequestType:req.type];
    }
//    [params addEntriesFromDictionary:signparam];
    return [self _buildParamsWithDict:signparam];
}


// 完整的请求地址
- (NSString *)_requestCompleteURLWithReq:(NSHttpRequest *)req
{
    // 域名+/api+urlpath部分 <api不能作为签名>
    NSString *hoststr = req.customHost?req.customHost:_hostURL.description;
    NSString *ipurl = [[self dnsPod] hostIPWithUrlStr:hoststr];
    return [ipurl stringByAppendingFormat:@"%@",req.urlPath];
}



// 签名类
- (PrismIOS *)prismIOS
{
    if (_prismIOS == nil) {
        _prismIOS = [[PrismIOS alloc]init];
    }
    return _prismIOS;
}


// dns解析类
- (NSDNSPod *)dnsPod
{
    if (_dnsPod == nil) {
        _dnsPod = [[NSDNSPod alloc]init];
    }
    return _dnsPod;
}


// 请求参数
- (AFHTTPSessionManager *)httpSessionManager
{
    if (_httpSessionManager == nil) {
        _httpSessionManager = [AFHTTPSessionManager manager];
        AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 验证域名
        [policy setValidatesDomainName:NO];
        // 允许无效证书
        [policy setAllowInvalidCertificates:YES];
        _httpSessionManager.securityPolicy = policy;
        
        // 添加header信息
        [_httpSessionManager.requestSerializer setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
        [_httpSessionManager.requestSerializer setValue:[self _localIP] forHTTPHeaderField:@"X-Forwarded-For"];
    }
    
    //设置 host 主机地址
    if (![_httpSessionManager.requestSerializer valueForHTTPHeaderField:@"Host"]) {
        [_httpSessionManager.requestSerializer setValue:_hostURL.host forHTTPHeaderField:@"Host"];
    }
    
    // 移除Access token <发生在重新登录过程中>
    NSDictionary *headers = [self prismIOS].headers;
    NSString *authorization = headers[@"Authorization"];
    [_httpSessionManager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    // 加载
    return _httpSessionManager;
}


//用户代理信息
- (NSString *)userAgent
{
    // 设置默认ua
    NSApi *api = [NSApi shareInstance];
    NSMutableString *defaultua = [[NSMutableString alloc]initWithString:[api.prismIOS headers][@"User-Agent"]];
    NSDictionary *identifier = _userAgentDict;
    if (identifier.allKeys.count > 0) {
        for (NSString *key in identifier.allKeys) {
            NSString *value = identifier[key];
            [defaultua appendFormat:@"%@/%@;",key,value];
        }
    }
    return defaultua;
}

//获取本机IP--不会变
- (NSString *)_localIP
{
    NSString *_localIP = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        _localIP = [NSPrivateTool localIP];
//    });
    return _localIP;
}


//#pragma mark - 统一处理请求结果
// 请求失败
//- (void)_handleCompletion:(id)responseObject
//              error:(NSError *)error
//{
//    // prism错误提示语
//    if ([responseObject isKindOfClass:[NSDictionary class]]) {
//        if ([responseObject[@"result"] isEqualToString:@"error"]) {
//            NSDictionary *error = responseObject[@"error"];
//            NSInteger code = [error[@"code"] integerValue];
//            NSString *errordes = [self prismErrorFromCode:code];
//            NSError *e = [[NSError alloc]initWithDomain:NSURLErrorDomain code:0 userInfo:@{NSURLErrorFailingURLErrorKey:errordes}];
//            if (_completion) {
//                _completion(responseObject, e);
//            }
//            return;
//        }
//    }
//    
//    if (_completion) {
//        _completion(responseObject, error);
//    }
//}




#pragma mark - 统一Prism错误提示语提示
//
- (NSString *)prismErrorFromCode:(NSInteger)code
{
    NSString *error = @"未知错误";
    switch (code) {
        case PE_LIMIT_OUT:
            error = @"请求超出限制,请稍后重试";
            break;
        case PE_MISS_PARAM:
            error = @"缺少参数";
            break;
        case PE_SIGN_INVALID:
            error = @"签名错误";
            break;
        case PE_CLIENTID_ERROR:
            error = @"clientid 错误";
            break;
        case PE_KEY_EXPIRED:
            error = @"key 过期";
            break;
        case PE_SECRET_INVALID:
            error = @"secret 错误";
            break;
        case PE_APP_INVALID:
            error = @"app 错误";
            break;
        case PE_APP_DISABLED:
            error = @"app 不可用";
            break;
        case PE_SIGNTIME_INVALID:
            error = @"签名时间错误";
            break;
        case PE_SIGNTIME_EXPIRED:
            error = @"签名时间过期";
            break;
        case PE_PERMISSION_INVALID:
            error = @"app缺少权限调用";
            break;
        case PE_TOKEN_REQUIRED:
            error = @"当前api请求需要token";
            break;
        case PE_PASSWORD_INVALID:
            error = @"用户名或密码错误";
            break;
        case PE_APP_NOTEXIST:
            error = @"app不存在";
            break;
        case PE_METHOD_NOTEXIST:
            error = @"方法不存在";
            break;
        case PE_BACKEND_ERROR:
            error = @"后台错误";
            break;
        default:
            break;
    }
    return error;
}


#pragma mark - private api
// af不支持二级参数 需要内部处理
- (NSDictionary *)_buildParamsWithDict:(NSDictionary *)dict
{
    NSMutableDictionary *params = dict.mutableCopy;
    // 并发处理
    [params enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonstr = [[NSString alloc]initWithData:data encoding:4];
            [params setObject:jsonstr forKey:key];
        }
    }];
    return params;
}





@end










