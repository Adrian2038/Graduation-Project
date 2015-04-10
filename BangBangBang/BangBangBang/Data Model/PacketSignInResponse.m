//
//  PacketSignInResponse.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "PacketSignInResponse.h"
#import "NSData+SnapAdditions.h"

@implementation PacketSignInResponse

+ (id)packetWithPlayerName:(NSString *)playerName
{
    return [[[self class] alloc] initWithPlayerName:playerName];
}

- (id)initWithPlayerName:(NSString *)playerName
{
    self = [super initWithType:PacketTypeSignInResponse];
    if (self) {
        self.playerName = playerName;
    }
    return self;
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data rw_appendString:self.playerName];
}

@end
