//
//  PacketActivatePlayer.h
//  BangBangBang
//
//  Created by Adrian on 15/4/27.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Packet.h"

@interface PacketActivatePlayer : Packet

@property (nonatomic, copy) NSString *peerID;

+ (id)packetWithPeerID:(NSString *)peerID;

@end
