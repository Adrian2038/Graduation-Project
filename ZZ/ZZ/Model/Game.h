//
//  Game.h
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/26.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

@class Game;

@protocol GameDelegate <NSObject>

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason;
- (void)gameWaitingForServerReady:(Game *)game;

@end

@interface Game : NSObject

@property (nonatomic, weak) id <GameDelegate> delegate;

@property (nonatomic, assign) BOOL isServer;

- (void)startClientGameWithSession:(GKSession *)session
                        playerName:(NSString *)name
                            server:(NSString *)peerID;
- (void)quitGameWithReason:(QuitReason)reason;

@end
