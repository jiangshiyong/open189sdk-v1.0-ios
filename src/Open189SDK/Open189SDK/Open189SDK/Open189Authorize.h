//
//  Open189Authorize.h
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Open189Request.h"
#import "Open189AuthorizeWebView.h"

@class Open189Authorize;

@protocol Open189AuthorizeDelegate <NSObject>

@required

- (void)authorize:(Open189Authorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken userID:(NSString *)userID expiresIn:(NSInteger)seconds;

- (void)authorize:(Open189Authorize *)authorize didFailWithError:(NSError *)error;

- (void)authorize:(Open189Authorize *)authorize didFailWithErrorCode:(NSString *)theErrorCode errorMessage:(NSString *)res_message;

@end

@interface Open189Authorize : NSObject <Open189AuthorizeWebViewDelegate, Open189RequestDelegate>{


    
    NSString    *appKey;
    NSString    *appSecret;
    
    NSString    *redirectURI;
    
    Open189Request   *request;
    
    UIViewController *rootViewController;
    Open189AuthorizeWebView *myWebView;
    id<Open189AuthorizeDelegate> delegate;
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, retain) Open189Request *request;
@property (nonatomic, assign) UIViewController *rootViewController;
@property (nonatomic, retain) Open189AuthorizeWebView *myWebView;

@property (nonatomic, assign) id<Open189AuthorizeDelegate> delegate;

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;

- (void)startAuthorize;
- (void)startAuthorizeUsingUserID:(NSString *)userID password:(NSString *)password;

@end
