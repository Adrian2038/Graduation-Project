//
//  MatchmakingServer.m
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/1.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


#import "MatchmakingServer.h"

typedef enum
{
    ServerStateIdle,
    ServerStateAcceptingConnections,
    ServerStateIgnoringNewConnections,
}
ServerState;

@interface MatchmakingServer ()

{
    NSMutableArray *_connectedClients;
    ServerState _serverState;
}

@end


@implementation MatchmakingServer


- (id)init
{
    if ((self = [super init]))
    {
        _serverState = ServerStateIdle;
    }
    return self;
}

#pragma mark - Other classes use

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
    if (_serverState == ServerStateIdle)
    {
        _serverState = ServerStateAcceptingConnections;
        _connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
        _session.delegate = self;
        _session.available = YES;
    }
}

- (NSArray *)connectedClients
{
    return _connectedClients;
}

- (NSUInteger)connectedClientCount
{
    return [_connectedClients count];
}

- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index
{
    return [_connectedClients objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
    return [_session displayNameForPeer:peerID];
}

- (void)endSession
{
    NSAssert(_serverState != ServerStateIdle, @"Wrong state");
    
    _serverState = ServerStateIdle;
    
    [_session disconnectFromAllPeers];
    _session.available = NO;
    _session.delegate = nil;
    _session = nil;
    
    _connectedClients = nil;
    
    [self.delegate matchmakingServerSessionDidEnd:self];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"MatchmakingServer: peer %@ changed state %d", peerID, state);
    
    switch (state)
    {
        case GKPeerStateAvailable:
            break;
            
        case GKPeerStateUnavailable:
            break;
            
            // A new client has connected to the server.
        case GKPeerStateConnected:
            if (_serverState == ServerStateAcceptingConnections)
            {
                if (![_connectedClients containsObject:peerID])
                {
                    [_connectedClients addObject:peerID];
                    [self.delegate matchmakingServer:self clientDidConnect:peerID];
                }
            }
            break;
            
            // A client has disconnected from the server.
        case GKPeerStateDisconnected:
            if (_serverState != ServerStateIdle)
            {
                if ([_connectedClients containsObject:peerID])
                {
                    [_connectedClients removeObject:peerID];
                    [self.delegate matchmakingServer:self clientDidDisconnect:peerID];
                }
            }
            break;
            
        case GKPeerStateConnecting:
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"MatchmakingServer: connection request from peer %@", peerID);
    
    if (_serverState == ServerStateAcceptingConnections && [self connectedClientCount] < self.maxClients)
    {
        NSError *error;
        if ([session acceptConnectionFromPeer:peerID error:&error])
            NSLog(@"MatchmakingServer: Connection accepted from peer %@", peerID);
        else
            NSLog(@"MatchmakingServer: Error accepting connection from peer %@, %@", peerID, error);
    }
    else  // not accepting connections or too many clients
    {
        [session denyConnectionFromPeer:peerID];
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"MatchmakingServer: connection with peer %@ failed %@", peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"MatchmakingServer: session failed %@", error);
    
    if ([[error domain] isEqualToString:GKSessionErrorDomain])
    {
        if ([error code] == GKSessionCannotEnableError)
        {
            [self.delegate matchmakingServerNoNetwork:self];
            [self endSession];
        }
    }
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}

@end
