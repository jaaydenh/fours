//
//  Utility.h
//  Fours
//
//  Created by Halko, Jaayden on 4/27/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PieceType) {
	Empty,
	Player1,
	Player2,
    Tie
};

typedef NS_ENUM(NSUInteger, Direction) {
    Up,
    Down,
    Left,
    Right
};

typedef NS_ENUM(NSUInteger, TokenType) {
    None,
    Sticky,
    UpArrow,
    DownArrow,
    LeftArrow,
    RightArrow,
    Blocker
};

#pragma mark - Custom Type Definitions

#define kPieceSize  30
#define kTapAreaWidth 40
#define kBoardRows 8
#define kBoardColumns 8
#define kWinnerLabelName @"winnerLabel"
#define kColumnSize 30
#define kRowSize    30
#define kGridXOffset 40.0
#define kGridYOffset 150.0
#define kGamePieceName @"gamepiece"
#define kTokenName @"token"

@interface Utility : NSObject

@end
