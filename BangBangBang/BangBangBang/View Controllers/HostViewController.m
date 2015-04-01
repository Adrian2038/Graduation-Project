//
//  HostViewController.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/1.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "HostViewController.h"

#import "UIButton+SnapAdditions.h"
#import "UIFont+SnapAdditions.h"

#import "MatchmakingServer.h"

@interface HostViewController ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>


{
    MatchmakingServer *_matchmakingServer;
}


@property (nonatomic, weak) IBOutlet UILabel *headingLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;

@end

@implementation HostViewController

#pragma mark - View Controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headingLabel.font = [UIFont rw_snapFontWithSize:24.0f];;
    self.nameLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.statusLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.nameTextField.font = [UIFont rw_snapFontWithSize:20.0f];
    
    [self.startButton rw_applySnapStyle];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.nameTextField action:@selector(resignFirstResponder)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_matchmakingServer == nil)
    {
        _matchmakingServer = [[MatchmakingServer alloc] init];
        _matchmakingServer.maxClients = 3;
        [_matchmakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
        
        self.nameTextField.placeholder = _matchmakingServer.session.displayName;
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Actions

- (IBAction)startAction:(id)sender
{
}

- (IBAction)exitAction:(id)sender
{
    [self.delegate hostViewControllerDidCancel:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
