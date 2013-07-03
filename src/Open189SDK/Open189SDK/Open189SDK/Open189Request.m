//
//  Open189Request.m
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import "Open189Request.h"
#import "Open189Util.h"
#import "JSON.h"

#import "Open189SDKGlobal.h"

#define kOpen189RequestTimeOutInterval   180.0
#define kOpen189RequestStringBoundary    @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw"

@interface Open189Request ()

+ (NSString *)stringFromDictionary:(NSDictionary *)dict;
+ (NSString *)createAuthValue:(NSDictionary *)params;

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString;
- (NSMutableData *)postBody;

- (void)handleResponseData:(NSData *)data;
- (id)parseJSONData:(NSData *)data error:(NSError **)error;

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (void)failedWithError:(NSError *)error;
@end

@implementation Open189Request
@synthesize url;
@synthesize httpMethod;
@synthesize params;
@synthesize postDataType;
@synthesize httpHeaderFields;
@synthesize delegate;


#pragma mark - WBRequest Life Circle

- (void)dealloc
{
    [url release], url = nil;
    [httpMethod release], httpMethod = nil;
    [params release], params = nil;
    [httpHeaderFields release], httpHeaderFields = nil;
    
    [responseData release];
	responseData = nil;
    
    [connection cancel];
    [connection release], connection = nil;
    
    [super dealloc];
}

#pragma mark - WBRequest Private Methods

+ (NSString *)stringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)createAuthValue:(NSDictionary *)dict {
    
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@:%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@""];
}

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData *)postBody
{
    NSMutableData *body = [NSMutableData data];
    
    if (postDataType == kOpen189RequestPostDataTypeNormal)
    {
        [Open189Request appendUTF8Body:body dataString:[Open189Request stringFromDictionary:params]];
    }
    else if (postDataType == kOpen189RequestPostDataTypeMultipart)
    {
        NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", kOpen189RequestStringBoundary];
		NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", kOpen189RequestStringBoundary];
        
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        
        [Open189Request appendUTF8Body:body dataString:bodyPrefixString];
        
        for (id key in [params keyEnumerator])
		{
			if (([[params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[params valueForKey:key] isKindOfClass:[NSData class]]))
			{
				[dataDictionary setObject:[params valueForKey:key] forKey:key];
				continue;
			}
			
			[Open189Request appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [params valueForKey:key]]];
			[Open189Request appendUTF8Body:body dataString:bodyPrefixString];
		}
		
		if ([dataDictionary count] > 0)
		{
			for (id key in dataDictionary)
			{
				NSObject *dataParam = [dataDictionary valueForKey:key];
				
				if ([dataParam isKindOfClass:[UIImage class]])
				{
					NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
					[Open189Request appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n", key]];
					[Open189Request appendUTF8Body:body dataString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:imageData];
				}
				else if ([dataParam isKindOfClass:[NSData class]])
				{
					[Open189Request appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key]];
					[Open189Request appendUTF8Body:body dataString:@"Content-Type: content/unknown\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:(NSData*)dataParam];
				}
				[Open189Request appendUTF8Body:body dataString:bodySuffixString];
			}
		}
    }
    
    return body;
}

- (void)handleResponseData:(NSData *)data
{
    if ([delegate respondsToSelector:@selector(request:didReceiveRawData:)])
    {
        [delegate request:self didReceiveRawData:data];
    }
	
	NSError* error = nil;
	id result = [self parseJSONData:data error:&error];
	
	if (error)
	{
		[self failedWithError:error];
	}
	else
	{
        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)])
		{
            [delegate request:self didFinishLoadingWithResult:(result == nil ? data : result)];
		}
	}
}

- (id)parseJSONData:(NSData *)data error:(NSError **)error
{
	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
	
	NSError *parseError = nil;
	id result = [jsonParser objectWithString:dataString error:&parseError];
	
	if (parseError)
    {
        if (error != nil)
        {
            *error = [self errorWithCode:kOpen189ErrorCodeSDK
                                userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kOpen189SDKErrorCodeParseError]
                                                                     forKey:kOpen189SDKErrorCodeKey]];
        }
	}
    
	[dataString release];
	[jsonParser release];
	
    
	if ([result isKindOfClass:[NSDictionary class]])
	{
		if ([result objectForKey:@"error_code"] != nil && [[result objectForKey:@"error_code"] intValue] != 200)
		{
			if (error != nil)
			{
				*error = [self errorWithCode:kOpen189ErrorCodeInterface userInfo:result];
			}
		}
	}
	
	return result;
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:kOpen189SDKErrorDomain code:code userInfo:userInfo];
}

- (void)failedWithError:(NSError *)error
{
	if ([delegate respondsToSelector:@selector(request:didFailWithError:)])
	{
		[delegate request:self didFailWithError:error];
	}
}

#pragma mark - WBRequest Public Methods

+ (Open189Request *)requestWithURL:(NSString *)url
                   httpMethod:(NSString *)httpMethod
                       params:(NSDictionary *)params
                 postDataType:(Open189RequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<Open189RequestDelegate>)delegate
{
    Open189Request *request = [[[Open189Request alloc] init] autorelease];
    
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.postDataType = postDataType;
    request.httpHeaderFields = httpHeaderFields;
    request.delegate = delegate;
    
    return request;
}

+ (Open189Request *)requestWithAccessToken:(NSString *)accessToken
                                  url:(NSString *)url
                           httpMethod:(NSString *)httpMethod
                               params:(NSDictionary *)params
                         postDataType:(Open189RequestPostDataType)postDataType
                     httpHeaderFields:(NSDictionary *)httpHeaderFields
                             delegate:(id<Open189RequestDelegate>)delegate
{
    // add the access token field
    return [Open189Request requestWithURL:url
                          httpMethod:httpMethod
                              params:params
                        postDataType:postDataType
                    httpHeaderFields:httpHeaderFields
                            delegate:delegate];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    if (![httpMethod isEqualToString:@"GET"])
    {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
    NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
    NSString *query = [Open189Request stringFromDictionary:params];
    return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix,query];
}

+ (Open189Request *)requestWithURL:(NSString *)url {
    
    Open189Request *request = [[[Open189Request alloc] init] autorelease];
    request.url = url;
    return request;
}

- (NSData *)connect:(NSString *)urlString{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:kOpen189RequestTimeOutInterval];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    return returnData;
}


- (void)connect
{
    
    NSString *urlString = [Open189Request serializeURL:url params:params httpMethod:httpMethod];
    NSLog(@"urlString======%@",urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:kOpen189RequestTimeOutInterval];
    
    [request setHTTPMethod:httpMethod];
    
    if ([httpMethod isEqualToString:@"POST"])
    {
        if (postDataType == kOpen189RequestPostDataTypeMultipart)
        {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kOpen189RequestStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }

        [request setHTTPBody:[self postBody]];
    }

    for (NSString *key in [httpHeaderFields keyEnumerator])
    {
        
        NSString *value=[httpHeaderFields objectForKey:key];

        [request setValue:value forHTTPHeaderField:key];
    }

    NSLog(@"Here's the request headers: %@", [request allHTTPHeaderFields]);
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)disconnect
{
    [responseData release];
	responseData = nil;
    
    [connection cancel];
    [connection release], connection = nil;
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	responseData = [[NSMutableData alloc] init];
	
	if ([delegate respondsToSelector:@selector(request:didReceiveResponse:)])
    {
		[delegate request:self didReceiveResponse:response];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	[self handleResponseData:responseData];
    
	[responseData release];
	responseData = nil;
    
    [connection cancel];
	[connection release];
	connection = nil;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	[self failedWithError:error];
	
	[responseData release];
	responseData = nil;
    
    [connection cancel];
	[connection release];
	connection = nil;
}





@end
