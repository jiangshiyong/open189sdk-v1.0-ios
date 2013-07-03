//
//  Open189Authorize.m
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import "Open189Authorize.h"
#import "Open189Request.h"
#import "Open189SDKGlobal.h"

@interface Open189Authorize ()

- (void)dismissModalViewController;
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;
- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password;

@end

@implementation Open189Authorize
@synthesize appKey;
@synthesize appSecret;
@synthesize redirectURI;
@synthesize request;
@synthesize rootViewController;
@synthesize myWebView;
@synthesize delegate;


- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init])
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
    }
    
    return self;
}

- (void)dealloc
{
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    
    [redirectURI release], redirectURI = nil;
    
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    [myWebView release],myWebView = nil;
    rootViewController = nil;
    delegate = nil;
    
    [super dealloc];
}

#pragma mark - WBAuthorize Private Methods

- (void)dismissModalViewController
{
    [rootViewController dismissModalViewControllerAnimated:YES];
}

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"app_id",appSecret, @"app_secret",
                            @"authorization_code", @"grant_type",
                            redirectURI, @"redirect_uri",
                            code, @"code", nil];
    [request disconnect];
    
    self.request = [Open189Request requestWithURL:kOpen189AccessTokenURL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kOpen189RequestPostDataTypeNormal
                            httpHeaderFields:nil
                                    delegate:self];
    
    [request connect];
}

- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
                            appSecret, @"client_secret",
                            @"password", @"grant_type",
                            redirectURI, @"redirect_uri",
                            userID, @"username",
                            password, @"password", nil];
    
    [request disconnect];
    
    self.request = [Open189Request requestWithURL:kOpen189AccessTokenURL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kOpen189RequestPostDataTypeNormal
                            httpHeaderFields:nil
                                    delegate:self];
    
    [request connect];
}

#pragma mark - WBAuthorize Public Methods

- (void)startAuthorize
{
    /*
    //IC模式
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"app_id",appSecret, @"app_secret",
                            @"touch", @"display",
                            @"token", @"response_type",
                            redirectURI, @"redirect_uri",nil];
    NSString *urlString = [Open189Request serializeURL:kOpen189AuthorizeURL
                                           params:params
                                       httpMethod:@"GET"];
    //NSLog(@"urlString  ====%@",urlString);
    Open189AuthorizeWebView *webView = [[Open189AuthorizeWebView alloc] init];
     self.myWebView = webView;
    [self.myWebView setDelegate:self];
    [self.myWebView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [self.myWebView show:YES];
    [webView release];
    */
    //AC模式
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"app_id",appSecret, @"app_secret",
                            @"touch", @"display",
                            @"code", @"response_type",
                            redirectURI, @"redirect_uri",nil];
    NSString *urlString = [Open189Request serializeURL:kOpen189AuthorizeURL
                                                params:params
                                            httpMethod:@"GET"];
    //NSLog(@"urlString  ====%@",urlString);
    Open189AuthorizeWebView *webView = [[Open189AuthorizeWebView alloc] init];
    self.myWebView = webView;
    [self.myWebView setDelegate:self];
    [self.myWebView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [self.myWebView show:YES];
    [webView release];
}

- (void)startAuthorizeUsingUserID:(NSString *)userID password:(NSString *)password
{
    [self requestAccessTokenWithUserID:userID password:password];
}

#pragma mark - Open189AuthorizeWebViewDelegate Methods

- (void)authorizeWebView:(Open189AuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code res_code:(NSString *)rescode
{
    [webView hide:YES];
    
    // if not canceled
    if ([rescode isEqualToString:@"0"])
    {
        [self requestAccessTokenWithAuthorizeCode:code];
    }
}

- (void)authorizeWebView:(Open189AuthorizeWebView *)webView didSucceedWithAccessToken:(NSString *)theAccessToken refreshToken:(NSString *)refreshToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds {
    
    [webView hide:YES];
    if ([delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:refreshToken:userID:expiresIn:)])
    {
        [delegate authorize:self didSucceedWithAccessToken:theAccessToken  refreshToken:refreshToken userID:theUserID expiresIn:seconds];
    }
}

- (void)authorizeWebView:(Open189AuthorizeWebView *)webView didFailWithErrorCode:(NSString *)theErrorCode errorMessage:(NSString *)res_message {
    
    [webView hide:YES];
    if ([delegate respondsToSelector:@selector(authorize:didFailWithErrorCode:errorMessage:)])
    {
        [delegate authorize:self didFailWithErrorCode:theErrorCode  errorMessage:res_message];
    }
}

#pragma mark - Open189RequestDelegate Methods

- (void)request:(Open189Request *)theRequest didFinishLoadingWithResult:(id)result
{
    BOOL success = NO;
    
    NSDictionary *dict = (NSDictionary *)result;
    NSLog(@"dict===%@",dict);
    NSString *token = [dict objectForKey:@"access_token"];
    NSString *refreshtoken = [dict objectForKey:@"refresh_token"];
    NSString *userID = [dict objectForKey:@"open_id"];
    NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
    if (!refreshtoken) {
        refreshtoken = @"";
    }
    
    
    success = token && userID;
    
    if (success && [delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:refreshToken:userID:expiresIn:)])
    {
        [delegate authorize:self didSucceedWithAccessToken:token  refreshToken:refreshtoken userID:userID expiresIn:seconds];
    }
    
    
    // should not be possible
    if (!success && [delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        NSError *error = [NSError errorWithDomain:kOpen189SDKErrorDomain
                                             code:kOpen189ErrorCodeSDK
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kOpen189SDKErrorCodeAuthorizeError]
                                                                              forKey:kOpen189SDKErrorCodeKey]];
        [delegate authorize:self didFailWithError:error];
    }
}

- (void)request:(Open189Request *)theReqest didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        [delegate authorize:self didFailWithError:error];
    }
}


@end
