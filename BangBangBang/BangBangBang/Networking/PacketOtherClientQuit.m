//
//  PacketOtherClientQuit.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "PacketOtherClientQuit.h"
#import "NSData+SnapAdditions.h"

@implementation PacketOtherClientQuit

@synthesize peerID = _peerID;

+ (id)packetWithPeerID:(NSString *)peerID
{
    return [[[self class] alloc] initWithPeerID:peerID];
}

- (id)initWithPeerID:(NSString *)peerID
{
    if ((self = [super initWithInsideType:PacketTypeOtherClientQuit]))
    {
        self.peerID = peerID;
    }
    return self;
}

+ (id)packetWithData:(NSData *)data
{
    size_t offset = PACKET_HEADER_SIZE;
    size_t count;
    
    NSString *peerID = [data rw_stringAtOffset:offset bytesRead:&count];
    
    return [[self class] packetWithPeerID:peerID];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data rw_appendString:self.peerID];
}

@end
