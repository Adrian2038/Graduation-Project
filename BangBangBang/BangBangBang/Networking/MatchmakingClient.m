//
//  MatchmakingClient.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/1.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "MatchmakingClient.h"

typedef enum
{
    ClientStateIdle,
    ClientStateSearchingForServers,
    ClientStateConnecting,
    ClientStateConnected,
}
ClientState;


@interface MatchmakingClient ()

{
    NSMutableArray *_availableServers;
    ClientState _clientState;
}

@end


@implementation MatchmakingClient

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _clientState = ClientStateIdle;
    }
    return self;
}

#pragma mark - Methods ,that other clases use

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID
{
    if (_clientState == ClientStateIdle)
    {
        _clientState = ClientStateSearchingForServers;
        
        _availableServers = [NSMutableArray arrayWithCapacity:10];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeClient];
        _session.delegate = self;
        _session.available = YES;
    }
}

- (NSArray *)availableServers
{
    return _availableServers;
}

- (NSUInteger)availableServerCount
{
    return [_availableServers count];
}

- (NSString *)peerIDForAvailableServerAtIndex:(NSUInteger)index
{
    return [_availableServers objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
    return [_session displayNameForPeer:peerID];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"MatchmakingClient: peer %@ changed state %d", peerID, state);
    
    switch (state)
    {
            // The client has discovered a new server.
        case GKPeerStateAvailable:
            if (_clientState == ClientStateSearchingForServers)
            {
                if (![_availableServers containsObject:peerID])
                {
                    [_availableServers addObject:peerID];
                    [self.delegate matchmakingClient:self serverBecameAvailable:peerID];
                }
            }
            break;
            
            // The client sees that a server goes away.
        case GKPeerStateUnavailable:
            if (_clientState == ClientStateSearchingForServers)
            {
                if ([_availableServers containsObject:peerID])
                {
                    [_availableServers removeObject:peerID];
                    [self.delegate matchmakingClient:self serverBecameUnavailable:peerID];
                }
            }
            break;
            
        case GKPeerStateConnected:
            break;
            
        case GKPeerStateDisconnected:
            break;
            
        case GKPeerStateConnecting:
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"MatchmakingClient: connection request from peer %@", peerID);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"MatchmakingClient: connection with peer %@ failed %@", peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"MatchmakingClient: session failed %@", error);
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
