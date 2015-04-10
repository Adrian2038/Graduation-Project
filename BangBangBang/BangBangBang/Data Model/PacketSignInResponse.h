//
//  PacketSignInResponse.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Packet.h"

@interface PacketSignInResponse : Packet

@property (nonatomic, strong) NSString *playerName;

+ (id)packetWithPlayerName:(NSString *)playerName;

@end
