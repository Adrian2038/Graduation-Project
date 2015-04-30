//
//  Packet.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Packet.h"
#import "NSData+SnapAdditions.h"
#import "PacketSignInResponse.h"
#import "PacketServerReady.h"
#import "PacketOtherClientQuit.h"
#import "PacketDealCards.h"
#import "PacketActivatePlayer.h"
#import "Card.h"

const size_t PACKET_HEADER_SIZE = 10;

@implementation Packet

@synthesize packetType = _packetType;

+ (id)packetWithType:(PacketType)packetType
{
    return [[[self class] alloc] initWithInsideType:packetType];
}

+ (id)packetWithData:(NSData *)data
{
    if ([data length] < PACKET_HEADER_SIZE)
    {
        NSLog(@"Error: Packet too small");
        return nil;
    }
    
    if ([data rw_int32AtOffset:0] != 'SNAP')
    {
        NSLog(@"Error: Packet has invalid header");
        return nil;
    }
    
    int packetNumber = [data rw_int32AtOffset:4];
    PacketType packetType = [data rw_int16AtOffset:8];
    
    Packet *packet;
    
    switch (packetType)
    {
        case PacketTypeSignInRequest:
        case PacketTypeClientReady:
        case PacketTypeClientDealtCards:
        case PacketTypeClientTurnedCard:
        case PacketTypeServerQuit:
        case PacketTypeClientQuit:
            packet = [Packet packetWithType:packetType];
            break;
            
        case PacketTypeSignInResponse:
            packet = [PacketSignInResponse packetWithData:data];
            break;
            
        case PacketTypeServerReady:
            packet = [PacketServerReady packetWithData:data];
            break;
            
        case PacketTypeOtherClientQuit:
            packet = [PacketOtherClientQuit packetWithData:data];
            break;
            
        case PacketTypeDealCards:
            packet = [PacketDealCards packetWithData:data];
            break;
        
        case PacketTypeActivatePlayer:
            packet = [PacketActivatePlayer packetWithData:data];
            break;
            
        default:
            NSLog(@"Error: Packet has invalid type");
            return nil;
    }
    
    return packet;
}

- (id)initWithInsideType:(PacketType)packetType
{
    if ((self = [super init]))
    {
        self.packetType = packetType;
    }
    return self;
}

- (NSData *)data
{
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:100];
    
    [data rw_appendInt32:'SNAP'];   // 0x534E4150
    [data rw_appendInt32:0];
    [data rw_appendInt16:self.packetType];
    
    [self addPayloadToData:data];
    
    return data;
}

- (void)addPayloadToData:(NSMutableData *)data
{
    // base class does nothing
}

- (void)addCards:(NSDictionary *)cards toPayload:(NSMutableData *)data
{
    [cards enumerateKeysAndObjectsUsingBlock:^(id key , NSArray *arry , BOOL *stop)
    {
        [data rw_appendString:key];
        [data rw_appendInt8:[arry count]];
        
        for (int t = 0; t < [arry count]; ++t) {
            Card *card = [arry objectAtIndex:t];
            [data rw_appendInt8:card.suit];
            [data rw_appendInt8:card.value];
        }
    }];
}

- (NSMutableDictionary *)cardsFromData:(NSData *)data atOffset:(size_t)offset
{
    size_t count;
    
    NSMutableDictionary *cards = [NSMutableDictionary dictionaryWithCapacity:4];
    
    while (offset < [data length])
    {
        NSString *peerID = [data rw_stringAtOffset:offset bytesRead:&count];
        offset += count;
        
        int numberOfCards = [data rw_int8AtOffset:offset];
        offset += 1;
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:numberOfCards];
        
        for (int t = 0; t < numberOfCards; ++t)
        {
            int suit = [data rw_int8AtOffset:offset];
            offset += 1;
            
            int value = [data rw_int8AtOffset:offset];
            offset += 1;
            
            Card *card = [[Card alloc] initWithSuit:suit value:value];
            [array addObject:card];
        }
        
        [cards setObject:array forKey:peerID];
    }
    
    return cards;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, type=%d", [super description], self.packetType];
}

@end
