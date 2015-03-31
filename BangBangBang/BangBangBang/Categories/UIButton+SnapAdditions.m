//
//  UIButton+SnapAdditions.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/3/31.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "UIButton+SnapAdditions.h"
#import "UIFont+SnapAdditions.h"

@implementation UIButton (SnapAdditions)

- (void)rw_applySnapStyle
{
    // I won't use the rw_snapFontWithSize:size method here Because from English to Chinese will rise some little Bugs
    
    UIImage *buttonImage = [[UIImage imageNamed:@"Button"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [self setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    UIImage *pressedImage = [[UIImage imageNamed:@"ButtonPressed"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [self setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
}
@end
