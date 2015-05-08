//
//  Packet.m
//  Snap
//
//  Created by Ray Wenderlich on 5/25/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "Packet.h"
#import "NSData+SnapAdditions.h"
#import "PacketSignInResponse.h"
#import "PacketServerReady.h"
#import "PacketOtherClientQuit.h"
#import "PacketDealCards.h"
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

- (void)addCards:(NSDictionary *)cards toPayload:(NSMutableData *)data
{
    [cards enumerateKeysAndObjectsUsingBlock:^(id key , NSArray *array, BOOL *stop)
    {
        [data rw_appendString:key];
        [data rw_appendInt8:array.count];
        
        for (int i = 0; i < array.count; ++i)
        {
            // For each card ,write 4 bytes.
            Card *card = [array objectAtIndex:i];
            [data rw_appendInt8:card.color];
            [data rw_appendInt8:card.shading];
            [data rw_appendInt8:card.symbol];
            [data rw_appendInt8:card.value];
        }
    }];
}

+ (NSDictionary *)cardsFromData:(NSData *)data atOffset:(size_t)offset
{
    size_t count;
    
    NSMutableDictionary *cards = [NSMutableDictionary dictionaryWithCapacity:4];
    while (offset < [data length])
    {
        // It's not right here.
        NSString *peerID = @"438";
        
        int numberOfCards = [data rw_int8AtOffset:offset];
        offset += 1;
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:numberOfCards];
        
        for (int t = 0; t < numberOfCards; ++t)
        {
            int color = [data rw_int8AtOffset:offset];
            offset += 1;
            
            int shading = [data rw_int8AtOffset:offset];
            offset += 1;
            
            int symbol = [data rw_int8AtOffset:offset];
            offset += 1;
            
            int value = [data rw_int8AtOffset:offset];
            
            Card *card = [[Card alloc] initWithColor:color
                                             shading:shading
                                              symbol:symbol
                                               value:value];
            [array addObject:card];
        }
        
        [cards setObject:array forKey:peerID];
    }
    return cards;
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

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@, type=%d", [super description], self.packetType];
}

@end
