//
//  MainViewController.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/3/31.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "MainViewController.h"

#import "UIFont+SnapAdditions.h"
#import "UIButton+SnapAdditions.h"


@interface MainViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *sImageView;
@property (nonatomic, weak) IBOutlet UIImageView *nImageView;
@property (nonatomic, weak) IBOutlet UIImageView *aImageView;
@property (nonatomic, weak) IBOutlet UIImageView *pImageView;
@property (nonatomic, weak) IBOutlet UIImageView *jokerImageView;

@property (nonatomic, weak) IBOutlet UIButton *hostGameButton;
@property (nonatomic, weak) IBOutlet UIButton *joinGameButton;
@property (nonatomic, weak) IBOutlet UIButton *singlePlayerGameButton;

@end

@implementation MainViewController


#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.hostGameButton rw_applySnapStyle];
    [self.joinGameButton rw_applySnapStyle];
    [self.singlePlayerGameButton rw_applySnapStyle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Actions

- (IBAction)hostGameAction:(id)sender
{
}

- (IBAction)joinGameAction:(id)sender
{
}

- (IBAction)singlePlayerGameAction:(id)sender
{
}

@end
