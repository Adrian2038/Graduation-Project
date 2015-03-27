//
//  JoinViewController.h
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//



@class JoinViewController;

@protocol JoinViewControllerDelegate <NSObject>

- (void)joinViewControllerDidCancel:(JoinViewController *)controller;
- (void)joinViewController:(JoinViewController *)controller didDisconnectWithReason:(QuitReason)reason;
- (void)joinViewController:(JoinViewController *)controller
      startGameWithSession:(GKSession *)session
                playerName:(NSString *)name
                    server:(NSString *)peerID;

@end

@interface JoinViewController : UIViewController

@property (nonatomic, weak) id <JoinViewControllerDelegate> delegate;

@end
