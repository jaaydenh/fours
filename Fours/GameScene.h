/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "GameKitTurnBasedMatchHelper.h"
#import "Match.h"

// IMPORTANT: in Kobold Kit all scenes must inherit from KKScene.
@interface GameScene : SKScene <GameKitTurnBasedMatchHelperDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) GKTurnBasedMatch *currentMatch;

- (void)setTokenLayout;

@end
