//
//  Deck.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/14.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

@class Card;

@interface Deck : NSObject

- (void)shuffle;
- (Card *)draw;
- (int)cardsRemaining;

@end
