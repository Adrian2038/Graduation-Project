//
//  HostViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "HostViewController.h"
#import "UIButton+SnapAdditions.h"
#import "HostControllerTableViewProtocol.h"

@interface HostViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, strong) HostControllerTableViewProtocol *tableViewProtocol;

@end

@implementation HostViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.dataSource = self.tableViewProtocol;
  self.tableView.delegate = self.tableViewProtocol;
  
  
  
  [self.startButton rw_applySnapStyle];
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

@end
