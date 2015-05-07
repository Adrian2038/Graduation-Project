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
//    UIImageView *_backImageView;               // back image view
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

- (void)loadCards
{
    if (!_frontImageView) {
        _frontImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _frontImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_frontImageView];
        
//        Green Open Diamond 2
        
        NSString *colorString = nil;
        
        switch (self.card.color)
        {
            case SetColorRed:colorString = @"Red"; break;
            case SetColorGreen:colorString = @"Green"; break;
            case SetColorPurple:colorString = @"Purple"; break;
            default: break;
        }
        
        NSString *shadingString = nil;
        
        switch (self.card.shading)
        {
            case SetShadingSolid: shadingString = @"Solid"; break;
            case SetShadingStriped: shadingString = @"Striped"; break;
            case SetShadingOpen: shadingString = @"Open"; break;
            default: break;
        }
        
        NSString *symbolString = nil;
        
        switch (self.card.symbol)
        {
            case SetSymbolDiamond: symbolString = @"Diamond"; break;
            case SetSymbolSquiggle: symbolString = @"Squiggle"; break;
            case SetSymbolOval: symbolString = @"Oval"; break;
            default: break;
        }
        
        NSString *valueString = 0;
        
        switch (self.card.value)
        {
            case 1: valueString = @"1"; break;
            case 2: valueString = @"2"; break;
            case 3: valueString = @"3"; break;
            default: break;
        }
        
        NSString *cardContent = [NSString stringWithFormat:@"%@ %@ %@ %@",
                                 colorString, shadingString, symbolString, valueString];
        _frontImageView.image = [UIImage imageNamed:cardContent];
    }
}

- (void)animationDealingToPosition:(CGPoint)point withDelay:(NSTimeInterval)delay
{
//    self.frame = CGRectMake(-100.0f, -100.0f, cardWidth, cardHeight);
    
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
