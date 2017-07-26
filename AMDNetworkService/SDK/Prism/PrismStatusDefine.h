//
//  PrismStatusDefine.h
//  AMDNetworkService
//
//  Created by SunSet on 2017/7/25.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#ifndef PrismStatusDefine_h
#define PrismStatusDefine_h


typedef NS_ENUM(NSUInteger, PrismErrorCode) {
    /*!
     缺少参数
     
     @discussion missing param '%s'
     */
    PE_MISS_PARAM = 40005,
    
    /*!
     签名不正确
     
     @discussion access denied, sign error
     */
    PE_SIGN_INVALID = 40301,
    
    /*!
     clientId不对
     
     @discussion access denied, client_id error
     */
    PE_CLIENTID_ERROR = 40302,
    
    /*!
     key 过期
     
     @discussion access denied, key expired
     */
    PE_KEY_EXPIRED = 40303,
    
    /*!
     secret 错误
     
     @discussion access denied, secret error
     */
    PE_SECRET_INVALID = 40304,
    
    /*!
     app 错误
     
     @discussion access denied, app error
     */
    PE_APP_INVALID = 40305,
    
    /*!
     app 不可用
     
     @discussion access denied, app is disabled
     */
    PE_APP_DISABLED = 40306,
    
    /*!
     签名时间 格式错误
     
     @discussion access denied, sign_time format error
     */
    PE_SIGNTIME_INVALID = 40307,
    
    /*!
     签名时间过期
     
     @discussion access denied, sign_time is out of date
     */
    PE_SIGNTIME_EXPIRED = 40308,
    
    /*!
     app没有权限调用当前api
     
     @discussion access denied, app can not call the api
     */
    PE_PERMISSION_INVALID = 40309,
    
    /*!
     请求需要Token
     
     @discussion access denied, oauth access token required
     */
    PE_TOKEN_REQUIRED = 40310,
    
    /*!
     请求超过限制 流控
     
     @discussion access denied, out of limit, waiting for %d seconds
     */
    PE_LIMIT_OUT = 40311,
    
    /*!
     用户名或密码错误
     
     @discussion 	access denied, username password are not match
     */
    PE_PASSWORD_INVALID = 40312,
    
    /*!
     app 不存在
     
     @discussion api not exists
     */
    PE_APP_NOTEXIST = 0040400,
    
    /*!
     method 不存在
     
     @discussion method not exists
     */
    PE_METHOD_NOTEXIST = 0040401,
    
    /*!
     后台 错误
     
     @discussion backend error
     */
    PE_BACKEND_ERROR = 0050400,
    
    /*
     预留错误
     
     @discussion backend error
     */
    Prism_UnknowError = -1,
    
};




#endif /* PrismStatusDefine_h */

















