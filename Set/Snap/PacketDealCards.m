//
//  PacketDealCards.m
//  Snap
//
//  Created by Adrian on 15/5/7.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//

#import "PacketDealCards.h"
#import "NSData+SnapAdditions.h"

@implementation PacketDealCards


+ (id)packetWithCards:(NSDictionary *)cards
{
    return [[[self class] alloc] initWithCards:cards];
}

- (id)initWithCards:(NSDictionary *)cards
{
    self = [super initWithInsideType:PacketTypeDealCards];
    if (self) {
        self.cards = cards;
    }
    return self;
}

+ (id)packetWithData:(NSData *)data
{
    size_t offset = PACKET_HEADER_SIZE;
//    size_t count;
    
    NSDictionary *cards = [self cardsFromData:data atOffset:offset];
    
    return [[self class] packetWithCards:cards];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [self addCards:self.cards toPayload:data];
}

@end
