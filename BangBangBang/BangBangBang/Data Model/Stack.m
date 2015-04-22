//
//  Stack.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/14.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Stack.h"
#import "Card.h"


@interface Stack ()

{
    NSMutableArray *_cards;
}

@end


@implementation Stack

- (id)init
{
    self = [super init];
    if (self) {
        _cards = [NSMutableArray arrayWithCapacity:26];
    }
    return self;
}

- (void)addCardToTop:(Card *)card
{
    NSAssert(card, @"Card cannot be nil");
    NSAssert([_cards indexOfObject:card] == NSNotFound, @"Already have this Card");
    
    [_cards addObject:card];
}

- (NSUInteger)cardCount
{
    return [_cards count];
}

- (NSArray *)array
{
    return [_cards copy];
}

- (Card *)cardAtIndex:(NSUInteger)index
{
    return [_cards objectAtIndex:index];
}

@end
