//
//  Game.m
//  BangBangBang
//
//  Created by Adrian on 15/4/5.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "Game.h"
#import "Player.h"
#import "Packet.h"
#import "PacketSignInResponse.h"

typedef enum
{
    GameStateWaitingForSignIn,
    GameStateWaitingForReady,
    GameStateDealing,
    GameStatePlaying,
    GameStateGameOver,
    GameStateQuitting,
}
GameState;

@implementation Game
{
    GameState _state;
    
    GKSession *_session;
    NSString *_serverPeerID;
    NSString *_localPlayerName;
  
    NSMutableDictionary *_players;
}

#pragma mark - Game Logic

- (void)startClientGameWithSession:(GKSession *)session
                        playerName:(NSString *)name
                            server:(NSString *)peerID
{
    self.isServer = NO;
    
    _session = session;
    _session.available = NO;
    _session.delegate = self;
    [_session setDataReceiveHandler:self withContext:nil];
    
    _serverPeerID = peerID;
    _localPlayerName = name;
    
    _state = GameStateWaitingForSignIn;
    
    [self.delegate gameWaitingForServerReady:self];
    
}

- (void)startServerGameWithSession:(GKSession *)session
                        playerName:(NSString *)name
                           clients:(NSArray *)clients
{
    self.isServer = YES;
    
    _session = session;
    _session.available = NO;
    _session.delegate = self;
    [_session setDataReceiveHandler:self withContext:nil];
    
    _state = GameStateWaitingForSignIn;
    
    [self.delegate gameWaitingForClientsReady:self];
    
    // Create the player object for the server.
    Player *player = [[Player alloc] init];
    player.peerID = session.peerID;
    player.name = name;
    player.position = PlayerPositionBotton;
    [_players setObject:player forKey:player.peerID];
    
    // Add a player object for each client
    int index = 0;
    for (NSString *peerID in clients) {
        Player *player = [[Player alloc] init];
        player.peerID = peerID;
        [_players setObject:player forKey:player.peerID];
        
        if (index == 0)
            clients.count == 1 ? player.position = PlayerPositionTop : PlayerPositionLeft;
        else if (index == 1)
            player.position = PlayerPositionTop;
        else
            player.position = PlayerPositionRight;
        
        index++;
    }
    
    Packet *packet = [Packet packetWithType:PacketTypeSignInRequest];
    [self sendPacketToAllClients:packet];
}


- (void)quitGameWithReason:(QuitReason)reason
{
    _state = GameStateQuitting;
    
    [_session disconnectFromAllPeers];
    _session.delegate = nil;
    _session = nil;
    
    [self.delegate game:self didQuitWithReason:reason];
}

- (void)clientReceivedPacket:(Packet *)packet
{
    switch (packet.packetType) {
        case PacketTypeSignInRequest:
            if (_state == GameStateWaitingForSignIn) {
                _state = GameStateWaitingForReady;
                
                Packet *packet = [PacketSignInResponse packetWithPlayerName:_localPlayerName];
                [self sendPacketToServer:packet];
            }
            break;
            
        default:
            NSLog(@"Client received unexcepted packet: %@", packet);
            break;
    }
}


- (void)serverReceivedPacket:(Packet *)packet fromPlayer:(Player *)player
{
    switch (packet.packetType) {
        case PacketTypeSignInResponse:
            if (_state == GameStateWaitingForSignIn) {
                player.name = ((PacketSignInResponse *)packet).playerName;
                
                if ([self receivedResponsesFromAllPlayers]) {
                    _state = GameStateWaitingForReady;
                }
            }
            break;
            
        default:
            NSLog(@"Server receives unexcepted packet: %@", packet);
            break;
    }
}

-(Player *)playerWithPeerID:(NSString *)peerID
{
    return [_players objectForKey:peerID];
}

- (BOOL)receivedResponsesFromAllPlayers
{
    for (NSString *peerID in _players) {
        Player *player = [self playerWithPeerID:peerID];
        if (!player.receivedResponse) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Networking

- (void)sendPacketToAllClients:(Packet *)packet
{
  [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
  {
    obj.receivedResponse = [_session.peerID isEqualToString:obj.peerID];
  }];
  
    GKSendDataMode dataModel = GKSendDataReliable;
    
    NSData *data = [packet data];
    NSError *error;
    
    if (![_session sendDataToAllPeers:data withDataMode:dataModel error:&error]) {
        NSLog(@"Error sending data to clients : %@", error);
    }
}

- (void)sendPacketToServer:(Packet *)packet
{
    GKSendDataMode dataModel = GKSendDataReliable;
    
    NSData *data = [packet data];
    NSError *error;
    
    if (![_session sendData:data toPeers:@[_serverPeerID] withDataMode:dataModel error:&error]) {
        NSLog(@"Error sending data to server : %@", error);
    }
}


#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"Game: peer %@ changed state %d", peerID, state);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"Game: connection request from peer %@", peerID);
    
    [session denyConnectionFromPeer:peerID];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"Game: connection with peer %@ failed %@", peerID, error);
    
    // Not used.
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"Game: session failed %@", error);
}

#pragma mark - GKSession Data Receive Handler

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
    NSLog(@"Game: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
    
    Packet *packet = [Packet packetWithData:data];
    if (!packet) {
        NSLog(@"Invalid packet %@", data);
        return;
    }
    
    Player *player = [self playerWithPeerID:peerID];
    if (player) {
        player.receivedResponse = YES; // this is the new bit.
    }
  
    if (self.isServer) {
        [self serverReceivedPacket:packet fromPlayer:player];
        
    } else {
        [self clientReceivedPacket:packet];
    }
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}

@end