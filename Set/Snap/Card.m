//
//  Card.m
//  Snap
//
//  Created by Adrian on 15/5/6.
//  Copyright (c) 2015年 Hollance. All rights reserved.
//

#import "Card.h"

@implementation Card

- (instancetype)initWithColor:(SetColor)color
                      shading:(SetShading)shading
                       symbol:(SetSymbol)symbol
                        value:(NSUInteger)value
{
    NSAssert(value >= 1 && value <= 3, @"Invalid card value");
    
    self = [super init];
    if (self) {
        _color = color;
        _shading = shading;
        _symbol = symbol;
        _value = value;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Card color = %d, shading = %d, symbol = %d, value = %d",
            _color, _shading, _symbol, _value];
}

@end
