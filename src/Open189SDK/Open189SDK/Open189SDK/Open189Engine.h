//
//  Open189Engine.h
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Open189Authorize.h"
#import "Open189Request.h"

@class Open189Engine;

@protocol Open189EngineDelegate <NSObject>

@optional

// If you try to log in with logIn or logInUsingUserID method, and
// there is already some authorization info in the Keychain,
// this method will be invoked.
// You may or may not be allowed to continue your authorization,
// which depends on the value of isUserExclusive.
- (void)engineAlreadyLoggedIn:(Open189Engine *)engine;

// Log in successfully.
- (void)engineDidLogIn:(Open189Engine *)engine;

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(Open189Engine *)engine didFailToLogInWithError:(NSError *)error;

// Log out successfully.
- (void)engineDidLogOut:(Open189Engine *)engine;

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(Open189Engine *)engine;//未授权
- (void)engineAuthorizeExpired:(Open189Engine *)engine;//授权过期

//UIAT模式下
- (void)engineUIATNotAuthorized:(Open189Engine *)engine;//未授权
- (void)engineUIATAuthorizeExpired:(Open189Engine *)engine;//授权过期

- (void)engine:(Open189Engine *)engine requestDidFailWithError:(NSError *)error;
- (void)engine:(Open189Engine *)engine requestDidSucceedWithResult:(id)result;

@end

@interface Open189Engine : NSObject<Open189AuthorizeDelegate, Open189RequestDelegate> {

    NSString        *appKey;
    NSString        *appSecret;
    
    NSString        *userID;
    NSString        *accessToken;
    NSString        *refresh_token;
    NSTimeInterval  expireTime;//授权时间
    
    NSString        *redirectURI;
    
    // Determine whether user must log out before another logging in.
    BOOL            isUserExclusive;
    BOOL            isRefreshTokenSuccess;//刷新token是否成功返回，yes成功，no失败
    Open189Request       *request;
    Open189Authorize     *authorize;
    
    id<Open189EngineDelegate> delegate;
    
    UIViewController *rootViewController;

}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *refresh_token;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, retain) NSString *redirectURI;

@property (nonatomic, assign) BOOL isUserExclusive;
@property (nonatomic, assign) BOOL isRefreshTokenSuccess;

@property (nonatomic, retain) Open189Request *request;
@property (nonatomic, retain) Open189Authorize *authorize;
@property (nonatomic, assign) id<Open189EngineDelegate> delegate;
@property (nonatomic, assign) UIViewController *rootViewController;

// Initialize an instance with the AppKey and the AppSecret you have for your client.
- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;

// 获得无需用户授权的访问令牌UIAT
- (void)client_credentialsLogin;

// Log in using OAuth Web authorization.
// If succeed, engineDidLogIn will be called.
- (void)userLogIn;

// Log in using OAuth Client authorization.
// If succeed, engineDidLogIn will be called.
- (void)logInUsingUserID:(NSString *)theUserID password:(NSString *)thePassword;

// Log out.
// If succeed, engineDidLogOut will be called.
- (void)logOut;

// Check if user has logged in, or the authorization is expired.
/*
 
 * 检查用户是否登录
 
 * 检查client_credentials 是否登录
 * 判断授权是否过期
 *
 * return       过期返回YES，未过期返回NO
 */
- (BOOL)isLoggedIn;
- (BOOL)isClientLoggedIn;
- (BOOL)isAuthorizeExpired;

/*
 * 刷新accessToken
 */
- (void)refreshAccessToken;

// @methodName: The interface you are trying to visit, exp, "v2/dm/randcode/token" for the user.

// @httpMethod: "GET" or "POST".
// @params: A dictionary that contains your request parameters.
// @postDataType: "GET" for kOpen189RequestPostDataTypeNone, "POST" for kOpen189RequestPostDataTypeNormal or kOpen189RequestPostDataTypeMultipart.
// @httpHeaderFields: A dictionary that contains HTTP header information.
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(Open189RequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields;


- (void)clientLoadRequestWithMethodName:(NSString *)methodName
                             httpMethod:(NSString *)httpMethod
                                 params:(NSDictionary *)params
                           postDataType:(Open189RequestPostDataType)postDataType
                       httpHeaderFields:(NSDictionary *)httpHeaderFields;
@end
