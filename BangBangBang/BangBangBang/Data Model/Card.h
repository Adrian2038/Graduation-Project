//
//  Card.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/14.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


typedef enum
{
    SuitClubs,
    SuitDiamonds,
    SuitHearts,
    SuitSpades
}
Suit;

#define CardAce 1
#define CardJack 11
#define CardQueen 12
#define CardKing 13

@interface Card : NSObject


@property (nonatomic, assign, readonly) Suit suit;
@property (nonatomic, assign, readonly) NSInteger value;

- (id)initWithSuit:(Suit)suit value:(NSInteger)value;


@end
