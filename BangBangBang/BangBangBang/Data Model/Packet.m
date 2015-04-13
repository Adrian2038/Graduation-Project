//
//  Packet.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Packet.h"
#import "PacketSignInResponse.h"
#import "PacketServerReady.h"

#import "NSData+SnapAdditions.h"

const size_t PACKET_HEADER_SIZE = 10;

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

+ (id)packetWithData:(NSData *)data
{
    if (data.length < PACKET_HEADER_SIZE) {
        NSLog(@"Error : packet too small");
        return nil;
    }
    
    if ([data rw_int32AtOffset:0] != 'SNAP') {
        NSLog(@"Error : packet has valid header");
        return nil;
    }
    
    int packetNumber = [data rw_int32AtOffset:4];
    PacketType packetType = [data rw_int16AtOffset:8];
    
    Packet *packet;
    
    switch (packetType) {
        case PacketTypeSignInRequest:
        case PacketTypeClientReady:
            packet = [Packet packetWithType:packetType];
            break;
            
        case PacketTypeSignInResponse:
            packet = [PacketSignInResponse packetWithData:data];
            break;
            
        case PacketTypeServerReady:
            packet = [PacketServerReady packetWithData:data];
            break;
            
        default:
            NSLog(@"Packet has invalid type");
            break;
    }
    
    return packet;
}

- (NSData *)data
{
    NSMutableData *data = [NSMutableData dataWithCapacity:100];
    
    [data rw_appendInt32:'SNAP'];  // 0x534E4150
    [data rw_appendInt32:0];
    [data rw_appendInt16:self.packetType];
    
    [self addPayloadToData:data];
    
    return data;
}

- (void)addPayloadToData:(NSMutableData *)data
{
    // base dose nothig,subclass override it,and do some stuff.
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, type = %d", [super description], self.packetType];
}

@end
