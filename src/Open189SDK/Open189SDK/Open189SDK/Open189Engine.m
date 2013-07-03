//
//  Open189Engine.m
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import "Open189Engine.h"

#import "SFHFKeychainUtils.h"
#import "Open189SDKGlobal.h"
#import "Open189Util.h"

#define kOpen189URLSchemePrefix              @"Open189_"

#define kOpen189KeychainServiceNameSuffix    @"_Open189ServiceName"
#define kOpen189KeychainUserID               @"Open189UserID"
#define kOpen189KeychainAccessToken          @"Open189AccessToken"
#define kOpen189KeyRefreshToken              @"Open189RefreshToken"
#define kOpen189KeychainExpireTime           @"Open189ExpireTime"


@interface Open189Engine (Private)

- (NSString *)urlSchemeString;

- (void)saveAuthorizeDataToKeychain;
- (void)readAuthorizeDataFromKeychain;
- (void)deleteAuthorizeDataInKeychain;

@end

@implementation Open189Engine
@synthesize appKey;
@synthesize appSecret;
@synthesize userID;
@synthesize accessToken;
@synthesize refresh_token;

@synthesize expireTime;
@synthesize redirectURI;
@synthesize isUserExclusive;
@synthesize isRefreshTokenSuccess;
@synthesize request;
@synthesize authorize;
@synthesize delegate;
@synthesize rootViewController;

#pragma mark - WBEngine Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init])
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
        
        self.redirectURI = kOpen189REDIRECT_URI;
        isUserExclusive = NO;
        
        [self readAuthorizeDataFromKeychain];
    }
    
    return self;
}

- (void)dealloc
{
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    
    [userID release], userID = nil;
    [accessToken release], accessToken = nil;
    [refresh_token release],refresh_token = nil;
    [redirectURI release], redirectURI = nil;
    
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    
    [authorize setDelegate:nil];
    [authorize release], authorize = nil;
    
    delegate = nil;
    rootViewController = nil;
    
    [super dealloc];
}


#pragma mark - Open189Engine Private Methods

- (NSString *)urlSchemeString
{
    return [NSString stringWithFormat:@"%@%@", kOpen189URLSchemePrefix, appKey];
}

- (void)saveAuthorizeDataToKeychain
{
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kOpen189KeychainServiceNameSuffix];
    [SFHFKeychainUtils storeUsername:kOpen189KeychainUserID andPassword:userID forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:kOpen189KeychainAccessToken andPassword:accessToken forServiceName:serviceName updateExisting:YES error:nil];
    [SFHFKeychainUtils storeUsername:kOpen189KeyRefreshToken andPassword:refresh_token forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:kOpen189KeychainExpireTime andPassword:[NSString stringWithFormat:@"%lf", expireTime] forServiceName:serviceName updateExisting:YES error:nil];
}

- (void)readAuthorizeDataFromKeychain
{
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kOpen189KeychainServiceNameSuffix];
    self.userID = [SFHFKeychainUtils getPasswordForUsername:kOpen189KeychainUserID andServiceName:serviceName error:nil];
    self.accessToken = [SFHFKeychainUtils getPasswordForUsername:kOpen189KeychainAccessToken andServiceName:serviceName error:nil];
    self.refresh_token = [SFHFKeychainUtils getPasswordForUsername:kOpen189KeyRefreshToken andServiceName:serviceName error:nil];
    self.expireTime = [[SFHFKeychainUtils getPasswordForUsername:kOpen189KeychainExpireTime andServiceName:serviceName error:nil] doubleValue];
}

- (void)deleteAuthorizeDataInKeychain
{
    self.userID = nil;
    self.accessToken = nil;
    self.expireTime = 0;
    
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kOpen189KeychainServiceNameSuffix];
    [SFHFKeychainUtils deleteItemForUsername:kOpen189KeychainUserID andServiceName:serviceName error:nil];
	[SFHFKeychainUtils deleteItemForUsername:kOpen189KeychainAccessToken andServiceName:serviceName error:nil];
    [SFHFKeychainUtils deleteItemForUsername:kOpen189KeyRefreshToken andServiceName:serviceName error:nil];
	[SFHFKeychainUtils deleteItemForUsername:kOpen189KeychainExpireTime andServiceName:serviceName error:nil];
}

#pragma mark - Open189Engine Public Methods

#pragma mark - 获得无需用户授权的访问令牌UIAT
- (void)client_credentialsLogin {

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"app_id",
                            appSecret, @"app_secret",
                            @"client_credentials", @"grant_type",nil];
    
    [request disconnect];
    
    self.request = [Open189Request requestWithURL:kOpen189AccessTokenURL
                                       httpMethod:@"POST"
                                           params:params
                                     postDataType:kOpen189RequestPostDataTypeNormal
                                 httpHeaderFields:nil
                                         delegate:self];
    
    [self.request connect];
    
}

#pragma mark - Authorization-用户授权

- (void)userLogIn
{
    if ([self isLoggedIn])
    {
        if ([delegate respondsToSelector:@selector(engineAlreadyLoggedIn:)])
        {
            [delegate engineAlreadyLoggedIn:self];
        }
        if (isUserExclusive)
        {
            return;
        }
    }
    
    Open189Authorize *auth = [[Open189Authorize alloc] initWithAppKey:appKey appSecret:appSecret];
    [auth setRootViewController:rootViewController];
    [auth setDelegate:self];
    self.authorize = auth;
    [auth release];
    
    if ([redirectURI length] > 0)
    {
        [authorize setRedirectURI:redirectURI];
    }
    else
    {
        [authorize setRedirectURI:@"http://"];
    }
    
    [authorize startAuthorize];
}

- (void)logInUsingUserID:(NSString *)theUserID password:(NSString *)thePassword
{
    self.userID = theUserID;
    
    if ([self isLoggedIn])
    {
        if ([delegate respondsToSelector:@selector(engineAlreadyLoggedIn:)])
        {
            [delegate engineAlreadyLoggedIn:self];
        }
        if (isUserExclusive)
        {
            return;
        }
    }
    
    Open189Authorize *auth = [[Open189Authorize alloc] initWithAppKey:appKey appSecret:appSecret];
    [auth setRootViewController:rootViewController];
    [auth setDelegate:self];
    self.authorize = auth;
    [auth release];
    
    if ([redirectURI length] > 0)
    {
        [authorize setRedirectURI:redirectURI];
    }
    else
    {
        [authorize setRedirectURI:@"http://"];
    }
    
    [authorize startAuthorizeUsingUserID:theUserID password:thePassword];
}

- (void)logOut
{
    [self deleteAuthorizeDataInKeychain];
    
    //添加非授权登录
    [self client_credentialsLogin];
    
    if ([delegate respondsToSelector:@selector(engineDidLogOut:)])
    {
        [delegate engineDidLogOut:self];
    }
}

- (BOOL)isLoggedIn
{
    //    return userID && accessToken && refreshToken;
    return userID && accessToken &&refresh_token&& (expireTime > 0);
}

- (BOOL)isClientLoggedIn {

    return accessToken&&(expireTime > 0);
}

- (BOOL)isAuthorizeExpired
{
    if ([[NSDate date] timeIntervalSince1970] > expireTime)
    {
        //刷新token
        if (refresh_token&&![refresh_token isEqualToString:@""]) {
            
            [self refreshAccessToken];
        }else{
        
            // force to log out
            //[self deleteAuthorizeDataInKeychain];
        }
        return YES;
    }
    return NO;
}

- (void)refreshAccessToken {

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"app_id",appSecret, @"app_secret",@"refresh_token", @"grant_type",refresh_token,@"refresh_token",nil];
    
    [request disconnect];
    
    self.request = [Open189Request requestWithURL:kOpen189AccessTokenURL
                                       httpMethod:@"POST"
                                           params:params
                                     postDataType:kOpen189RequestPostDataTypeNormal
                                 httpHeaderFields:nil
                                         delegate:self];
    
    [self.request connect];
}


#pragma mark - Request——已经授权的接口请求
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(Open189RequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
{
    // Step 1.
    // Check if the user has been logged in.
	if (![self isLoggedIn])
	{
        
        if ([delegate respondsToSelector:@selector(engineNotAuthorized:)])
        {
            [delegate engineNotAuthorized:self];
        }
        return;
	}
    
	// Step 2.
    // Check if the access token is expired.
    if ([self isAuthorizeExpired])
    {
        if ([delegate respondsToSelector:@selector(engineAuthorizeExpired:)])
        {
            [delegate engineAuthorizeExpired:self];
        }
        return;
    }
    
    [request disconnect];

//    self.request = [Open189Request requestWithAccessToken:accessToken
//                                                 url:[NSString stringWithFormat:@"%@%@", kOpen189SDKAPIDomain, methodName]
//                                          httpMethod:httpMethod
//                                              params:params
//                                        postDataType:postDataType
//                                    httpHeaderFields:httpHeaderFields
//                                            delegate:self];
    
    self.request = [Open189Request requestWithURL:methodName
                                       httpMethod:httpMethod
                                           params:params
                                     postDataType:postDataType
                                 httpHeaderFields:httpHeaderFields
                                         delegate:self];
	[request connect];
}


#pragma mark - ClientRequest ——非授权使用低级令牌的请求

- (void)clientLoadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(Open189RequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
{
    // Step 1.
    // Check if the user has been logged in.
	if (![self isClientLoggedIn])
	{
        //直接再UIAT授权一次 （User-Independent Access Token，简称UIAT）
        
        if ([delegate respondsToSelector:@selector(engineUIATNotAuthorized:)])
        {
            [delegate engineUIATNotAuthorized:self];
        }
        return;
	}
    
	// Step 2.
    // Check if the access token is expired.
    if ([self isAuthorizeExpired])
    {
        //直接再UIAT授权一次User-Independent Access Token，简称UIAT
        if ([delegate respondsToSelector:@selector(engineUIATAuthorizeExpired:)])
        {
            [delegate engineUIATAuthorizeExpired:self];
        }
        return;
    }
    
    [request disconnect];
    
//    self.request = [Open189Request requestWithAccessToken:accessToken
//                                                      url:[NSString stringWithFormat:@"%@%@", kOpen189SDKAPIDomain, methodName]
//                                               httpMethod:httpMethod
//                                                   params:params
//                                             postDataType:postDataType
//                                         httpHeaderFields:httpHeaderFields
//                                                 delegate:self];
    
    self.request = [Open189Request requestWithURL:methodName
                                       httpMethod:httpMethod
                                           params:params
                                     postDataType:postDataType
                                 httpHeaderFields:httpHeaderFields
                                         delegate:self];
	[request connect];
}

#pragma mark - Open189AuthorizeDelegate Methods

- (void)authorize:(Open189Authorize *)authorize didSucceedWithAccessToken:(NSString *)theAccessToken refreshToken:(NSString *)refreshToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds
{
    NSLog(@"theAccessToken=====%@",theAccessToken);
    self.accessToken = theAccessToken;
    self.refresh_token = refreshToken;
    self.userID = theUserID;
    self.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;
    
    [self saveAuthorizeDataToKeychain];
    
    if ([delegate respondsToSelector:@selector(engineDidLogIn:)])
    {
        [delegate engineDidLogIn:self];
    }
}

- (void)authorize:(Open189Authorize *)authorize didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(engine:didFailToLogInWithError:)])
    {
        [delegate engine:self didFailToLogInWithError:error];
    }
}

- (void)authorize:(Open189Authorize *)authorize didFailWithErrorCode:(NSString *)theErrorCode errorMessage:(NSString *)res_message {


}

#pragma mark - Open189RequestDelegate Methods

- (void)request:(Open189Request *)request didFinishLoadingWithResult:(id)result
{
    NSLog(@"返回==========%@",result);
    NSDictionary *dict = (NSDictionary *)result;
    //NSLog(@"====%@",[[dict objectForKey:@"queryBillboardListResponse"] objectForKey:@"desc"]);
    if ([dict objectForKey:@"access_token"]) {
        
        self.accessToken = [dict objectForKey:@"access_token"];
        self.expireTime= [[NSDate date] timeIntervalSince1970]+[[dict objectForKey:@"expires_in"] doubleValue];
        [self saveAuthorizeDataToKeychain];
        
    }
    if ([delegate respondsToSelector:@selector(engine:requestDidSucceedWithResult:)])
    {
        [delegate engine:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(Open189Request *)request didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(engine:requestDidFailWithError:)])
    {
        [delegate engine:self requestDidFailWithError:error];
    }
}


@end
