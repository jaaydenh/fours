//
//  GameKitHelper.m
//  Fours
//
//  Created by Halko, Jaayden on 5/6/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GameKitHelper.h"
#import "AppDelegate.h"

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";

@implementation GameKitHelper

BOOL _enableGameCenter;
BOOL _matchStarted;

#pragma mark Singleton stuff

+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
        _enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if (localPlayer.isAuthenticated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
        NSLog(@"Local Player is Authenticated: %hhd", localPlayer.isAuthenticated);
        return;
    }
    
    localPlayer.authenticateHandler  = ^(UIViewController *viewController, NSError *error) {

        [self setLastError:error];
        
        if(viewController != nil) {
            [self showAuthenticationDialogWhenReasonable:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
            _enableGameCenter = YES;
            [self localPlayerWasAuthenticated];
            [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
            //authenticatedPlayer: is an example method name. Create your own method that is called after the local player is authenticated.
            //[self authenticatedPlayer: localPlayer];
        } else {
            _enableGameCenter = NO;
        }
    };
}

- (void)localPlayerWasAuthenticated
{
    // Implemented by subclasses.
}

- (void)loadPlayerPhoto:(GKPlayer*)player
{
    
    [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (photo != nil)
        {
            NSLog(@"Loaded photo for %@", player.alias);
            //[APP_DELEGATE.playerCache cachePhoto:photo forPlayer:player];
        }
        if (error != nil)
        {
            // Handle the error if necessary.
            NSLog(@"Error fetching player photo: %@", [error localizedDescription]);
        }
    }];
}

- (void)showAuthenticationDialogWhenReasonable:(UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController object:self];
    }
}

// The user has cancelled matchmaking
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

// A peer-to-peer match has been found, the game should start
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.match = match;
   // match. = self;
    //if (!_matchStarted && match.expectedPlayerCount == 0) {
    //    NSLog(@"Ready to start match!");
    //}
    

}

- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
        
        if ([[error domain] isEqualToString:GKErrorDomain])
        {
            if ([error code] == GKErrorNotSupported)
            {
                // Not supported
            }
            else
            {
                if ([error code] == GKErrorCancelled)
                {
                    // Login cancelled
                }
            }
        }
    }
}

#pragma mark UIViewController stuff

- (UIViewController*)getRootViewController
{
	return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)presentViewController:(UIViewController*)vc
{
	UIViewController *rootVC = [self getRootViewController];
	[rootVC presentViewController:vc animated:YES completion:nil];
}

- (void)dismissModalViewController
{
    UIViewController *rootVC = [self getRootViewController];
    [rootVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)getPlayerInfo:(NSArray*)playerList delegate:(NSObject<GameKitHelperProtocol>*)delegate
{
    
    if ([playerList count] > 0)
    {
        [GKPlayer loadPlayersForIdentifiers:playerList withCompletionHandler:^(NSArray* players, NSError* error) {
                          
            [self setLastError:error];
                          
            if ([delegate respondsToSelector:@selector(onPlayerInfoReceived:)])
            {
                [delegate onPlayerInfoReceived:players];
            }
        }];
	}
}

- (void)getPlayerInfo:(NSArray*)playerList
{
    [self getPlayerInfo:playerList delegate:self.delegate];
}

@end
