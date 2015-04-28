//
//  GameViewController.m
//  BangBangBang
//
//  Created by Adrian on 15/4/5.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "GameViewController.h"

#import "UIFont+SnapAdditions.h"

#import "Game.h"
#import "Player.h"
#import "Card.h"
#import "CardView.h"
#import "Stack.h"


@interface GameViewController ()

{
    UIAlertView *_alertView;
    AVAudioPlayer *_dealingCardsSound;
    AVAudioPlayer *_turnCardSound;
    UIImageView *_tappedView;
}

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIView *cardContainerView;
@property (nonatomic, weak) IBOutlet UIButton *turnOverButton;
@property (nonatomic, weak) IBOutlet UIButton *snapButton;
@property (nonatomic, weak) IBOutlet UIButton *nextRoundButton;
@property (nonatomic, weak) IBOutlet UIImageView *wrongSnapImageView;
@property (nonatomic, weak) IBOutlet UIImageView *correctSnapImageView;

@property (weak, nonatomic) IBOutlet UILabel *centerLabel;

@property (nonatomic, weak) IBOutlet UILabel *playerNameBottomLabel;
@property (nonatomic, weak) IBOutlet UILabel *playerNameLeftLabel;
@property (nonatomic, weak) IBOutlet UILabel *playerNameTopLabel;
@property (nonatomic, weak) IBOutlet UILabel *playerNameRightLabel;

@property (nonatomic, weak) IBOutlet UILabel *playerWinsBottomLabel;
@property (nonatomic, weak) IBOutlet UILabel *playerWinsLeftLabel;
@property (nonatomic, weak) IBOutlet UILabel *playerWinsTopLabel;
@property (nonatomic, weak) IBOutlet UILabel *playerWinsRightLabel;

@property (nonatomic, weak) IBOutlet UIImageView *playerActiveBottomImageView;
@property (nonatomic, weak) IBOutlet UIImageView *playerActiveLeftImageView;
@property (nonatomic, weak) IBOutlet UIImageView *playerActiveTopImageView;
@property (nonatomic, weak) IBOutlet UIImageView *playerActiveRightImageView;

@property (nonatomic, weak) IBOutlet UIImageView *snapIndicatorBottomImageView;
@property (nonatomic, weak) IBOutlet UIImageView *snapIndicatorLeftImageView;
@property (nonatomic, weak) IBOutlet UIImageView *snapIndicatorTopImageView;
@property (nonatomic, weak) IBOutlet UIImageView *snapIndicatorRightImageView;

@end

@implementation GameViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.centerLabel.font = [UIFont rw_snapFontWithSize:18.0f];
    
    self.snapButton.hidden = YES;
    self.nextRoundButton.hidden = YES;
    self.wrongSnapImageView.hidden = YES;
    self.correctSnapImageView.hidden = YES;
    
    [self hidePlayerLabels];
    [self hideActivePlayerIndicator];
    [self hideSnapIndicators];
    [self loadSounds];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_alertView dismissWithClickedButtonIndex:_alertView.cancelButtonIndex animated:NO];
}

#pragma mark - Action

- (IBAction)exitAction:(UIButton *)sender
{
    if (self.game.isServer) {
        _alertView = [[UIAlertView alloc]
                      initWithTitle:NSLocalizedString(@"End Game", @"Alert title (user is host)")
                      message:NSLocalizedString(@"This will terminal the game for all other players", @"Alert message (user is host)")
                      delegate:self
                      cancelButtonTitle:NSLocalizedString(@"No", @"Button : No")
                      otherButtonTitles:NSLocalizedString(@"Yes", @"Button Yes"),
                      nil];
        [_alertView show];
    } else {
        _alertView = [[UIAlertView alloc]
                      initWithTitle: NSLocalizedString(@"Leave Game?", @"Alert title (user is not host)")
                      message:nil
                      delegate:self
                      cancelButtonTitle:NSLocalizedString(@"No", @"Button: No")
                      otherButtonTitles:NSLocalizedString(@"Yes", @"Button: Yes"),
                      nil];
        
        [_alertView show];

    }
}

- (IBAction)turnOverPressed:(id)sender
{
    [self showTappedView];
}

- (IBAction)turnOverEnter:(id)sender
{
    [self showTappedView];
}

- (IBAction)turnOverExit:(id)sender
{
    [self hideTappedView];
}

- (IBAction)turnOverAction:(id)sender
{
    [self hideTappedView];
    [self.game turnCardForPlayerAtBottom];
}

- (IBAction)snapAction:(id)sender
{
}

- (IBAction)nextRoundAction:(id)sender
{
}


#pragma mark - Game UI

- (void)hidePlayerLabels
{
    self.playerNameBottomLabel.hidden = YES;
    self.playerWinsBottomLabel.hidden = YES;
    
    self.playerNameLeftLabel.hidden = YES;
    self.playerWinsLeftLabel.hidden = YES;
    
    self.playerNameTopLabel.hidden = YES;
    self.playerWinsTopLabel.hidden = YES;
    
    self.playerNameRightLabel.hidden = YES;
    self.playerWinsRightLabel.hidden = YES;
}

- (void)hideActivePlayerIndicator
{
    self.playerActiveBottomImageView.hidden = YES;
    self.playerActiveLeftImageView.hidden   = YES;
    self.playerActiveTopImageView.hidden    = YES;
    self.playerActiveRightImageView.hidden  = YES;
}

- (void)hideSnapIndicators
{
    self.snapIndicatorBottomImageView.hidden = YES;
    self.snapIndicatorLeftImageView.hidden   = YES;
    self.snapIndicatorTopImageView.hidden    = YES;
    self.snapIndicatorRightImageView.hidden  = YES;
}

- (void)showPlayerLabels
{
    Player *player = [self.game playerAtPosition:PlayerPositionBottom];
    if (player != nil) {
        self.playerNameBottomLabel.hidden = NO;
        self.playerWinsBottomLabel.hidden = NO;
    }
    
    player = [self.game playerAtPosition:PlayerPositionLeft];
    if (player != nil)
    {
        self.playerNameLeftLabel.hidden = NO;
        self.playerWinsLeftLabel.hidden = NO;
    }
    
    player = [self.game playerAtPosition:PlayerPositionTop];
    if (player != nil)
    {
        self.playerNameTopLabel.hidden = NO;
        self.playerWinsTopLabel.hidden = NO;
    }
    
    player = [self.game playerAtPosition:PlayerPositionRight];
    if (player != nil)
    {
        self.playerNameRightLabel.hidden = NO;
        self.playerWinsRightLabel.hidden = NO;
    }
}

- (void)updateWinsLabels
{
    NSString *format = NSLocalizedString(@"%@ Won", @"Number of Games Won");
    
    Player *player = [self.game playerAtPosition:PlayerPositionBottom];
    if (player != nil)
        self.playerWinsBottomLabel.text = [NSString stringWithFormat:format, player.gamesWon];
    
    player = [self.game playerAtPosition:PlayerPositionLeft];
    if (player != nil)
        self.playerWinsLeftLabel.text = [NSString stringWithFormat:format, player.gamesWon];
    
    player = [self.game playerAtPosition:PlayerPositionTop];
    if (player != nil)
        self.playerWinsTopLabel.text = [NSString stringWithFormat:format, player.gamesWon];
    
    player = [self.game playerAtPosition:PlayerPositionRight];
    if (player != nil)
        self.playerWinsRightLabel.text = [NSString stringWithFormat:format, player.gamesWon];
}

- (void)resizeLabelToFit:(UILabel *)label
{
    [label sizeToFit];
    
    CGRect rect = label.frame;
    rect.size.width = ceilf(rect.size.width / 2.0f) * 2.0f;
    rect.size.height = ceilf(rect.size.height / 2.0f) * 2.0f;
    
    label.frame = rect;
}

- (void)caculateLabelFrames
{
    UIFont *font = [UIFont rw_snapFontWithSize:14.0f];
    self.playerNameBottomLabel.font = font;
    self.playerNameLeftLabel.font = font;
    self.playerNameTopLabel.font = font;
    self.playerNameRightLabel.font = font;
    
    font = [UIFont rw_snapFontWithSize:11.0f];
    self.playerWinsBottomLabel.font = font;
    self.playerWinsLeftLabel.font = font;
    self.playerWinsTopLabel.font = font;
    self.playerWinsRightLabel.font = font;
    
    self.playerWinsBottomLabel.layer.cornerRadius = 4.0f;
    self.playerWinsLeftLabel.layer.cornerRadius = 4.0f;
    self.playerWinsTopLabel.layer.cornerRadius = 4.0f;
    self.playerWinsRightLabel.layer.cornerRadius = 4.0f;
    
    UIImage *image = [[UIImage imageNamed:@"ActivePlayer"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    self.playerActiveBottomImageView.image = image;
    self.playerActiveLeftImageView.image = image;
    self.playerActiveTopImageView.image = image;
    self.playerActiveRightImageView.image = image;
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat centerX = viewWidth / 2.0f;
 
    Player *player = [self.game playerAtPosition:PlayerPositionBottom];
    if (player != nil)
    {
        self.playerNameBottomLabel.text = player.name;
        
        [self resizeLabelToFit:self.playerNameBottomLabel];
        CGFloat labelWidth = self.playerNameBottomLabel.bounds.size.width;
        
        CGPoint point = CGPointMake(centerX - 19.0f - 3.0f, 306.0f);
        self.playerNameBottomLabel.center = point;
        
        CGPoint winsPoint = point;
        winsPoint.x += labelWidth/2.0f + 6.0f + 19.0f;
        winsPoint.y -= 0.5f;
        self.playerWinsBottomLabel.center = winsPoint;
        
        self.playerActiveBottomImageView.frame = CGRectMake(0, 0, 20.0f + labelWidth + 6.0f + 38.0f + 2.0f, 20.0f);
        
        point.x = centerX - 9.0f;
        self.playerActiveBottomImageView.center = point;
    }
    
    player = [self.game playerAtPosition:PlayerPositionLeft];
    if (player != nil)
    {
        self.playerNameLeftLabel.text = player.name;
        
        [self resizeLabelToFit:self.playerNameLeftLabel];
        CGFloat labelWidth = self.playerNameLeftLabel.bounds.size.width;
        
        CGPoint point = CGPointMake(2.0 + 20.0f + labelWidth/2.0f, 48.0f);
        self.playerNameLeftLabel.center = point;
        
        CGPoint winsPoint = point;
        winsPoint.x += labelWidth/2.0f + 6.0f + 19.0f;
        winsPoint.y -= 0.5f;
        self.playerWinsLeftLabel.center = winsPoint;
        
        self.playerActiveLeftImageView.frame = CGRectMake(2.0f, 38.0f, 20.0f + labelWidth + 6.0f + 38.0f + 2.0f, 20.0f);
    }
    
    player = [self.game playerAtPosition:PlayerPositionTop];
    if (player != nil)
    {
        self.playerNameTopLabel.text = player.name;
        
        [self resizeLabelToFit:self.playerNameTopLabel];
        CGFloat labelWidth = self.playerNameTopLabel.bounds.size.width;
        
        CGPoint point = CGPointMake(centerX - 19.0f - 3.0f, 15.0f);
        self.playerNameTopLabel.center = point;
        
        CGPoint winsPoint = point;
        winsPoint.x += labelWidth/2.0f + 6.0f + 19.0f;
        winsPoint.y -= 0.5f;
        self.playerWinsTopLabel.center = winsPoint;
        
        self.playerActiveTopImageView.frame = CGRectMake(0, 0, 20.0f + labelWidth + 6.0f + 38.0f + 2.0f, 20.0f);
        
        point.x = centerX - 9.0f;
        self.playerActiveTopImageView.center = point;
    }
    
    player = [self.game playerAtPosition:PlayerPositionRight];
    if (player != nil)
    {
        self.playerNameRightLabel.text = player.name;
        
        [self resizeLabelToFit:self.playerNameRightLabel];
        CGFloat labelWidth = self.playerNameRightLabel.bounds.size.width;
        
        CGPoint point = CGPointMake(viewWidth - labelWidth/2.0f - 2.0f - 6.0f - 38.0f - 12.0f, 48.0f);
        self.playerNameRightLabel.center = point;
        
        CGPoint winsPoint = point;
        winsPoint.x += labelWidth/2.0f + 6.0f + 19.0f;
        winsPoint.y -= 0.5f;
        self.playerWinsRightLabel.center = winsPoint;
        
        self.playerActiveRightImageView.frame = CGRectMake(self.playerNameRightLabel.frame.origin.x - 20.0f, 38.0f, 20.0f + labelWidth + 6.0f + 38.0f + 2.0f, 20.0f);
    }
}

- (void)hidePlayerLabelsForPlayer:(Player *)player
{
    switch (player.position)
    {
        case PlayerPositionBottom:
            self.playerNameBottomLabel.hidden = YES;
            self.playerWinsBottomLabel.hidden = YES;
            break;
            
        case PlayerPositionLeft:
            self.playerNameLeftLabel.hidden = YES;
            self.playerWinsLeftLabel.hidden = YES;
            break;
            
        case PlayerPositionTop:
            self.playerNameTopLabel.hidden = YES;
            self.playerWinsTopLabel.hidden = YES;
            break;
            
        case PlayerPositionRight:
            self.playerNameRightLabel.hidden = YES;
            self.playerWinsRightLabel.hidden = YES;
            break;
    }
}

- (void)hideActiveIndicatorForPlayer:(Player *)player
{
    switch (player.position)
    {
        case PlayerPositionBottom: self.playerActiveBottomImageView.hidden = YES; break;
        case PlayerPositionLeft:   self.playerActiveLeftImageView.hidden   = YES; break;
        case PlayerPositionTop:    self.playerActiveTopImageView.hidden    = YES; break;
        case PlayerPositionRight:  self.playerActiveRightImageView.hidden  = YES; break;
    }
}

- (void)hideSnapIndicatorForPlayer:(Player *)player
{
    switch (player.position)
    {
        case PlayerPositionBottom: self.snapIndicatorBottomImageView.hidden = YES; break;
        case PlayerPositionLeft:   self.snapIndicatorLeftImageView.hidden   = YES; break;
        case PlayerPositionTop:    self.snapIndicatorTopImageView.hidden    = YES; break;
        case PlayerPositionRight:  self.snapIndicatorRightImageView.hidden  = YES; break;
    }
}

- (void)afterDealing
{
    [_dealingCardsSound stop];
    self.snapButton.hidden = NO;
    [self.game beginRound];
}


- (void)showIndicatorForActivePlayer
{
    [self hideActivePlayerIndicator];
    
    PlayerPosition position = [self.game activePlayer].position;
    switch (position) {
        case PlayerPositionBottom: self.playerActiveBottomImageView.hidden = NO; break;
        case PlayerPositionLeft: self.playerActiveLeftImageView.hidden = NO; break;
        case PlayerPositionTop: self.playerActiveTopImageView.hidden = NO; break;
        case PlayerPositionRight: self.playerActiveRightImageView.hidden = NO; break;
        default: break;
    }
    
    if (position == PlayerPositionBottom) {
        self.centerLabel.text = NSLocalizedString(@"Your turn : tap stack", @"Status text : your turn");
    } else {
        self.centerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ turn", @"Status text : other player's turn"), [self.game activePlayer].name];
    }
}

- (void)showTappedView
{
    Player *player = [self.game playerAtPosition:PlayerPositionBottom];
    Card *card = [player.closedCards topmostCard];
    if (card) {
        CardView *cardView = [self cardViewForCard:card];
        if (!_tappedView) {
            _tappedView = [[UIImageView alloc] initWithFrame:cardView.bounds];
            _tappedView.backgroundColor = [UIColor clearColor];
            _tappedView.image = [UIImage imageNamed:@"Darken"];
            _tappedView.alpha = 0.6f;
            [self.view addSubview:_tappedView];
        } else {
            _tappedView.hidden = NO;
        }
        
        _tappedView.center = cardView.center;
        _tappedView.transform = cardView.transform;
    }
}

- (void)hideTappedView
{
    _tappedView.hidden = YES;
}

- (CardView *)cardViewForCard:(Card *)card
{
    for (CardView *cardView in self.cardContainerView.subviews) {
        if (cardView.card == card) {
            return cardView;
        }
    }
    return nil;
}

#pragma mark - Sounds

- (void)loadSounds
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    audioSession.delegate = nil;
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:NULL];
    [audioSession setActive:YES error:NULL];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Dealing" withExtension:@"caf"];
    _dealingCardsSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _dealingCardsSound.numberOfLoops = -1;
    [_dealingCardsSound prepareToPlay];
    
    url = [[NSBundle mainBundle] URLForResource:@"TurnCard" withExtension:@"caf"];
    _turnCardSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_turnCardSound prepareToPlay];
}

#pragma mark - GameDelegate

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason
{
    [self.delegate gameViewController:self didQuitWithReason:reason];
}

- (void)gameWaitingForServerReady:(Game *)game
{
    self.centerLabel.text = NSLocalizedString(@"正在等待游戏开始...", @"Status text: waiting for server");
}

- (void)gameWaitingForClientsReady:(Game *)game
{
    self.centerLabel.text = NSLocalizedString(@"正在等待其它游戏玩家...", @"Status text: waiting for clients");
}

- (void)gameDidBegin:(Game *)game
{
    [self showPlayerLabels];
    [self caculateLabelFrames];
    [self updateWinsLabels];
}

- (void)game:(Game *)game playerDidDisconnect:(Player *)disconnectedPlayer
{
    [self hidePlayerLabelsForPlayer:disconnectedPlayer];
    [self hideActiveIndicatorForPlayer:disconnectedPlayer];
    [self hideSnapIndicatorForPlayer:disconnectedPlayer];
}

- (void)gameShouldDealCards:(Game *)game startingWithPlayer:(Player *)startingPlayer
{
    self.centerLabel.text = NSLocalizedString(@"游戏处理中...", @"Status text: dealing");
    
    self.snapButton.hidden = YES;
    self.nextRoundButton.hidden = YES;
    
    NSTimeInterval delay = 1.0f;
    
    _dealingCardsSound.currentTime = 0.0f;
    [_dealingCardsSound prepareToPlay];
    [_dealingCardsSound performSelector:@selector(play) withObject:nil afterDelay:delay];
    
    
    for (int t = 0; t < 26; ++t) {
        for (PlayerPosition p = startingPlayer.position; p < startingPlayer.position + 4; ++p) {
            Player *player = [self.game playerAtPosition:p % 4];
            if (player != nil && t < [player.closedCards cardCount]) {
                CardView *cardView = [[CardView alloc] initWithFrame:CGRectMake(0, 0, CardWidth, CardHeight)];
                cardView.card = [player.closedCards cardAtIndex:t];
                [self.cardContainerView addSubview:cardView];
                [cardView animateDealingToPlayer:player withDelay:delay];
                delay += 0.1f;
            }
        }
    }
    
    [self performSelector:@selector(afterDealing) withObject:nil afterDelay:delay];
}

- (void)game:(Game *)game didActivatePlayer:(Player *)player
{
    [self showIndicatorForActivePlayer];
    self.snapButton.hidden = YES;
}

- (void)game:(Game *)game player:(Player *)player turnedOverCard:(Card *)card
{
    [_turnCardSound play];
    
    CardView *cardView = [self cardViewForCard:card];
    [cardView animateTurningOverForPlayer:player];
}


#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [self.game quitGameWithReason:QuitReasonUserQuit];
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
    
    [_dealingCardsSound stop];
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
}


@end
