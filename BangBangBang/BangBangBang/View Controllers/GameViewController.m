//
//  GameViewController.m
//  BangBangBang
//
//  Created by Adrian on 15/4/5.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "GameViewController.h"

#import "UIFont+SnapAdditions.h"

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *centerLabel;

@end

@implementation GameViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.centerLabel.font = [UIFont rw_snapFontWithSize:18.0f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - Action

- (IBAction)exitAction:(UIButton *)sender
{
    [self.game quitGameWithReason:QuitReasonUserQuit];
}

#pragma mark - GameDelegate

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason
{
    [self.delegate gameViewController:self didQuitWithReason:reason];
}

- (void)gameWaitingForServerReady:(Game *)game
{
    self.centerLabel.text = NSLocalizedString(@"正在等待游戏开始...", @"Status text: waiting for server");
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
