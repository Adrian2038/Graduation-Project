//
//  PacketServerReady.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Packet.h"

@interface PacketServerReady : Packet

@property (nonatomic, strong) NSMutableDictionary *players;

+ (id)packetWithPlayers:(NSMutableDictionary *)players;

@end
