//
//  Stack.h
//  Snap
//
//  Created by Adrian on 15/5/6.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@interface Stack : NSObject

- (void)addCardToTop:(Card *)card;
- (NSUInteger)cardCount;
- (NSArray *)array;
- (Card *)cardAtIndex:(NSInteger)index;

@end
