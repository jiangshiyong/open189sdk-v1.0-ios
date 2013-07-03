//
//  ViewController.m
//  Open189SDKDemo
//
//  Created by user on 13-6-30.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize openEngine;
@synthesize textView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tianyi_43.png"] forBarMetrics:UIBarMetricsDefault];

    Open189Engine *engine = [[Open189Engine alloc] initWithAppKey:Open189APPKey appSecret:Open189APPSecret];
    [engine setRootViewController:self];
    [engine setDelegate:self];
    [engine setIsUserExclusive:NO];
    self.openEngine = engine;
    [engine release];
    
    UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(onLoginButtonPressed)];
    
    [self.navigationItem setRightBarButtonItem:rightBtn1];
    [rightBtn1 release];
    
    if (![openEngine isLoggedIn]){
        
        if (![openEngine isClientLoggedIn]) {
            
            [openEngine client_credentialsLogin];
        }else if ([openEngine isClientLoggedIn]&& ![openEngine isAuthorizeExpired]){
            
        }else if ([openEngine isClientLoggedIn]&& [openEngine isAuthorizeExpired]){
            
            [openEngine client_credentialsLogin];
        }
    }else if ([openEngine isLoggedIn]&& ![openEngine isAuthorizeExpired]){
    
        UIBarButtonItem *rightBtn2 = [[UIBarButtonItem alloc] initWithTitle:@"登出" style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onLogOutButtonPressed)];
        
        [self.navigationItem setRightBarButtonItem:rightBtn2];
        [rightBtn2 release];
    }else if ([openEngine isLoggedIn]&& [openEngine isAuthorizeExpired]){

    }
    
    UIButton *checkbutton1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    checkbutton1.frame = CGRectMake(0, 10, 130, 30);
    [checkbutton1 setTitle:@"获取音乐榜单" forState:(UIControlStateNormal)];
    [checkbutton1 addTarget:self action:@selector(getMusicInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkbutton1];
    
    UIButton *checkbutton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    checkbutton2.frame = CGRectMake(150, 10, 130, 30);
    [checkbutton2 setTitle:@"获取用户信息" forState:(UIControlStateNormal)];
    [checkbutton2 addTarget:self action:@selector(getUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkbutton2];
    
    UITextView *temptextView =[[UITextView alloc]initWithFrame:CGRectMake(10, 40, 240, self.view.frame.size.height-130)];
    self.textView = temptextView;
    [temptextView release];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:14.0];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
    
}
- (void)clientLogin{

    Open189Engine *engine = [[Open189Engine alloc] initWithAppKey:Open189APPKey appSecret:Open189APPSecret];
    [engine setRootViewController:self];
    [engine setDelegate:self];
    [engine setIsUserExclusive:NO];
    self.openEngine = engine;
    [engine release];
    
    [openEngine client_credentialsLogin];
}

- (void)getMusicInfo {


    Open189Engine *engine = [[Open189Engine alloc] initWithAppKey:Open189APPKey appSecret:Open189APPSecret];
    [engine setDelegate:self];
    [engine setIsUserExclusive:NO];
    self.openEngine = engine;
    [engine release];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params setObject:self.openEngine.accessToken forKey:@"access_token"];
    [params setObject:Open189APPKey forKey:@"app_id"];
    [self.openEngine clientLoadRequestWithMethodName:@"http://api.189.cn/imusic/content/contentBillboardservice/queryBillboardListInfo"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kOpen189RequestPostDataTypeNormal
                   httpHeaderFields:params];
}

- (void)getUserInfo {

    Open189Engine *engine = [[Open189Engine alloc] initWithAppKey:Open189APPKey appSecret:Open189APPSecret];
    [engine setDelegate:self];
    [engine setIsUserExclusive:NO];
    self.openEngine = engine;
    [engine release];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:@"json" forKey:@"type"];
    [params setObject:self.openEngine.accessToken forKey:@"access_token"];
	[params setObject:Open189APPKey forKey:@"app_id"];

    [self.openEngine loadRequestWithMethodName:@"http://api.189.cn/upc/real/age_and_sex"
                                    httpMethod:@"GET"
                                              params:params
                                        postDataType:kOpen189RequestPostDataTypeNone
                                    httpHeaderFields:nil];
}

- (void)onLogOutButtonPressed
{
    [openEngine logOut];

}

- (void)onLoginButtonPressed {

    [openEngine userLogIn];
}

- (void)engineAlreadyLoggedIn:(Open189Engine *)engine {

}

- (void)engineDidLogIn:(Open189Engine *)engine {

    
    UIBarButtonItem *rightBtn2 = [[UIBarButtonItem alloc] initWithTitle:@"登出" style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onLogOutButtonPressed)];
    
    [self.navigationItem setRightBarButtonItem:rightBtn2];
    [rightBtn2 release];
}

- (void)engine:(Open189Engine *)engine didFailToLogInWithError:(NSError *)error {

}

// Log out successfully.
- (void)engineDidLogOut:(Open189Engine *)engine {

    UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onLoginButtonPressed)];
    
    [self.navigationItem setRightBarButtonItem:rightBtn1];
    [rightBtn1 release];
}

- (void)engineNotAuthorized:(Open189Engine *)engine {

}

- (void)engineAuthorizeExpired:(Open189Engine *)engine {

    
}

//UIAT模式下
- (void)engineUIATNotAuthorized:(Open189Engine *)engine {

    
}

- (void)engineUIATAuthorizeExpired:(Open189Engine *)engine {

    [self clientLogin];
}

- (void)engine:(Open189Engine *)engine requestDidFailWithError:(NSError *)error {

}
- (void)engine:(Open189Engine *)engine requestDidSucceedWithResult:(id)result {

    if ([result isKindOfClass:[NSDictionary class]])
    {
    }
    self.textView.text = [NSString stringWithFormat:@"%@",result];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
