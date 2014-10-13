//
//  HomeScene.h
//  Fours
//
//  Created by Halko, Jaayden on 6/5/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameKitTurnBasedMatchHelper.h"

@interface HomeScene : SKScene

@property (nonatomic) CGSize contentSize;
@property(nonatomic) CGPoint contentOffset;
@property (nonatomic, weak) SKSpriteNode *spriteForScrollingGeometry;

- (void)displayMatchList:(NSArray*)matches;

@end
