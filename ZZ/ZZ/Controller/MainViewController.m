//
//  MainViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "MainViewController.h"
#import "UIButton+SnapAdditions.h"

@interface MainViewController ()

{
  BOOL _buttonEnabed;
}

@property (weak, nonatomic) IBOutlet UIImageView *sImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nImageView;
@property (weak, nonatomic) IBOutlet UIImageView *aImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pImageView;
@property (weak, nonatomic) IBOutlet UIImageView *jokerImageView;

@property (weak, nonatomic) IBOutlet UIButton *hostGameButton;
@property (weak, nonatomic) IBOutlet UIButton *joinGameButton;
@property (weak, nonatomic) IBOutlet UIButton *singlePlayerGameButton;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
  
    [self.hostGameButton rw_applySnapStyle];
    [self.joinGameButton rw_applySnapStyle];
    [self.singlePlayerGameButton rw_applySnapStyle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Host Game"]) {
        if ([segue.destinationViewController isKindOfClass:[HostViewController class]]) {
            HostViewController *controller = (HostViewController *)segue.destinationViewController;
            controller.delegate = self;
            NSLog(@"host delegate = %@", self);
        }
    } else if ([segue.identifier isEqualToString:@"Join Game"]) {
        if ([segue.destinationViewController isKindOfClass:[JoinViewController class]]) {
            JoinViewController *controller = (JoinViewController *)segue.destinationViewController;
            controller.delegate = self;
            NSLog(@"join delegate = %@", self);
        }
    }
}

#pragma mark - Animation  ... Something wrong with the animation

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    [self prepareForIntroAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    [self performIntroAnimation];
}

- (void)prepareForIntroAnimation
{
    self.sImageView.hidden = YES;
    self.nImageView.hidden = YES;
    self.aImageView.hidden = YES;
    self.pImageView.hidden = YES;
    self.jokerImageView.hidden = YES;
  
    self.joinGameButton.alpha = 0.0f;
    self.hostGameButton.alpha = 0.0f;
    self.singlePlayerGameButton.alpha = 0.0f;
  
    _buttonEnabed = NO;
}

- (void)performIntroAnimation
{
    self.sImageView.hidden = NO;
    self.nImageView.hidden = NO;
    self.aImageView.hidden = NO;
    self.pImageView.hidden = NO;
    self.jokerImageView.hidden = NO;
  
    CGPoint point = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height * 2.0f);
  
    self.sImageView.center = point;
    self.nImageView.center = point;
    self.aImageView.center = point;
    self.pImageView.center = point;
    self.jokerImageView.center = point;
  
    [UIView animateWithDuration:0.65f
                          delay:0.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
   
    {
       self.sImageView.center = CGPointMake(80.0, 108.0f);
       self.sImageView.transform = CGAffineTransformMakeRotation(-0.22f);
       
       self.nImageView.center = CGPointMake(160.0f, 93.0f);
       self.nImageView.transform = CGAffineTransformMakeRotation(-0.1f);
       
       self.aImageView.center = CGPointMake(240.0f, 88.0f);
     
       self.pImageView.center = CGPointMake(320.0f, 93.0f);
       self.pImageView.transform = CGAffineTransformMakeRotation(0.1f);
     
       self.jokerImageView.center = CGPointMake(400.0f, 108.0f);
       self.jokerImageView.transform = CGAffineTransformMakeRotation(0.22f);
    }
                     completion:nil];
  
 
    [UIView animateWithDuration:0.5f
                          delay:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
    {
       self.hostGameButton.alpha = 1.0f;
       self.joinGameButton.alpha = 1.0f;
       self.singlePlayerGameButton.alpha = 1.0f;
    }
                     completion:^(BOOL finished)
     {
       _buttonEnabed = YES;
     }];
  
}

- (void)performExitAnimationWithCompletionBlock:(void(^)(BOOL))block
{
    _buttonEnabed = NO;
  
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
                     {
                         self.sImageView.center = self.aImageView.center;
                         self.sImageView.transform = self.aImageView.transform;
                         
                         self.nImageView.center = self.aImageView.center;
                         self.nImageView.transform = self.aImageView.transform;
                         
                         self.pImageView.center = self.aImageView.center;
                         self.pImageView.transform = self.aImageView.transform;
                         
                         self.jokerImageView.center = self.aImageView.center;
                         self.joinGameButton.transform = self.aImageView.transform;
                     }
                     completion:^(BOOL finished)
                     {
                         CGPoint point = CGPointMake(self.aImageView.center.x, self.view.frame.size.height * -2.0f);
                         
                         [UIView animateWithDuration:1.0f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^
                                          {
                                              self.sImageView.center = point;
                                              self.nImageView.center = point;
                                              self.aImageView.center = point;
                                              self.pImageView.center = point;
                                              self.jokerImageView.center = point;
                                          }
                                          completion:block];
                         
                         [UIView animateWithDuration:0.3f
                                               delay:0.3f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^
                                          {
                                              self.hostGameButton.alpha = 0.0f;
                                              self.joinGameButton.alpha = 0.0f;
                                              self.singlePlayerGameButton.alpha = 0.0f;
                                          }
                                          completion:nil];
                     }];
  
}

#pragma mark - HostViewControllerDelegate

- (void)hostViewControllerDidCancel:(HostViewController *)controller
{
//    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

- (void)joinViewControllerDidCancel:(JoinViewController *)controller
{
    
}

@end
