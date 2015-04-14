//
//  Card.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/14.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Card.h"

@implementation Card

- (id)initWithSuit:(Suit)suit value:(NSInteger)value
{
    NSAssert(value >= CardAce && value <= CardKing, @"Invalid card value");
    
    self = [super init];
    if (self) {
        _suit = suit;
        _value = value;
    }
    return self;
}

@end
