//
//  Deck.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/14.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Deck.h"
#import "Card.h"


@interface Deck ()

{
    NSMutableArray *_cards;
}

@end


@implementation Deck

- (void)setUpCards
{
    for (Suit suit = SuitClubs; suit <= SuitSpades; ++suit) {
        for (NSInteger value = CardAce; value <= CardKing; ++value) {
            Card *card = [[Card alloc] initWithSuit:suit value:value];
            [_cards addObject:card];
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        _cards = [NSMutableArray arrayWithCapacity:52];
        [self setUpCards];
    }
    return self;
}

- (int)cardsRemaining
{
    return _cards.count;
}

- (void)shuffle
{
    NSUInteger count = [_cards count];
    NSMutableArray *shuffle = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; ++i) {
        int t = arc4random() % [self cardsRemaining];
        Card *card = [_cards objectAtIndex:t];
        [shuffle addObject:card];
        [_cards removeObject:card];
    }
    
    NSAssert([self cardsRemaining] == 0, @"Original deck should be empty now");
    
    _cards = shuffle;
}

- (Card *)draw
{
    NSAssert([self cardsRemaining] > 0, @"No more cards in the deck");
    Card *card = [_cards lastObject];
    [_cards removeLastObject];
    return card;
}


@end
