//
//  Md5Helper.m
//  SmsHelper
//
//  Created by kai li on 12-11-20.
//  Copyright (c) 2012年 ffcs. All rights reserved.
//

#import "Md5Helper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Md5Helper

+ (NSString *)md5HexDigest:(NSString *)input{
    const char *str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    
    for(int i=0; i<CC_MD5_DIGEST_LENGTH; i++){
        [ret appendFormat:@"%02X",result[i]];
    }
    
    return ret;
}
@end
