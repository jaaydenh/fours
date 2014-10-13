//
//  GameBoard.h
//  Fours
//
//  Created by Halko, Jaayden on 4/27/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GamePiece.h"
#import "Utility.h"

@interface GameBoard : SKSpriteNode
{
    GamePiece *board[8][8];
    int tokens[8][8];
}
@property int currentPlayer;
@property GamePiece *lastPiece;
@property NSMutableArray *layouts;
@property int currentLayout;
@property int lastLayout;

- (id)initWithImageNamed:(NSString *)name;
- (void)loadLayouts;
- (NSArray *)getLayout;

@end
