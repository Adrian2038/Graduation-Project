//
//  Packet.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Packet.h"

#import "NSData+SnapAdditions.h"

@implementation Packet

+ (id)packetWithType:(PacketType)packetType
{
    return [[[self class] alloc] initWithType:packetType];
}

- (id)initWithType:(PacketType)packetType
{
    self = [super init];
    if (self) {
        self.packetType = packetType;
    }
    
    return self;
}

- (NSData *)data
{
    NSMutableData *data = [NSMutableData dataWithCapacity:100];
    
    [data rw_appendInt32:'SNAP'];  // 0x534E4150
    [data rw_appendInt32:0];
    [data rw_appendInt16:self.packetType];
    
    return data;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, type = %d", [super description], self.packetType];
}

@end
