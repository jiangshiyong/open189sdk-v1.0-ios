//
//  Open189AuthorizeWebView.h
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Open189AuthorizeWebView;

@protocol Open189AuthorizeWebViewDelegate <NSObject>
@optional

- (void)authorizeWebView:(Open189AuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code res_code:(NSString*)rescode;

- (void)authorizeWebView:(Open189AuthorizeWebView *)webView didSucceedWithAccessToken:(NSString *)theAccessToken refreshToken:(NSString *)refreshToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds;
- (void)authorizeWebView:(Open189AuthorizeWebView *)webView didFailWithErrorCode:(NSString *)theErrorCode errorMessage:(NSString *)res_message;
@end


@interface Open189AuthorizeWebView : UIView<UIWebViewDelegate>  {

    UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
    
    UIInterfaceOrientation previousOrientation;
    
    id<Open189AuthorizeWebViewDelegate> delegate;
    UIButton *_cancelButton;
    
}


@property (nonatomic, assign) id<Open189AuthorizeWebViewDelegate> delegate;
@property (nonatomic, retain) UIButton *_cancelButton;
@property (nonatomic, retain) UIWebView *webView;

- (void)loadRequestWithURL:(NSURL *)url;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

- (void)close;


@end
