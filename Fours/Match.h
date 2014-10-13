//
//  Match.h
//  Fours
//
//  Created by Halko, Jaayden on 6/13/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>

@interface Match : SKSpriteNode

@property (nonatomic, strong) NSString *matchStatus;
@property (nonatomic, strong) NSString *matchId;
@property (nonatomic, strong) NSData *matchData;
@property (nonatomic, strong) GKTurnBasedMatch *match;

@end
