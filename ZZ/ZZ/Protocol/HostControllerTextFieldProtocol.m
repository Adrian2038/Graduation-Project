//
//  HostControllerTextFieldProtocol.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "HostControllerTextFieldProtocol.h"

@implementation HostControllerTextFieldProtocol

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


@end
