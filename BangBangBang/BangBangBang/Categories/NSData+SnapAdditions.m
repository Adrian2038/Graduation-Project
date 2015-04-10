//
//  NSData+SnapAdditions.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "NSData+SnapAdditions.h"

@implementation NSData (SnapAdditions)

@end

@implementation NSMutableData (SnapAdditions)

- (void)rw_appendInt32:(int)value
{
    value = htonl(value);
    [self appendBytes:&value length:4];
}

- (void)rw_appendInt16:(short)value
{
    value = htons(value);
    [self appendBytes:&value length:2];
}

- (void)rw_appendInt8:(char)value
{
    [self appendBytes:&value length:1];
}

- (void)rw_appendString:(NSString *)string
{
    const char *cString = [string UTF8String];
    [self appendBytes:cString length:strlen(cString) + 1];
}

@end
