//
//  Player.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Player.h"

@implementation Player


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, peerID = %@, name = %@, position = %d",
            [super description], self.peerID, self.name, self.position];
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}

@end
