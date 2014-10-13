//
//  HomeScene.m
//  Fours
//
//  Created by Halko, Jaayden on 6/5/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "HomeScene.h"
#import "GameScene.h"
//#import "Flurry.h"
#import "AppDelegate.h"
#import "Match.h"

typedef NS_ENUM(NSInteger, IIMySceneZPosition)
{
    kIIMySceneZPositionScrolling = 0,
    kIIMySceneZPositionVerticalAndHorizontalScrolling,
    kIIMySceneZPositionStatic,
};

@interface HomeScene ()

@property BOOL contentCreated;

//kIIMySceneZPositionScrolling
@property (nonatomic, weak) SKSpriteNode *spriteToScroll;

//kIIMySceneZPositionStatic
@property (nonatomic, weak) SKSpriteNode *spriteForStaticGeometry;

//kIIMySceneZPositionVerticalAndHorizontalScrolling
@property (nonatomic, weak) SKSpriteNode *spriteToHostHorizontalAndVerticalScrolling;
@property (nonatomic, weak) SKSpriteNode *spriteForVerticalScrolling;

@end

@implementation HomeScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self setAnchorPoint:(CGPoint){0,1}];
        SKSpriteNode *spriteToScroll = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:size];
        [spriteToScroll setAnchorPoint:(CGPoint){0,1}];
        [spriteToScroll setZPosition:kIIMySceneZPositionScrolling];
        [self addChild:spriteToScroll];
        
        //Overlay sprite to make anchor point 0,0 (lower left, default for SK)
        SKSpriteNode *spriteForScrollingGeometry = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:size];
        [spriteForScrollingGeometry setAnchorPoint:(CGPoint){0,0}];
        [spriteForScrollingGeometry setPosition:(CGPoint){0, -size.height}];
        [spriteToScroll addChild:spriteForScrollingGeometry];
        
        SKSpriteNode *spriteForStaticGeometry = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:size];
        [spriteForStaticGeometry setAnchorPoint:(CGPoint){0,0}];
        [spriteForStaticGeometry setPosition:(CGPoint){0, -size.height}];
        [spriteForStaticGeometry setZPosition:kIIMySceneZPositionStatic];
        [self addChild:spriteForStaticGeometry];
        
        SKSpriteNode *spriteToHostHorizontalAndVerticalScrolling = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:size];
        [spriteToHostHorizontalAndVerticalScrolling setAnchorPoint:(CGPoint){0,0}];
        [spriteToHostHorizontalAndVerticalScrolling setPosition:(CGPoint){0, -size.height}];
        [spriteToHostHorizontalAndVerticalScrolling setZPosition:kIIMySceneZPositionVerticalAndHorizontalScrolling];
        [self addChild:spriteToHostHorizontalAndVerticalScrolling];
        
        CGSize upAndDownSize = size;
        upAndDownSize.width = 30;
        SKSpriteNode *spriteForVerticalScrolling = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:upAndDownSize];
        [spriteForVerticalScrolling setAnchorPoint:(CGPoint){0,0}];
        [spriteForVerticalScrolling setPosition:(CGPoint){0,30}];
        [spriteToHostHorizontalAndVerticalScrolling addChild:spriteForVerticalScrolling];
        
        CGSize leftToRightSize = size;
        leftToRightSize.height = 30;
        
        //Set properties
        _contentSize = size;
        _spriteToScroll = spriteToScroll;
        _spriteForScrollingGeometry = spriteForScrollingGeometry;
        _spriteForStaticGeometry = spriteForStaticGeometry;
        _spriteToHostHorizontalAndVerticalScrolling = spriteToHostHorizontalAndVerticalScrolling;
        _spriteForVerticalScrolling = spriteForVerticalScrolling;
        _contentOffset = (CGPoint){0,0};
        
    }
    
    return self;
}

- (void)displayMatchList:(NSArray*)matches {
    int matchNumber = 0;

    for (GKTurnBasedMatch *match in matches) {
        
        Match *matchNode = [Match spriteNodeWithColor:[SKColor greenColor]
                                                               size:(CGSize){.width = 320,
                                                                   .height = 90}];
        [matchNode setAnchorPoint:(CGPoint){0,0}];
        [matchNode setPosition:CGPointMake(0, matchNumber * 100)];
        
        matchNode.matchData = match.matchData;
        matchNode.matchId = match.matchID;
        matchNode.match = match;
        
        if (match.status == GKTurnBasedMatchStatusMatching) {
            matchNode.matchStatus = @"Finding Player";
        }
        
        NSString *opponentPlayerId;
        NSString *opponentDisplayName;
        
        NSString *localPlayerID = [GKLocalPlayer localPlayer].playerID;
        for (GKTurnBasedParticipant *participant in match.participants) {
            if (![participant.playerID isEqualToString:localPlayerID]) {
                opponentPlayerId = participant.playerID;
            }
        }
        
        //GKPlayer *opponent = [APP_DELEGATE.playerCache playerWithID:opponentPlayerId];
        //GKPlayer *currentPlayer = (GKPlayer*)[players objectForKey:match.currentParticipant.playerID];
//        if (!opponent) {
//            opponentDisplayName = @"Waiting for Match";
//        } else {
//            opponentDisplayName = opponent.displayName;
//        }
        
        BOOL isCurrentParticipant = [match.currentParticipant.playerID isEqualToString:localPlayerID];
        if (isCurrentParticipant) {
            matchNode.matchStatus = @"Your Turn";
        } else {
            matchNode.matchStatus = @"Waiting For Turn";
        }
        
        [self.spriteForScrollingGeometry addChild:matchNode];
        
        SKLabelNode *matchStatusLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        [matchStatusLabel setText:matchNode.matchStatus];
        [matchStatusLabel setFontSize:14.0];
        [matchStatusLabel setFontColor:[SKColor darkGrayColor]];
        [matchStatusLabel setPosition:(CGPoint){.x = 20.0, .y = 20.0}];
        [matchStatusLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
        [matchNode addChild:matchStatusLabel];
        
        SKLabelNode *opponentLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        [opponentLabel setText:opponentDisplayName];
        [opponentLabel setFontSize:12.0];
        [opponentLabel setFontColor:[SKColor darkGrayColor]];
        [opponentLabel setPosition:(CGPoint){.x = 20.0, .y = 60.0}];
        [opponentLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
        [matchNode addChild:opponentLabel];
        
        matchNumber++;
    }
}

- (void)didMoveToView:(SKView *)view {
    //[GameKitTurnBasedMatchHelper sharedInstance].tbDelegate = self;
    
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    } else {
        //[[GameKitTurnBasedMatchHelper sharedInstance] loadMatches];
    }
}

- (void)createContent {
    self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self addNewGameButton];
}

- (void) addNewGameButton
{
    SKSpriteNode *newGameButton = [[SKSpriteNode alloc] initWithImageNamed:@"new_game_button1"];
    newGameButton.anchorPoint = CGPointMake(0.0, 0.0);
    newGameButton.size = CGSizeMake(80, 80);
    newGameButton.position = CGPointMake(10, self.contentSize.height - newGameButton.size.height - 10);
    //newGameButton.position = CGPointMake(10, 0);
    
    [self.spriteForScrollingGeometry addChild:newGameButton];
    
    SKLabelNode *newGameLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    [newGameLabel setText:@"New Game"];
    [newGameLabel setFontSize:40.0];
    [newGameLabel setFontColor:[SKColor darkGrayColor]];
    [newGameLabel setPosition:CGPointMake(100, 20)];
    [newGameLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [newGameButton addChild:newGameLabel];
    
//	KKButtonBehavior* buttonBehavior = [KKButtonBehavior behavior];
//	buttonBehavior.selectedScale = 1.2;
//	[newGameButton addBehavior:buttonBehavior];
//	[self observeNotification:KKButtonDidExecuteNotification selector:@selector(newGameButtonDidExecute:) object:newGameButton];
	//[[OALSimpleAudio sharedInstance] preloadEffect:@"die.wav"];
}

-(void) newGameButtonDidExecute:(NSNotification*)notification
{
	//[[OALSimpleAudio sharedInstance] playEffect:@"die.wav"];
    
    //[Flurry logEvent:@"StartGame_Button_Press"];
    
    [[GameKitTurnBasedMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 showExistingMatches:YES];
    
    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:1];
    
    //GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
    //scene.scaleMode = SKSceneScaleModeAspectFill;
    //[scene setTokenLayout];
    //[self.kkView presentScene:scene transition:reveal];
}

//- (void)didFetchMatches:(NSArray*)matches
//{
//    NSLog(@"%@", matches);
//    //[self loadMatches];
//    //[self.menuCollection reloadData];
//    UIViewController *VC = (UIViewController *)self.kkView.
//}

-(void)didChangeSize:(CGSize)oldSize
{
    CGSize size = [self size];
    
    CGPoint lowerLeft = (CGPoint){0, -size.height};
    
    [self.spriteForStaticGeometry setSize:size];
    [self.spriteForStaticGeometry setPosition:lowerLeft];
    
    [self.spriteToHostHorizontalAndVerticalScrolling setSize:size];
    [self.spriteToHostHorizontalAndVerticalScrolling setPosition:lowerLeft];
}

-(void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(contentSize, _contentSize))
    {
        _contentSize = contentSize;
        [self.spriteToScroll setSize:contentSize];
        [self.spriteForScrollingGeometry setSize:contentSize];
        //[self.spriteForScrollingGeometry setPosition:(CGPoint){0, -contentSize.height}];
    }
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    _contentOffset = contentOffset;
    contentOffset.x *= -1;
    [self.spriteToScroll setPosition:contentOffset];
    
    CGPoint scrollingLowerLeft = [self.spriteForScrollingGeometry convertPoint:(CGPoint){0,0} toNode:self.spriteToHostHorizontalAndVerticalScrolling];
    
    CGPoint verticalScrollingPosition = [self.spriteForVerticalScrolling position];
    verticalScrollingPosition.x = scrollingLowerLeft.x;
    [self.spriteForVerticalScrolling setPosition:verticalScrollingPosition];
}


@end
