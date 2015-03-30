//
//  MainViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


#import "MainViewController.h"
#import "HostViewController.h"
#import "JoinViewController.h"
#import "GameViewController.h"

#import "Game.h"

#import "UIButton+SnapAdditions.h"

@interface MainViewController ()
<HostViewControllerDelegate, JoinViewControllerDelegate, GameViewControllerDelegate>

{
    BOOL _buttonsEnabled;
    BOOL _performAnimations;
}

@property (nonatomic, weak) IBOutlet UIButton *hostGameButton;
@property (nonatomic, weak) IBOutlet UIButton *joinGameButton;
@property (nonatomic, weak) IBOutlet UIButton *singlePlayerGameButton;

@end

@implementation MainViewController

#pragma mark - LifeCycle of vc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@".....................................");
        
    [self.hostGameButton rw_applySnapStyle];
    [self.joinGameButton rw_applySnapStyle];
    [self.singlePlayerGameButton rw_applySnapStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _performAnimations = YES;
    
    if (_performAnimations) {
        [self prepareForIntroAnimation];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_performAnimations) {
        [self performIntroAnimation];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (_buttonsEnabled)
    {
        if ([segue.identifier isEqualToString:@"Host Game"]) {
            if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *naviController = (UINavigationController *)segue.destinationViewController;
                HostViewController *hostViewController = [naviController viewControllers][0];
                hostViewController.delegate = self;
            }
        } else if ([segue.identifier isEqualToString:@"Join Game"]) {
            if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *naviController = (UINavigationController *)segue.destinationViewController;
                JoinViewController *joinViewController = [naviController viewControllers][0];
                joinViewController.delegate = self;
            }
        }
    }
}

#pragma mark - Actions , that I may use segue replace it.

- (IBAction)hostGameAction:(id)sender
{
}

- (IBAction)joinGameAction:(id)sender
{
}

- (IBAction)singlePlayerGameAction:(id)sender
{
}

#pragma mark - Animation

- (void)prepareForIntroAnimation
{
    self.hostGameButton.alpha = 0.0f;
    self.joinGameButton.alpha = 0.0f;
    self.singlePlayerGameButton.alpha = 0.0f;
    
    _buttonsEnabled = NO;
}

- (void)performIntroAnimation
{
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
         _buttonsEnabled = YES;
     }];
    
}

- (void)performExitAnimationWithCompletionBlock:(void (^)(BOOL))block
{    
    _buttonsEnabled = NO;
    
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

}

#pragma mark - AlertView

- (void)showNoNetworkAlert
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"No Network", @"No network alert title")
                              message:NSLocalizedString(@"To use multiplayer, please enable Bluetooth or Wi-Fi in your device's Settings.", @"No network alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)showDisconnectedAlert
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Disconnected", @"Client disconnected alert title")
                              message:NSLocalizedString(@"You were disconnected from the game.", @"Client disconnected alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
    [alertView show];
}

#pragma mark - Game block

- (void)startGameWithBlock:(void(^)(Game *))block
{
    
    [self performSegueWithIdentifier:@"Game ooo" sender:self];
    
//    GameViewController *gameViewController = [[GameViewController alloc] init];
//    gameViewController.delegate = self;
//        
//    [self presentViewController:gameViewController animated:NO completion:^
//     {         
//         Game *game = [[Game alloc] init];
//         gameViewController.game = game;
//         game.delegate = gameViewController;
//         block(game);
//     }];
}

#pragma mark - HostViewControllerDelegate

- (void)hostViewControllerDidCancel:(HostViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hostViewController:(HostViewController *)controller didEndSessionWithReason:(QuitReason)reason
{
    if (reason == QuitReasonNoNetwork)
    {
        [self showNoNetworkAlert];
    }
}

#pragma mark - JoinViewControllerDelegate

- (void)joinViewControllerDidCancel:(JoinViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)joinViewController:(JoinViewController *)controller didDisconnectWithReason:(QuitReason)reason
{
    if (reason == QuitReasonNoNetwork)
    {
        [self showNoNetworkAlert];
    }
    else if (reason == QuitReasonConnectionDropped)
    {
        [self dismissViewControllerAnimated:NO completion:^
         {
             [self showDisconnectedAlert];
         }];
    }
}

- (void)joinViewController:(JoinViewController *)controller
      startGameWithSession:(GKSession *)session
                playerName:(NSString *)name
                    server:(NSString *)peerID
{
    _performAnimations = NO;
    
    [self dismissViewControllerAnimated:NO completion:^
    {
        _performAnimations = YES;
        
        [self startGameWithBlock:^(Game *game)
        {
            [game startClientGameWithSession:session playerName:name server:peerID];
        }];
    }];
}

#pragma mark - GameViewControllerDelegate

- (void)gameViewController:(GameViewController *)controller didQuitWithReason:(QuitReason)reason
{
    [self dismissViewControllerAnimated:NO completion:^
    {
        if (reason == QuitReasonConnectionDropped) {
            [self showDisconnectedAlert];
        }
    }];
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);

}

@end
