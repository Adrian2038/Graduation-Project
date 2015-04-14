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
#import "PacketServerReady.h"
#import "PacketOtherClientQuit.h"
#import "Card.h"
#import "Deck.h"

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
    
    PlayerPosition _startingPlayerPosition;
    PlayerPosition _activePlayerPosition;
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
    player.position = PlayerPositionBottom;
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
    
    if (reason == QuitReasonUserQuit) {
        if (self.isServer) {
            Packet *packet = [Packet packetWithType:PacketTypeServerQuit];
            [self sendPacketToAllClients:packet];
        } else {
            Packet *packet = [Packet packetWithType:PacketTypeClientQuit];
            [self sendPacketToServer:packet];
        }
    }
    
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
            
        case PacketTypeServerReady:
            if (_state == GameStateWaitingForReady) {
                _players = ((PacketServerReady*)packet).players;
                
                [self changeRelativePositionsOfPlayers];
                
                Packet *packet = [Packet packetWithType:PacketTypeClientReady];
                [self sendPacketToServer:packet];
                NSLog(@"server ready");
                [self beginGame];
            }
            break;
            
        case PacketTypeOtherClientQuit:
            if (_state != GameStateQuitting) {
                PacketOtherClientQuit *quitClient = ((PacketOtherClientQuit *)packet);
                [self clientDidDisconnect:quitClient.peerID];
            }
            break;
            
        case PacketTypeServerQuit:
            [self quitGameWithReason:QuitReasonServerQuit];
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
                    
                    Packet *packet = [PacketServerReady packetWithPlayers:_players];
                    [self sendPacketToAllClients:packet];
                }
            }
            break;
        case PacketTypeClientReady:
            if (_state == GameStateWaitingForReady && [self receivedResponsesFromAllPlayers]) {
                [self beginGame];
                NSLog(@"client ready");
            }
            break;
            
        case PacketTypeClientQuit:
            [self clientDidDisconnect:player.peerID];
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

- (void)changeRelativePositionsOfPlayers
{
    NSAssert(!self.isServer, @"Must be Client");
    
    Player *myPlayer = [self playerWithPeerID:_session.peerID];
    int diff = myPlayer.position;
    myPlayer.position = PlayerPositionBottom;
    
    [_players enumerateKeysAndObjectsUsingBlock:^(id key , Player *obj, BOOL *stop)
    {
        if (obj != myPlayer) {
            obj.position = (obj.position - diff) % 4;
        }
    }];
}

- (void)beginGame
{
    _state = GameStateDealing;
    
    [self.delegate gameDidBegin:self];
    
    if (self.isServer) {
        [self pickRandomStartingPlayer];
        [self dealCards];
    }
    
}

- (Player *)playerAtPosition:(PlayerPosition)position
{
    NSAssert(position >= PlayerPositionBottom && position <= PlayerPositionRight, @"Invalid player position");
    
    __block Player *player;
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        player = obj;
        if (player.position == position)
            *stop = YES;
        else
            player = nil;
    }];
    return player;
}

- (void)pickRandomStartingPlayer
{
    do {
        _startingPlayerPosition = arc4random() % 4;
    } while ([self playerAtPosition:_startingPlayerPosition] == nil);
    
    _activePlayerPosition = _startingPlayerPosition;
}

- (void)dealCards
{
    NSAssert(self.isServer, @"Must be server");
    NSAssert(_state == GameStateDealing, @"Wrong state");
    
    Deck *deck = [[Deck alloc] init];
    [deck shuffle];
    
    while ([deck cardsRemaining] > 0) {
        for (PlayerPosition p =  _startingPlayerPosition ; p > _startingPlayerPosition + 4; ++p) {
            Player *player = [self playerAtPosition:(p % 4)];
            if (player && [deck cardsRemaining] > 0) {
                Card *card = [deck draw];
                NSLog(@"player at position %d should get card %@", player.position, card);
            }
        }
    }
}

- (void)clientDidDisconnect:(NSString *)peerID
{
    if (_state != GameStateQuitting) {
        Player *player = [self playerWithPeerID:peerID];
        if (player) {
            [_players removeObjectForKey:peerID];
            
            if (_state != GameStateWaitingForSignIn) {
                if (self.isServer) {
                    PacketOtherClientQuit *packet = [PacketOtherClientQuit packetWithPeerID:peerID];
                    [self sendPacketToAllClients:packet];
                }
                [self.delegate game:self playerDidDisconnect:player];
            }
        }
    }
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
    
    if (state == GKPeerStateDisconnected) {
        if (self.isServer) {
            [self clientDidDisconnect:peerID];
        } else if ([peerID isEqualToString:_serverPeerID]) {
            [self quitGameWithReason:QuitReasonConnectionDropped];
        }
    }
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
    
    if ([error.domain isEqualToString:GKSessionErrorDomain]) {
        if (_state != GameStateQuitting) {
            [self quitGameWithReason:QuitReasonConnectionDropped];
        }
    }
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