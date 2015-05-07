//
//  CardView.h
//  Snap
//
//  Created by Adrian on 15/5/6.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//
// .........................
// The default set image is rect , and with the game's effect,
// I will let the CardView has some corner radius property.

#import <UIKit/UIKit.h>

const CGFloat cardWidth;
const CGFloat cardHeight;

@class Card;
// I needn't animate the card to the palyer's position , but animate the card to a H & V

@interface CardView : UIView

@property (nonatomic, strong) Card *card;

- (void)loadCards;
- (void)animationDealingToPosition:(CGPoint)point withDelay:(NSTimeInterval)delay;

@end
