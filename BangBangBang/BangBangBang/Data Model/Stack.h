//
//  Stack.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/14.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

@class Card;

@interface Stack : NSObject

- (void)addCardToTop:(Card *)card;
- (NSUInteger)cardCount;
- (NSArray *)array;
- (Card *)cardAtIndex:(NSUInteger)index;
- (void)addCardsFromArray:(NSArray *)array;
- (Card *)topmostCard;

@end
