//
//  MatchmakingServer.h
//  ZZSetCard
//
//  Created by Zhu Dengquan on 15/3/31.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//



@class MatchmakingServer;

@protocol MatchmakingServerDelegate <NSObject>

- (void)matchmakingServer:(MatchmakingServer *)server clientDidConnect:(NSString *)peerID;
- (void)matchmakingServer:(MatchmakingServer *)server clientDidDisconnect:(NSString *)peerID;
- (void)matchmakingServerSessionDidEnd:(MatchmakingServer *)server;
- (void)matchmakingServerNoNetwork:(MatchmakingServer *)server;

@end


@interface MatchmakingServer : NSObject <GKSessionDelegate>


@property (nonatomic, assign) int maxClients;
@property (nonatomic, strong, readonly) NSArray *connectedClients;
@property (nonatomic, strong, readonly) GKSession *session;

@property (nonatomic, weak) id <MatchmakingServerDelegate> delegate;

- (void)endSession;
- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID;
- (NSUInteger)connectedClientCount;
- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index;
- (NSString *)displayNameForPeerID:(NSString *)peerID;

@end
