//
//  PacketDealCards.m
//  BangBangBang
//
//  Created by Adrian on 15/4/27.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "PacketDealCards.h"
#import "NSData+SnapAdditions.h"

@implementation PacketDealCards

+ (id)packetWithCards:(NSDictionary *)cards startingWithPlayerPeerID:(NSString *)startingPeerID
{
    return [[[self class] alloc] initWithCards:cards startingWithPlayerPeerID:startingPeerID];
}

- (id)initWithCards:(NSDictionary *)cards startingWithPlayerPeerID:(NSString *)startingPeerID
{
    self = [super initWithInsideType:PacketTypeDealCards];
    if (self) {
        self.cards = cards;
        self.startingPeerID = startingPeerID;
    }
    return self;
}

+ (id)packetWithData:(NSData *)data
{
    size_t offset = PACKET_HEADER_SIZE;
    size_t count;
    
    NSString *startingPeerID = [data rw_stringAtOffset:offset bytesRead:&count];
    offset += count;
    
    NSDictionary *cards = [[self class] cardsFromData:data atOffset:offset];

    return [[self class] packetWithCards:cards startingWithPlayerPeerID:startingPeerID];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data rw_appendString:self.startingPeerID];
    [self addCards:self.cards toPayload:data];
}

@end
