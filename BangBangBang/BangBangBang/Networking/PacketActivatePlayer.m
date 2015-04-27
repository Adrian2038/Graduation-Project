//
//  PacketActivatePlayer.m
//  BangBangBang
//
//  Created by Adrian on 15/4/27.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "PacketActivatePlayer.h"
#import "NSData+SnapAdditions.h"

@implementation PacketActivatePlayer

+ (id)packetWithPeerID:(NSString *)peerID
{
    return [[[self class] alloc] initWithPeerID:peerID];
}

- (id)initWithPeerID:(NSString *)peerID
{
    self = [super initWithInsideType:PacketTypeActivatePlayer];
    if (self) {
        self.peerID = peerID;
    }
    return self;
}

+ (id)packetWithData:(NSData *)data
{
    size_t count;
    NSString *peerID = [data rw_stringAtOffset:PACKET_HEADER_SIZE bytesRead:&count];
    return [[self class] packetWithPeerID:peerID];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data rw_appendString:self.peerID];
}

@end
