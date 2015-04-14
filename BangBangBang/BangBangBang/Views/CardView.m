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
    CGFloat angle;
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

@end
