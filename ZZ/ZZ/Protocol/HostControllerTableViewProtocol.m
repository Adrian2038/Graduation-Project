//
//  HostControllerTableViewProtocol.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "HostControllerTableViewProtocol.h"

@implementation HostControllerTableViewProtocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor grayColor];
    
    NSString *name = nil;
    switch (indexPath.row) {
        case 0: name = @"Tom"; break;
        case 1: name = @"Jack"; break;
        case 2: name = @"Taylor Swift"; break;
        default: break;
    }
    cell.textLabel.text = name;
    return cell;
}

@end
