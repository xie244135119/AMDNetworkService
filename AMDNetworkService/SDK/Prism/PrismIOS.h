//
//  PrismIOS.h
//  PrismIOS
//
//  Created by SunSet on 14-11-28.
//  Copyright (c) 2014年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrismStatusDefine.h"

//
static NSInteger const PrismHttpRequestTypeGet = 1;         //get
static NSInteger const PrismHttpRequestTypePost = 2;        //post方式
static NSInteger const PrismHttpRequestTypePUT = 3;         //put方式
static NSInteger const PrismHttpRequestTypeDelete = 4;      //delete方式

@interface PrismIOS : NSObject

//appkey 和 appsecret 可能改变
@property(nonatomic, copy, readonly) NSString *appKey;        //appkey
@property(nonatomic, copy, readonly) NSString *appSecret;     //appsecret

// oauth登录获取到的token(令牌)
// 注:当通过oauth服务取到的token需要赋值
@property(nonatomic,copy, readwrite) NSString *prismAccessToken;

/**
 *  唯一的实例化
 *
 *  @param appkey    Prism平台为应用分配的key
 *  @param appsecret Prism平台为应用分配的secret
 *
 *  @return Prism实例
 */
- (id)initWithAppKey:(NSString *)appkey
           appSecret:(NSString *)appsecret;


/**
 *  设置请求Header
 *
 *  @return 带token和userAgent的字典
 */
- (NSDictionary *)headers;


/**
 *  http方式 签名字段
 *
 *  @param appParams 传递的参数
 *  @param headers   请求header
 *  @param urlpath  url的后半部分
 *  @param type      请求类型详见头部 例PrismHttpRequestTypeGet
 *
 *  @return Prism平台验签需要的所有字段
 */
- (NSMutableDictionary *)assembleParams:(NSDictionary *)appParams
                                headers:(NSDictionary *)headers
                                urlPath:(NSString *)urlpath
                        httpRequestType:(NSInteger)type;

/**
 *  https方式 签名字段
 *
 *  @param appParams 请求传递的参数
 *
 *  @return Prism平台验签需要的所有字段
 */
- (NSMutableDictionary *)assembleGetParams:(NSDictionary *)appParams;


@end
