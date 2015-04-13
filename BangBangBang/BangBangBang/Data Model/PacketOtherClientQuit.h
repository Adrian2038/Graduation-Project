//
//  PacketOtherClientQuit.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Packet.h"

@interface PacketOtherClientQuit : Packet

@property (nonatomic, copy) NSString *peerID;

+ (id)packetWithPeerID:(NSString *)peerID;

@end
