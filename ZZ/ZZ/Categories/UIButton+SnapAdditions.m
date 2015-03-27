//
//  UIButton+SnapAdditions.m
//  Snap
//
//  Created by Zhu Dengquan on 15/3/11.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//

#import "UIButton+SnapAdditions.h"
#import "UIFont+SnapAdditions.h"

@implementation UIButton (SnapAdditions)

- (void)rw_applySnapStyle
{  
    UIImage *buttonImage = [[UIImage imageNamed:@"Button"] stretchableImageWithLeftCapWidth:15
                                                                               topCapHeight:0];
    [self setBackgroundImage:buttonImage forState:UIControlStateNormal];
  
    UIImage *pressedImage = [[UIImage imageNamed:@"ButtonPressed"] stretchableImageWithLeftCapWidth:15
                                                                                       topCapHeight:0];
    [self setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
}

@end
