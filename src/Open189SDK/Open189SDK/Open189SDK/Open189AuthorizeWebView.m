//
//  Open189AuthorizeWebView.m
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#define kOpen189REDIRECT_URI2     @"http://www.renren.com/bind/ty/tyLoginCallBack?"

#import "Open189AuthorizeWebView.h"
#import <QuartzCore/QuartzCore.h> 

@interface Open189AuthorizeWebView ()

- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;
- (void)bounceNormalAnimationStopped;
- (void)allAnimationsStopped;

- (UIInterfaceOrientation)currentOrientation;
- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation;
- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation;

- (void)addObservers;
- (void)removeObservers;

@end


@implementation Open189AuthorizeWebView
@synthesize webView;
@synthesize _cancelButton;
@synthesize delegate;

#pragma mark - WBAuthorizeWebView Life Circle

- (id)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 480)])
    {
        // background settings
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        // add the panel view
        panelView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 300, 440)];
        [panelView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.55]];
        [[panelView layer] setMasksToBounds:NO]; // very important
        [[panelView layer] setCornerRadius:10.0];
        [self addSubview:panelView];
        
        // add the conainer view
        containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 280, 420)];
        [[containerView layer] setBorderColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.7].CGColor];
        [[containerView layer] setBorderWidth:1.0];
        
        
        // add the web view
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, 280, 390)];
        webView.scalesPageToFit = NO;
        [webView setUserInteractionEnabled: YES];	 //是否支持交互
		[webView setDelegate:self];
        /*
         [webView stringByEvaluatingJavaScriptFromString:
         @"var script = document.createElement('script');"
         "script.type = 'text/javascript';"
         "script.text = \"function ResizeImages() { "
         "var myimg,oldwidth;"
         "var maxwidth=280;"//缩放系数
         "for(i=0;i <document.images.length;i++){"
         "myimg = document.images[i];"
         "if(myimg.width > maxwidth){"
         "oldwidth = myimg.width;"
         "myimg.width = maxwidth;"
         "myimg.height = myimg.height*(maxwidth/oldwidth);"
         "}"
         "}"
         "}\";"
         "document.getElementsByTagName('head')[0].appendChild(script);"];
         [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
        */
		[containerView addSubview:webView];
        
        [panelView addSubview:containerView];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake(160, 240)];
        [self addSubview:indicatorView];
        
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(panelView.frame.size.width-30, 0,35, 35);
        [_cancelButton setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [panelView addSubview:self._cancelButton];
    }
    return self;
}

- (void)dealloc
{
    [panelView release], panelView = nil;
    [containerView release], containerView = nil;
    [webView release], webView = nil;
    [indicatorView release], indicatorView = nil;
    [_cancelButton release],_cancelButton = nil;
    [super dealloc];
}

#pragma mark Actions

- (void)onCloseButtonTouched:(id)sender
{
    [self hide:YES];
}

#pragma mark Orientations

- (UIInterfaceOrientation)currentOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation
{
    [self setTransform:CGAffineTransformIdentity];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        [self setFrame:CGRectMake(0, 0, 480, 320)];
        [panelView setFrame:CGRectMake(10, 30, 460, 280)];
        [containerView setFrame:CGRectMake(10, 10, 440, 260)];
        [webView setFrame:CGRectMake(0, 0, 440, 260)];
        [indicatorView setCenter:CGPointMake(240, 160)];
    }
    else
    {
        [self setFrame:CGRectMake(0, 0, 320, 480)];
        [panelView setFrame:CGRectMake(10, 30, 300, 440)];
        [containerView setFrame:CGRectMake(10, 10, 280, 420)];
        [webView setFrame:CGRectMake(0, 0, 280, 420)];
        [indicatorView setCenter:CGPointMake(160, 240)];
        [self setCenter:CGPointMake(160, 240)];
    }
    
    [self setTransform:[self transformForOrientation:orientation]];
    
    previousOrientation = orientation;
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
		return CGAffineTransformMakeRotation(-M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
		return CGAffineTransformMakeRotation(M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
		return CGAffineTransformMakeRotation(-M_PI);
	}
    else
    {
		return CGAffineTransformIdentity;
	}
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == previousOrientation)
    {
		return NO;
	}
    else
    {
		return orientation == UIInterfaceOrientationLandscapeLeft
		|| orientation == UIInterfaceOrientationLandscapeRight
		|| orientation == UIInterfaceOrientationPortrait
		|| orientation == UIInterfaceOrientationPortraitUpsideDown;
	}
    return YES;
}

#pragma mark Obeservers

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}


#pragma mark Animations

- (void)bounceOutAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceInAnimationStopped)];
    [panelView setAlpha:0.8];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
	[UIView commitAnimations];
}

- (void)bounceInAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceNormalAnimationStopped)];
    [panelView setAlpha:1.0];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)];
	[UIView commitAnimations];
}

- (void)bounceNormalAnimationStopped
{
    [self allAnimationsStopped];
}

- (void)allAnimationsStopped
{
    // nothing shall be done here
}

#pragma mark Dismiss

- (void)hideAndCleanUp
{
    [self removeObservers];
	[self removeFromSuperview];
}

#pragma mark - WBAuthorizeWebView Public Methods

- (void)loadRequestWithURL:(NSURL *)url
{
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [webView loadRequest:request];
}

- (void)show:(BOOL)animated
{
    [self sizeToFitOrientation:[self currentOrientation]];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window)
    {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
  	[window addSubview:self];
    
    if (animated)
    {
        [panelView setAlpha:0];
        CGAffineTransform transform = CGAffineTransformIdentity;
        [panelView setTransform:CGAffineTransformScale(transform, 0.3, 0.3)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounceOutAnimationStopped)];
        [panelView setAlpha:0.5];
        [panelView setTransform:CGAffineTransformScale(transform, 1.1, 1.1)];
        [UIView commitAnimations];
    }
    else
    {
        [self allAnimationsStopped];
    }
    
    [self addObservers];
}

- (void)hide:(BOOL)animated
{
	if (animated)
    {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideAndCleanUp)];
		[self setAlpha:0];
		[UIView commitAnimations];
	}
    [self hideAndCleanUp];
}

- (void)close {
    
    [self hide:YES];
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods
- (void)deviceOrientationDidChange:(id)object
{
	UIInterfaceOrientation orientation = [self currentOrientation];
	if ([self shouldRotateToOrientation:orientation])
    {
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    /*
    //IC模式
    NSString *strRet=[webView.request.URL absoluteString];
    NSRange range = [strRet rangeOfString:kOpen189REDIRECT_URI2];
    if(range.length!=0)
    {
        //NSString *rescode = [webView.request.URL.absoluteString substringFromIndex:range.location + range.length];
        NSString *strParam = [strRet substringFromIndex:range.length];

        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [strParam componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            
            [queryStringDictionary setObject:value forKey:key];
        }

        NSString *access_tokenstr = [NSString stringWithFormat:@"%@",[queryStringDictionary objectForKey:@"access_token"]];
        NSString *res_codeStr = [NSString stringWithFormat:@"%@",[queryStringDictionary objectForKey:@"res_code"]];
        NSString *res_messageStr = [NSString stringWithFormat:@"%@",[queryStringDictionary objectForKey:@"res_message"]];
        NSString *open_idStr = [NSString stringWithFormat:@"%@",[queryStringDictionary objectForKey:@"open_id"]];
        NSInteger seconds = [[queryStringDictionary objectForKey:@"expires_in"] intValue];
        if ([res_messageStr isEqualToString:@"Success"]) {
            
            if ([delegate respondsToSelector:@selector(authorizeWebView:didSucceedWithAccessToken:refreshToken:userID:expiresIn:)])
            {
                [delegate authorizeWebView:self didSucceedWithAccessToken:access_tokenstr  refreshToken:@"" userID:open_idStr expiresIn:seconds];
            }
        }else{

            if ([delegate respondsToSelector:@selector(authorizeWebView: didFailWithErrorCode:errorMessage:)])
            {
                [delegate authorizeWebView:self didFailWithErrorCode:res_codeStr errorMessage:res_messageStr];
            }
        }
         [queryStringDictionary release];
    }
    */
    [indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
     //AC模式
     //NSLog(@"Open189Web页面返回=====%@",request.URL.absoluteString);
     NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
     if (range.location != NSNotFound)
     {
         NSString *query = [[request URL] query];
         
         NSString *codeForToken = [self valueForKey:@"code" ofQuery:query];
         NSString *rescode = [self valueForKey:@"res_code" ofQuery:query];
         if ([delegate respondsToSelector:@selector(authorizeWebView:didReceiveAuthorizeCode:res_code:)])
         {
             [delegate authorizeWebView:self didReceiveAuthorizeCode:codeForToken res_code:rescode];
         }
     }
    
    return YES;
}

#pragma mark -
#pragma mark private methods
-(NSString*) valueForKey:(NSString *)key ofQuery:(NSString*)query
{
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	for(NSString *aPair in pairs){
		NSArray *keyAndValue = [aPair componentsSeparatedByString:@"="];
		if([keyAndValue count] != 2) continue;
		if([[keyAndValue objectAtIndex:0] isEqualToString:key]){
			return [keyAndValue objectAtIndex:1];
		}
	}
	return nil;
}

@end
