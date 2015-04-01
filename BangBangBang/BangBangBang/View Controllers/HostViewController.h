//
//  HostViewController.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/1.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


@class HostViewController;

@protocol HostViewControllerDelegate <NSObject>

- (void)hostViewControllerDidCancel:(HostViewController *)controller;

@end

@interface HostViewController : UIViewController

@property (nonatomic, weak) id <HostViewControllerDelegate> delegate;

@end
