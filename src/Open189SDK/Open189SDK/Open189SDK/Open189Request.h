//
//  Open189Request.h
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kOpen189RequestPostDataTypeNone,
	kOpen189RequestPostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	kOpen189RequestPostDataTypeMultipart,        // for uploading images and files.
}Open189RequestPostDataType;

@class Open189Request;

@protocol Open189RequestDelegate <NSObject>

@optional

- (void)request:(Open189Request *)request didReceiveResponse:(NSURLResponse *)response;

- (void)request:(Open189Request *)request didReceiveRawData:(NSData *)data;

- (void)request:(Open189Request *)request didFailWithError:(NSError *)error;

- (void)request:(Open189Request *)request didFinishLoadingWithResult:(id)result;

@end

@interface Open189Request : NSObject
{
    NSString                *url;
    NSString                *httpMethod;
    NSDictionary            *params;
    Open189RequestPostDataType   postDataType;
    NSDictionary            *httpHeaderFields;
    
    NSURLConnection         *connection;
    NSMutableData           *responseData;
    
    id<Open189RequestDelegate>   delegate;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSDictionary *params;
@property Open189RequestPostDataType postDataType;
@property (nonatomic, retain) NSDictionary *httpHeaderFields;
@property (nonatomic, assign) id<Open189RequestDelegate> delegate;

+ (Open189Request *)requestWithURL:(NSString *)url
                   httpMethod:(NSString *)httpMethod
                       params:(NSDictionary *)params
                 postDataType:(Open189RequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<Open189RequestDelegate>)delegate;

+ (Open189Request *)requestWithAccessToken:(NSString *)accessToken
                                  url:(NSString *)url
                           httpMethod:(NSString *)httpMethod
                               params:(NSDictionary *)params
                         postDataType:(Open189RequestPostDataType)postDataType
                     httpHeaderFields:(NSDictionary *)httpHeaderFields
                             delegate:(id<Open189RequestDelegate>)delegate;
+ (Open189Request *)requestWithURL:(NSString *)url;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;

- (void)connect;

- (NSData *)connect:(NSString *)urlString;
- (void)disconnect;


@end
