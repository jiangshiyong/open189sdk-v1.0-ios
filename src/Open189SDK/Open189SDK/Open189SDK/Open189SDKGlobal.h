//
//  Open189SDKGlobal.h
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#define kOpen189SDKErrorDomain           @"Open189SDKErrorDomain"
#define kOpen189SDKErrorCodeKey          @"Open189SDKErrorCodeKey"


#define kOpen189AuthorizeURL     @"https://oauth.api.189.cn/emp/oauth2/v2/authorize"
#define kOpen189AccessTokenURL   @"https://oauth.api.189.cn/emp/oauth2/v2/access_token"

#define kOpen189SDKAPIDomain     @"http://api.189.cn/"

typedef enum
{
	kOpen189ErrorCodeInterface	= 100,
	kOpen189ErrorCodeSDK         = 101,
}Open189ErrorCode;

typedef enum
{
	kOpen189SDKErrorCodeParseError       = 200,
	kOpen189SDKErrorCodeRequestError     = 201,
	kOpen189SDKErrorCodeAccessError      = 202,
	kOpen189SDKErrorCodeAuthorizeError	= 203,
}Open189SDKErrorCode;


