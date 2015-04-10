//
//  Packet.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


typedef enum
{
    PacketTypeSignInRequest = 0x64,    // server to client
    PacketTypeSignInResponse,          // client to server
    
    PacketTypeServerReady,             // sever to client
    PacketTypeClientReady,             // client to server
    
    PacketTypeDealCards,               // server to client
    PacketTypeClientDealCards,         // client to server
    
    PacketTypeActivatePlayer,          // server to client
    PacketTypeClientTurnedCards,       // client to server
    
    PacketTypePlayerShouldSnap,        // client to server
    PacketTypePlayerCalledSnap,        // server to client
    
    PacketTypeOtherClientQuit,         // server to client
    PacketTypeServerQuit,              // server to client
    PacketTypeClientQuit,              // client to server
}
PacketType;

@interface Packet : NSObject

@property (nonatomic, assign) PacketType packetType;

+ (id)packetWithType:(PacketType)packetType;
- (id)initWithType:(PacketType)packetType;

- (NSData *)data;

@end
