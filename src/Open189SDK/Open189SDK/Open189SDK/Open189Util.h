//
//  Open189Util.h
//  Open189SDK
//
//  Created by user on 13-7-1.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

//Functions for Encoding Data.
@interface NSData (Open189Encode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
- (NSString *)base64EncodedString;
@end

//Functions for Encoding String.
@interface NSString (Open189Encode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
- (NSString *)base64EncodedString;
- (NSString *)URLEncodedString;
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding;
@end

@interface NSString (Open189Util)

+ (NSString *)GUIDString;

@end