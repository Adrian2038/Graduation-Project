//
//  CardView.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/14.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "CardView.h"
#import "Card.h"
#import "Player.h"

const CGFloat CardWidth = 67.0f;
const CGFloat CardHeight = 99.0f;


@interface CardView ()

{
    UIImageView *_backImageView;
    UIImageView *_frontImageView;
    CGFloat _angle;
}

@end

@implementation CardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self loadBack];
    }
    return self;
}

- (void)loadBack
{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backImageView.image = [UIImage imageNamed:@"Back"];
        _backImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_backImageView];
    }
}

- (void)animateDealingToPlayer:(Player *)player withDelay:(NSTimeInterval)delay
{
    self.frame = CGRectMake(-100.0f, -100.0f, CardWidth, CardHeight);
    self.transform = CGAffineTransformMakeRotation(M_PI);
    
    CGPoint point = [self centerForPlayer:player];
    _angle = [self angleForPlayer:player];
    
    [UIView animateWithDuration:0.2f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.center = point;
         self.transform = CGAffineTransformMakeRotation(_angle);
     }
                     completion:nil];
}

- (CGPoint)centerForPlayer:(Player *)player
{
    CGRect rect = self.superview.bounds;
    CGFloat midX = CGRectGetMidX(rect);
    CGFloat midY = CGRectGetMidY(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    CGFloat x = -3.0f + RANDOM_INT(6) + CardWidth/2.0f;
    CGFloat y = -3.0f + RANDOM_INT(6) + CardHeight/2.0f;
    
    if (player.position == PlayerPositionBottom)
    {
        x += midX - CardWidth - 7.0f;
        y += maxY - CardHeight - 30.0f;
    }
    else if (player.position == PlayerPositionLeft)
    {
        x += 31.0f;
        y += midY - CardWidth - 45.0f;
    }
    else if (player.position == PlayerPositionTop)
    {
        x += midX + 7.0f;
        y += 29.0f;
    }
    else
    {
        x += maxX - CardHeight + 1.0f;
        y += midY - 30.0f;
    }
    
    return CGPointMake(x, y);
}

- (CGFloat)angleForPlayer:(Player *)player
{
    float theAngle = (-0.5f + RANDOM_FLOAT()) / 4.0f;
    
    if (player.position == PlayerPositionLeft)
        theAngle += M_PI / 2.0f;
    else if (player.position == PlayerPositionTop)
        theAngle += M_PI;
    else if (player.position == PlayerPositionRight)
        theAngle -= M_PI / 2.0f;
    
    return theAngle;
}


@end
