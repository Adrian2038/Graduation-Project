//
//  PacketDealCards.h
//  BangBangBang
//
//  Created by Adrian on 15/4/27.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Packet.h"

@class Player;

@interface PacketDealCards : Packet

@property (nonatomic, strong) NSDictionary *cards;
@property (nonatomic, copy) NSString *startingPeerID;

+ (id)packetWithCards:(NSDictionary *)cards startingWithPlayerPeerID:(NSString *)startingPeerID;

@end
