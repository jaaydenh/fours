//
//  GameKitHelper.h
//  Fours
//
//  Created by Halko, Jaayden on 5/6/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@import GameKit;

extern NSString *const LocalPlayerIsAuthenticated;

@protocol GameKitHelperProtocol<NSObject>
@optional
-(void) onScoresSubmitted:(bool)success;
-(void) onScoresOfFriendsToChallengeListReceived:(NSArray*)scores;
-(void) onPlayerInfoReceived:(NSArray*)players;
@end

extern NSString *const PresentAuthenticationViewController;

@interface GameKitHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate>

@property (nonatomic, assign) id<GameKitHelperProtocol> delegate;
@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;
@property (nonatomic, strong) GKTurnBasedMatch *match;

+ (instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;
- (void)getPlayerInfo:(NSArray*)playerList;
- (void)getPlayerInfo:(NSArray*)playerList delegate:(NSObject<GameKitHelperProtocol>*)delegate;
- (void)presentViewController:(UIViewController*)vc;
- (void)dismissModalViewController;
- (void)localPlayerWasAuthenticated;
- (void)loadPlayerPhoto:(GKPlayer*)player;

@end
