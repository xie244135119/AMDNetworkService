//
//  Constants.h
//  PrismIOS
//
//  Created by SunSet on 14-8-27.
//  Copyright (c) 2014年 SunSet. All rights reserved.
//

#ifndef PrismIOS_Constants_h
#define PrismIOS_Constants_h

static NSString const *CLIENT_ID = @"client_id";
static NSString const *SIGN_METHOD = @"sign_method";
static NSString const *SIGN_TIME = @"sign_time";
static NSString const *SIGN = @"sign";
static NSString const *CLIENT_SECRET = @"client_secret";
static NSString const *REDIRECT_URL = @"redirect_uri";

static NSString const *GRANT_TYPE= @"grant_type";
static NSString *kAuthorizationCode = @"authorization_code";

static NSString const *CODE = @"code";

//跳转的地址
static NSString const *REDIRECT_URLINFO = @"http://example.com/oauth-callback";


//用户登录操作地址
static NSString const *kAuthorizeURL = @"/oauth/authorize";
//获取token地址
static NSString *kGetTokenURL = @"/oauth/token";



#endif


