//
//  JoinViewController.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/1.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JoinViewController;

@protocol JoinViewControllerDelegate <NSObject>

- (void)joinViewControllerDidCancel:(JoinViewController *)controller;

@end

@interface JoinViewController : UIViewController

@property (nonatomic, weak) id <JoinViewControllerDelegate> delegate;


@end
