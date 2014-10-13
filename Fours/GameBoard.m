//
//  GameBoard.m
//  Fours
//
//  Created by Halko, Jaayden on 4/27/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GameBoard.h"

@implementation GameBoard

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {
        self.layouts = [[NSMutableArray alloc] init];
        self.currentLayout = 1;

    }
    return self;
}

- (void)addGamePieceAt:(CGPoint)location andDestinationRow:(NSInteger)row andDestinationColumn:(NSInteger)column
{
    //SKSpriteNode *piece = [SKSpriteNode spriteNodeWithImageNamed:@"gamepiece3"];
    NSString *gamePieceImage;
    if (self.currentPlayer == Player1) {
        gamePieceImage = @"gamepiece4";
    } else {
        gamePieceImage = @"gamepiece6";
    }
    GamePiece *piece = [[GamePiece alloc] initWithImageNamed:gamePieceImage];
    
    piece.position = location;
    piece.name = kGamePieceName;
    //piece.row = row;
    //piece.column = column;
    self.lastPiece = piece;
    [self addChild:piece];
}

- (void)loadLayouts {
    
    NSNumber *n = @(None);
    NSNumber *s = @(Sticky);
    NSNumber *u = @(UpArrow);
    NSNumber *d = @(DownArrow);
    NSNumber *l = @(LeftArrow);
    NSNumber *r = @(RightArrow);
    NSNumber *b = @(Blocker);
    
    NSArray *layout1 = @[n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,s,n,
                         n,n,n,n,n,s,n,n,
                         n,n,n,n,s,n,n,n,
                         n,n,n,s,n,n,n,n,
                         n,n,s,n,n,n,n,n,
                         n,s,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n];
    
    [self.layouts addObject:layout1];
    
    NSArray *layout2 = @[n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,s,n,n,
                         n,n,n,s,n,n,n,n,
                         n,n,n,n,s,n,n,n,
                         n,n,s,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n];
    
    [self.layouts addObject:layout2];
    
    NSArray *layout3 = @[n,n,n,n,n,n,n,n,
                         n,n,r,n,n,n,n,n,
                         n,n,s,n,n,s,d,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,u,s,n,n,s,n,n,
                         n,n,n,n,n,l,n,n,
                         n,n,n,n,n,n,n,n];
    
    [self.layouts addObject:layout3];
    
    NSArray *layout4 = @[n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,r,n,n,s,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,s,n,n,u,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n];
    
    [self.layouts addObject:layout4];
    
    NSArray *layout5 = @[n,n,n,d,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,r,s,n,n,n,
                         n,n,n,b,u,n,n,l,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n];
    
    [self.layouts addObject:layout5];
    
    NSArray *layout6 = @[n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,l,b,n,n,n,
                         n,n,n,b,r,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n];
    
    [self.layouts addObject:layout6];
    
    NSArray *layout7 = @[s,n,n,n,n,n,n,s,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         s,n,n,n,n,n,n,s];
    
    [self.layouts addObject:layout7];
    
    NSArray *layout8 = @[n,n,n,n,n,n,n,n,
                         n,n,s,n,n,n,n,n,
                         n,n,n,n,n,n,s,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,s,n,n,n,n,n,n,
                         n,n,n,n,n,s,n,n,
                         n,n,n,n,n,n,n,n];
    
    [self.layouts addObject:layout8];
    
    NSArray *layout9 = @[b,n,n,n,n,n,n,b,
                         n,s,n,n,n,n,s,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,s,n,n,n,n,s,n,
                         b,n,n,n,n,n,n,b];
    
    [self.layouts addObject:layout9];
    
    NSArray *layout10 = @[n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,d,n,n,n,n,
                         n,n,n,n,n,l,n,n,
                         n,n,r,n,n,n,n,n,
                         n,n,n,n,u,n,n,n,
                         n,n,n,n,n,n,n,n,
                         n,n,n,n,n,n,n,n];
    
    [self.layouts addObject:layout10];
    
    NSArray *layout11 = @[b,n,n,n,n,n,n,b,
                          n,n,n,n,l,n,n,n,
                          n,n,n,d,n,n,n,n,
                          n,d,n,n,n,l,n,n,
                          n,n,r,n,n,n,u,n,
                          n,n,n,n,u,n,n,n,
                          n,n,n,l,n,n,n,n,
                          b,n,n,n,n,n,n,b];
    
    [self.layouts addObject:layout11];
    
    NSArray *layout12 = @[b,n,n,n,n,n,n,b,
                          n,s,n,n,n,n,n,n,
                          n,n,n,n,n,s,n,n,
                          n,n,n,s,n,n,n,n,
                          n,n,n,n,s,n,n,n,
                          n,n,s,n,n,n,n,n,
                          n,n,n,n,n,n,s,n,
                          b,n,n,n,n,n,n,b];
    
    [self.layouts addObject:layout12];
    
    NSArray *layout13 = @[b,n,n,n,n,n,n,b,
                          n,n,n,n,n,n,n,n,
                          n,n,s,n,n,s,n,n,
                          n,n,n,n,n,n,n,n,
                          n,n,n,n,n,n,n,n,
                          n,n,s,n,n,s,n,n,
                          n,n,n,n,n,n,n,n,
                          b,n,n,n,n,n,n,b];
    
    [self.layouts addObject:layout13];
    
    NSArray *layout14 = @[n,n,n,d,n,n,n,n,
                          n,n,n,n,n,n,n,n,
                          n,n,n,n,n,n,n,n,
                          n,n,n,n,s,n,n,l,
                          r,n,n,s,n,n,n,n,
                          n,n,n,n,n,n,n,n,
                          n,n,n,n,n,n,n,n,
                          n,n,n,n,u,n,n,n];
    
    [self.layouts addObject:layout14];
}

- (NSArray *)getLayout {
    self.currentLayout++;
    if (self.currentLayout > self.layouts.count - 1) {
        self.currentLayout = 0;
    }

    return self.layouts[self.currentLayout];
}

@end
