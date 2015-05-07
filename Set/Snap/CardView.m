//
//  CardView.m
//  Snap
//
//  Created by Adrian on 15/5/6.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//

#import "CardView.h"
#import "Card.h"

const CGFloat cardWidth = 70.0f;
const CGFloat cardHeight = 50.0f;


@interface CardView ()

{
    // I may not need the back image view;
    UIImageView *_backImageView;               // back image view
    UIImageView *_frontImageView;              // front image view.
    CGFloat _angle;
}

@end

@implementation CardView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)animationDealingToPosition:(CGPoint)point withDelay:(NSTimeInterval)delay
{
    self.frame = CGRectMake(-100.0f, -100.0f, cardWidth, cardHeight);
    
    [UIView animateWithDuration:0.2f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
                     {
                         self.center = point;
                     }
                     completion:nil];
}

// no center for player & no angle player

@end
