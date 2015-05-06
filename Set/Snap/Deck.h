//
//  Deck.h
//  Snap
//
//  Created by Adrian on 15/5/6.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@interface Deck : NSObject

- (void)shuffle;
- (Card *)draw;
- (NSUInteger)cardsRemaning;

@end
