//
//  Game.m
//  BangBangBang
//
//  Created by Adrian on 15/4/5.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


#import "Game.h"
#import "Packet.h"
#import "PacketSignInResponse.h"
#import "PacketServerReady.h"
#import "PacketOtherClientQuit.h"
#import "PacketDealCards.h"
#import "PacketActivatePlayer.h"
#import "Card.h"
#import "Deck.h"
#import "Player.h"


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
    
    BOOL _firstTime;
}

@synthesize delegate = _delegate;
@synthesize isServer = _isServer;

- (id)init
{
    if ((self = [super init]))
    {
        _players = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"dealloc %@", self);
#endif
}

#pragma mark - Game Logic

- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID
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

- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients
{
    self.isServer = YES;
    
    _session = session;
    _session.available = NO;
    _session.delegate = self;
    [_session setDataReceiveHandler:self withContext:nil];
    
    _state = GameStateWaitingForSignIn;
    
    [self.delegate gameWaitingForClientsReady:self];
    
    // Create the Player object for the server.
    Player *player = [[Player alloc] init];
    player.name = name;
    player.peerID = _session.peerID;
    player.position = PlayerPositionBottom;
    [_players setObject:player forKey:player.peerID];
    
    // Add a Player object for each client.
    int index = 0;
    for (NSString *peerID in clients)
    {
        Player *player = [[Player alloc] init];
        player.peerID = peerID;
        [_players setObject:player forKey:player.peerID];
        
        if (index == 0)
            player.position = ([clients count] == 1) ? PlayerPositionTop : PlayerPositionLeft;
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
    
    if (reason == QuitReasonUserQuit)
    {
        if (self.isServer)
        {
            Packet *packet = [Packet packetWithType:PacketTypeServerQuit];
            [self sendPacketToAllClients:packet];
        }
        else
        {
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
    switch (packet.packetType)
    {
        case PacketTypeSignInRequest:
            if (_state == GameStateWaitingForSignIn)
            {
                _state = GameStateWaitingForReady;
                
                Packet *packet = [PacketSignInResponse packetWithPlayerName:_localPlayerName];
                [self sendPacketToServer:packet];
            }
            break;
            
        case PacketTypeServerReady:
            if (_state == GameStateWaitingForReady)
            {
                _players = ((PacketServerReady *)packet).players;
                [self changeRelativePositionsOfPlayers];
                
                Packet *packet = [Packet packetWithType:PacketTypeClientReady];
                [self sendPacketToServer:packet];
                
                [self beginGame];
            }
            break;
            
        case PacketTypeOtherClientQuit:
            if (_state != GameStateQuitting)
            {
                PacketOtherClientQuit *quitPacket = ((PacketOtherClientQuit *)packet);
                [self clientDidDisconnect:quitPacket.peerID];
            }
            break;
            
        case PacketTypeServerQuit:
            [self quitGameWithReason:QuitReasonServerQuit];
            break;
            
        case PacketTypeDealCards:
            if (_state == GameStateDealing)
            {
                [self handleDealCardsPacket:(PacketDealCards *)packet];
            }
            break;
            
        case PacketTypeActivatePlayer:
            if (_state == GameStateDealing)
            {
                [self handleActivatePlayerPacket:(PacketActivatePlayer *)packet];
            }
            break;
            
        default:
            NSLog(@"Client received unexpected packet: %@", packet);
            break;
    }
}

- (BOOL)receivedResponsesFromAllPlayers
{
    for (NSString *peerID in _players)
    {
        Player *player = [self playerWithPeerID:peerID];
        if (!player.receivedResponse)
            return NO;
    }
    return YES;
}

- (void)serverReceivedPacket:(Packet *)packet fromPlayer:(Player *)player
{
    switch (packet.packetType)
    {
        case PacketTypeSignInResponse:
            if (_state == GameStateWaitingForSignIn)
            {
                player.name = ((PacketSignInResponse *)packet).playerName;
                
                if ([self receivedResponsesFromAllPlayers])
                {
                    _state = GameStateWaitingForReady;
                    
                    Packet *packet = [PacketServerReady packetWithPlayers:_players];
                    [self sendPacketToAllClients:packet];
                }
            }
            break;
            
        case PacketTypeClientReady:
            NSLog(@"State: %d, received Responses: %d", _state, [self receivedResponsesFromAllPlayers]);
            if (_state == GameStateWaitingForReady && [self receivedResponsesFromAllPlayers])
            {
                [self beginGame];
            }
            break;
        case PacketTypeClientDealtCards:
            if (_state == GameStateDealing && [self receivedResponsesFromAllPlayers])
            {
                _state = GameStatePlaying;
            }
            break;
            
        case PacketTypeClientQuit:
            [self clientDidDisconnect:player.peerID];
            break;
            
        case PacketTypeClientTurnedCard:
            if (_state == GameStatePlaying && player == [self activePlayer])
            {
                [self turnCardForActivePlayer];
            }
            break;
            
        default:
            NSLog(@"Server received unexpected packet: %@", packet);
            break;
    }
}

- (Player *)playerWithPeerID:(NSString *)peerID
{
    return [_players objectForKey:peerID];
}

- (void)beginGame
{
    _firstTime = YES;
    
    _state = GameStateDealing;
    [self.delegate gameDidBegin:self];
    
    if (self.isServer)
    {
        [self pickRandomStartingPlayer];
        [self dealCards];
    }
}

- (void)pickRandomStartingPlayer
{
    do
    {
        _startingPlayerPosition = arc4random() % 4;
    }
    while ([self playerAtPosition:_startingPlayerPosition] == nil);
    
    _activePlayerPosition = _startingPlayerPosition;
}

- (void)dealCards
{
    NSAssert(self.isServer, @"Must be server");
    NSAssert(_state == GameStateDealing, @"Wrong state");
    
    Deck *deck = [[Deck alloc] init];
    [deck shuffle];
    
    while ([deck cardsRemaining] > 0)
    {
        for (PlayerPosition p = _startingPlayerPosition; p < _startingPlayerPosition + 4; ++p)
        {
            Player *player = [self playerAtPosition:(p % 4)];
            if (player != nil && [deck cardsRemaining] > 0)
            {
                Card *card = [deck draw];
                [player.closedCards addCardToTop:card];
            }
        }
    }
    Player *startingPlayer = [self activePlayer];
    
    NSMutableDictionary *playerCards = [NSMutableDictionary dictionaryWithCapacity:4];
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         NSArray *array = [obj.closedCards array];
         [playerCards setObject:array forKey:obj.peerID];
     }];
    
    PacketDealCards *packet = [PacketDealCards packetWithCards:playerCards startingWithPlayerPeerID:startingPlayer.peerID];
    [self sendPacketToAllClients:packet];
    
    [self.delegate gameShouldDealCards:self startingWithPlayer:startingPlayer];
}

- (Player *)activePlayer
{
    return [self playerAtPosition:_activePlayerPosition];
}

- (void)changeRelativePositionsOfPlayers
{
    NSAssert(!self.isServer, @"Must be client");
    
    Player *myPlayer = [self playerWithPeerID:_session.peerID];
    int diff = myPlayer.position;
    myPlayer.position = PlayerPositionBottom;
    
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         if (obj != myPlayer)
         {
             obj.position = (obj.position - diff) % 4;
         }
     }];
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

- (void)beginRound
{
    [self activatePlayerAtPosition:_activePlayerPosition];
}

- (void)activatePlayerAtPosition:(PlayerPosition)playerPosition
{
    if (self.isServer) {
        NSString *peerID = [self activePlayer].peerID;
        Packet *packet = [PacketActivatePlayer packetWithPeerID:peerID];
        [self sendPacketToAllClients:packet];
    }
    
    [self.delegate game:self didActivatePlayer:[self activePlayer]];
}

- (void)activateNextPlayer
{
    NSAssert(self.isServer, @"Must be server");
    
    while (true)
    {
        _activePlayerPosition++;
        if (_activePlayerPosition > PlayerPositionRight)
            _activePlayerPosition = PlayerPositionBottom;
        
        Player *nextPlayer = [self activePlayer];
        if (nextPlayer != nil)
        {
            [self activatePlayerAtPosition:_activePlayerPosition];
            return;
        }
    }
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
    NSLog(@"Game: peer %@ changed state %d", peerID, state);
#endif
    
    if (state == GKPeerStateDisconnected)
    {
        if (self.isServer)
        {
            [self clientDidDisconnect:peerID];
        }
        else if ([peerID isEqualToString:_serverPeerID])
        {
            [self quitGameWithReason:QuitReasonConnectionDropped];
        }
    }
}
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
    NSLog(@"Game: connection request from peer %@", peerID);
#endif
    
    [session denyConnectionFromPeer:peerID];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Game: connection with peer %@ failed %@", peerID, error);
#endif
    
    // Not used.
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Game: session failed %@", error);
#endif
    
    if ([[error domain] isEqualToString:GKSessionErrorDomain])
    {
        if (_state != GameStateQuitting)
        {
            [self quitGameWithReason:QuitReasonConnectionDropped];
        }
    }
}

#pragma mark - GKSession Data Receive Handler

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
#ifdef DEBUG
    NSLog(@"Game: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
#endif
    
    Packet *packet = [Packet packetWithData:data];
    if (packet == nil)
    {
        NSLog(@"Invalid packet: %@", data);
        return;
    }
    
    Player *player = [self playerWithPeerID:peerID];
    if (player != nil)
    {
        player.receivedResponse = YES;  // this is the new bit
    }
    
    if (self.isServer)
        [self serverReceivedPacket:packet fromPlayer:player];
    else
        [self clientReceivedPacket:packet];
}

#pragma mark - Networking

- (void)sendPacketToAllClients:(Packet *)packet
{
    GKSendDataMode dataMode = GKSendDataReliable;
    NSData *data = [packet data];
    NSError *error;
    
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         obj.receivedResponse = [_session.peerID isEqualToString:obj.peerID];
     }];
    
    if (![_session sendDataToAllPeers:data withDataMode:dataMode error:&error])
    {
        NSLog(@"Error sending data to clients: %@", error);
    }
}

- (void)sendPacketToServer:(Packet *)packet
{
    GKSendDataMode dataMode = GKSendDataReliable;
    NSData *data = [packet data];
    NSError *error;
    if (![_session sendData:data toPeers:[NSArray arrayWithObject:_serverPeerID] withDataMode:dataMode error:&error])
    {
        NSLog(@"Error sending data to server: %@", error);
    }
}

- (void)clientDidDisconnect:(NSString *)peerID
{
    if (_state != GameStateQuitting)
    {
        Player *player = [self playerWithPeerID:peerID];
        if (player != nil)
        {
            [_players removeObjectForKey:peerID];
            
            if (_state != GameStateWaitingForSignIn)
            {
                // Tell the other clients that this one is now disconnected.
                if (self.isServer)
                {
                    PacketOtherClientQuit *packet = [PacketOtherClientQuit packetWithPeerID:peerID];
                    [self sendPacketToAllClients:packet];
                }			
                
                [self.delegate game:self playerDidDisconnect:player];
            }
        }
    }
}

- (void)handleDealCardsPacket:(PacketDealCards *)packet
{
    [packet.cards enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         Player *player = [self playerWithPeerID:key];
         [player.closedCards addCardsFromArray:obj];
     }];
    
    Player *startingPlayer = [self playerWithPeerID:packet.startingPeerID];
    _activePlayerPosition = startingPlayer.position;
    
    Packet *responsePacket = [Packet packetWithType:PacketTypeClientDealtCards];
    [self sendPacketToServer:responsePacket];
    
    _state = GameStatePlaying;
    
    [self.delegate gameShouldDealCards:self startingWithPlayer:startingPlayer];
}

- (void)handleActivatePlayerPacket:(PacketActivatePlayer *)packet
{
    if (_firstTime) {
        _firstTime = NO;
        return;
    }
    
    NSString *peerID = packet.peerID;
    
    Player *newPlayer = [self playerWithPeerID:peerID];
    if(!newPlayer) return;
        
    [self performSelector:@selector(activatePlayerWithPeerID:) withObject:peerID afterDelay:0.5f];
}

- (void)activatePlayerWithPeerID:(NSString *)peerID
{
    NSAssert(!self.isServer, @"Must be client");
    
    Player *player = [self playerWithPeerID:peerID];
    _activePlayerPosition = player.position;
    [self activatePlayerAtPosition:_activePlayerPosition];
}

- (void)turnCardForPlayerAtBottom
{
    if (_state == GameStatePlaying
        && _activePlayerPosition == PlayerPositionBottom
        && [[self activePlayer].closedCards cardCount] > 0)
    {
        [self turnCardForActivePlayer];
        
        if (!self.isServer)
        {
            Packet *packet = [Packet packetWithType:PacketTypeClientTurnedCard];
            [self sendPacketToServer:packet];
        }
    }
}

- (void)turnCardForPlayer:(Player *)player
{
    NSAssert([player.closedCards cardCount] > 0, @"Player has no more cards");
    
    Card *card = [player turnOverTopCard];
    [self.delegate game:self player:player turnedOverCard:card];
}


- (void)turnCardForActivePlayer
{
    [self turnCardForPlayer:[self activePlayer]];
    
    if (self.isServer) {
        [self performSelector:@selector(activateNextPlayer) withObject:nil afterDelay:0.5f];
    }
}



@end
