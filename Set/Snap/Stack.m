//
//  Stack.m
//  Snap
//
//  Created by Adrian on 15/5/6.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//

#import "Stack.h"
#import "Card.h"

@interface Stack()

{
    NSMutableArray *_cards;
}

@end

@implementation Stack

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cards = [NSMutableArray arrayWithCapacity:81];
    }
    return self;
}

- (void)addCardToTop:(Card *)card
{
    NSAssert(card, @"Card cannot be nil");
    NSAssert([_cards indexOfObject:card] == NSNotFound, @"Already have this card");
    
    [_cards addObject:card];
}

- (Card *)cardAtIndex:(NSInteger)index
{
    return [_cards objectAtIndex:index];
}

- (NSUInteger)cardCount
{
    return [_cards count];
}

- (NSArray *)array
{
    return [_cards copy];
}

@end
