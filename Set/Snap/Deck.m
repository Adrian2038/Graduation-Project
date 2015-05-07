//
//  Deck.m
//  Snap
//
//  Created by Adrian on 15/5/6.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//

#import "Deck.h"
#import "Card.h"


@interface Deck ()

{
    NSMutableArray *_cards;
}

@end

@implementation Deck

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cards = [NSMutableArray arrayWithCapacity:81];
        [self setupCards];
    }
    return self;
}

- (void)setupCards
{
    for (SetColor color = SetColorRed; color <= SetColorPurple; color ++)
    {
        for (SetShading shading = SetShadingSolid; shading <= SetShadingOpen; shading ++)
        {
            for (SetSymbol symbol = SetSymbolDiamond; symbol <= SetSymbolOval; symbol ++)
            {
                for (NSUInteger value = 1; value <= 3; value ++)
                {
                    Card *card = [[Card alloc] initWithColor:color shading:shading symbol:symbol value:value];
                    [_cards addObject:card];
                }
            }
        }
    }
}

- (void)shuffle
{
    NSUInteger cardsCount = [self cardsRemaning];
    NSMutableArray *randomCards = [NSMutableArray arrayWithCapacity:[self cardsRemaning]];
    
    for (NSUInteger i = 0; i < cardsCount; i++)
    {
        NSUInteger randomIndex = arc4random() % [self cardsRemaning];  // randomIndex will between 0 and 80;
        Card *card = [_cards objectAtIndex:randomIndex];
        [randomCards addObject:card];
        [_cards removeObjectAtIndex:randomIndex];
    }
    
    NSAssert([self cardsRemaning] == 0, @"original cards's count must be 0");
    
    _cards = randomCards;
}

- (Card *)draw
{
    if ([self cardsRemaning])
    {
        Card *card = [_cards lastObject];
        [_cards removeLastObject];
        
        return card;
    }
    return nil;
}

- (NSUInteger)cardsRemaning
{
    return [_cards count];
}

@end
