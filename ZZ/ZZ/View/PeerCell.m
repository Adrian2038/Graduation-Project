//
//  PeerCell.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/18.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "PeerCell.h"
#import "UIFont+SnapAdditions.h"

@implementation PeerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CellBackground"]];
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground"]];
        self.selectedBackgroundView = [[UIImageView alloc]
                                       initWithImage:[UIImage imageNamed:@"CellBackgroundSelected"]];
      
        self.textLabel.font = [UIFont rw_snapFontWithSize:24.0f];
        self.textLabel.textColor = [UIColor colorWithRed:116/255.0f green:192/255.0f blue:97/255.0f alpha:1.0f];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
    }
    
    return self;
}

@end
