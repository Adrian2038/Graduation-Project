//
//  HostViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "HostViewController.h"
#import "UIButton+SnapAdditions.h"
#import "UIFont+SnapAdditions.h"
#import "HostControllerTableViewProtocol.h"
#import "HostControllerTextFieldProtocol.h"

@interface HostViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, strong) HostControllerTextFieldProtocol *textFieldProtocol;
@property (nonatomic, strong) HostControllerTableViewProtocol *tableViewProtocol;

@end

@implementation HostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headingLabel.font = [UIFont rw_snapFontWithSize:24.0f];
    self.nameLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.statusLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.nameTextField.font = [UIFont rw_snapFontWithSize:20.0f];
 
    [self.startButton rw_applySnapStyle];
 
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.nameTextField action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.nameTextField.delegate = self.textFieldProtocol;
    
    self.tableView.dataSource = self.tableViewProtocol;
    self.tableView.delegate = self.tableViewProtocol;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Action

- (IBAction)startAction:(UIButton *)sender
{
}

- (IBAction)exitAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Properties

- (HostControllerTableViewProtocol *)tableViewProtocol
{
    if (!_tableViewProtocol) {
      _tableViewProtocol = [[HostControllerTableViewProtocol alloc] init];
    }
    return _tableViewProtocol;
}

- (HostControllerTextFieldProtocol *)textFieldProtocol
{
    if (!_textFieldProtocol) {
        _textFieldProtocol = [[HostControllerTextFieldProtocol alloc] init];
    }
    return _textFieldProtocol;
}

@end
