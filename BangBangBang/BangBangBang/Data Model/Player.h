//
//  Player.h
//  BangBangBang
//
//  Created by Zhu Dengquan on 15/4/10.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

typedef enum
{
    PlayerPositionBottom, // the user
    PlayerPositionLeft,
    PlayerPositionTop,
    PlayerPositionRight
}
PlayerPosition;

@interface Player : NSObject

@property (nonatomic, assign) PlayerPosition position;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *peerID;

@property (nonatomic, assign) BOOL receivedResponse;

@property (nonatomic, assign) int gamesWon;


@end
