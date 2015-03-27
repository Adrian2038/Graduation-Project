//
//  GameViewController.h
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/26.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Game.h"

@class GameViewController;

@protocol GameViewControllerDelegate <NSObject>

- (void)gameViewController:(GameViewController *)controller didQuitWithReason:(QuitReason)reason;

@end


@interface GameViewController : UIViewController <GameDelegate>

@property (nonatomic, weak) id <GameViewControllerDelegate> delegate;

@property (nonatomic, strong) Game *game;

@end
