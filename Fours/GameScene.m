/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "GameScene.h"
#import "GamePiece.h"
#import "GridPosition.h"
#import "GameBoard.h"
#import "Utility.h"
//#import "Flurry.h"
#import "GameKitMatchData.h"
#import "FPosition.h"

#pragma mark - Private GameScene Properties

@interface GameScene ()
{
    //GamePiece *gameBoard[8][8];
    //int boardTokens[8][8];
}

@property NSMutableArray *grid;
@property NSMutableArray *tokens;

@property BOOL contentCreated;
@property SKSpriteNode *tapAreaLeft;
@property SKSpriteNode *tapAreaRight;
@property SKSpriteNode *tapAreaTop;
@property SKSpriteNode *tapAreaBottom;
@property SKSpriteNode *highlight;
@property int currentPlayer;
@property int boardColumns;
@property int boardRows;
@property (strong) NSMutableArray *winningPositions;
@property GamePiece *lastPiece;
@property GamePiece *currentPiece;
@property NSMutableArray *currentPieces;
@property GameBoard *board;
@property (nonatomic, strong) NSMutableArray *sortedMatches;
@property GameKitMatchData *gameData;
@property BOOL isMultiplayer;
@property (nonatomic, readwrite) NSInteger dimension;

@end

@implementation GameScene

// Gameboard is constructed by replaying the list of moves contained in gameData


-(void)didMoveToView:(SKView *)view
{
    [GameKitTurnBasedMatchHelper sharedInstance].gameSceneDelegate = self;

    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

-(void)createContent
{
    self.isMultiplayer = NO;
    self.currentPieces = [[NSMutableArray alloc] init];
    self.boardRows = kBoardRows;
    self.boardColumns = kBoardColumns;
    self.dimension = kBoardRows;
    self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.gameData = [[GameKitMatchData alloc] init];
    self.currentPlayer = Player1;
    
    [self setupTapAreas];
    [self setupBoard];
    
    SKLabelNode *winnerLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial Bold"];
    winnerLabel.fontSize = 26;
    winnerLabel.fontColor = [UIColor blackColor];
    winnerLabel.position = CGPointMake(self.frame.size.width/2 , 480);
    winnerLabel.zPosition = 1.0;
    winnerLabel.hidden = YES;
    winnerLabel.name = kWinnerLabelName;
    [self addChild:winnerLabel];

    [self addBackButton];
    [self addMenuButton];
    [self loadSounds];
}

-(void)loadSounds {
//    [[OALSimpleAudio sharedInstance] preloadEffect:@"arrow1.mp3"];
//    [[OALSimpleAudio sharedInstance] preloadEffect:@"lose1.mp3"];
//    [[OALSimpleAudio sharedInstance] preloadEffect:@"sticky1.mp3"];
//    [[OALSimpleAudio sharedInstance] preloadEffect:@"win1.mp3"];
//    [[OALSimpleAudio sharedInstance] preloadEffect:@"menu.mp3"];
}

-(void)setupBoard
{
    self.board = [[GameBoard alloc] initWithImageNamed:@"grid8"];

    
    self.board.anchorPoint = CGPointMake(0.0, 0.0);
    self.board.position = CGPointMake(kGridXOffset, kGridYOffset);
    [self addChild:self.board];
    
    [self.board loadLayouts];
    [self setupBoardCorners];
    [self initWithDimension:self.boardRows];
    [self resetBoardTokens];
    [self initTokensWithDimention:self.boardRows];
}

- (void)setTokenLayout {
    //if (self.gameData.tokenLayout == nil) {
        [self.gameData setTokenLayout:[self.board getLayout]];
    //}
}

- (void)initTokensWithDimention:(NSInteger)dimension {
    self.tokens = [[NSMutableArray alloc] initWithCapacity:dimension];
    NSArray *tokenLayout = [self.gameData tokenLayout];
    
    NSInteger layoutPos = 0;
    
    for (NSInteger row = dimension - 1; row >= 0; row--) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:dimension];
        for (NSInteger col = 0; col < dimension; col++) {
            
            [array addObject:[NSNumber numberWithInteger:[tokenLayout[layoutPos] integerValue]]];
			//boardTokens[row][col] = [tokenLayout[layoutPos] intValue];
            if ([tokenLayout[layoutPos] intValue] != None) {
                [self addTokenAt:row andColumn:col andType:[tokenLayout[layoutPos] intValue]];
            }
            
            layoutPos++;
		}
        [self.tokens insertObject:array atIndex:0];
	}
}

-(void)initWithDimension:(NSInteger)dimension {
    self.grid = [[NSMutableArray alloc] initWithCapacity:dimension];
    
    for (NSInteger i = 0; i < dimension; i++) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:dimension];
        for (NSInteger j = 0; j < dimension; j++) {
            //[array addObject:[[M2Cell alloc] initWithPosition:M2PositionMake(i, j)]];
            GamePiece *piece = [[GamePiece alloc] init];
            piece.player = Empty;
            [array addObject:piece];
        }
        [self.grid addObject:array];
    }
}

-(void)setupTapAreas
{
    SKAction *fadeOut = [SKAction fadeAlphaTo:.4 duration:.1];
    //SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:.8];
    //SKAction *pulse = [SKAction sequence:@[fadeOut,fadeIn]];
    //SKAction *pulseForever = [SKAction repeatActionForever:pulse];
    
    self.tapAreaLeft = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area" ];
    self.tapAreaLeft.size = CGSizeMake(kTapAreaWidth, kRowSize * self.boardRows);
    self.tapAreaLeft.anchorPoint = CGPointMake(0.0, 0.0);
    self.tapAreaLeft.position = CGPointMake(0.0, 150.0);
    self.tapAreaLeft.name = @"tapAreaLeft";
    [self addChild:self.tapAreaLeft];
    [self.tapAreaLeft runAction:fadeOut];
    
    self.tapAreaRight = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area" ];
    self.tapAreaRight.size = CGSizeMake(kTapAreaWidth, kRowSize * self.boardRows);
    self.tapAreaRight.anchorPoint = CGPointMake(0.0, 0.0);
    self.tapAreaRight.position = CGPointMake(280.0, 150.0);
    self.tapAreaRight.name = @"tapAreaRight";
    [self addChild:self.tapAreaRight];
    [self.tapAreaRight runAction:fadeOut];
    
    self.tapAreaTop = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area" ];
    self.tapAreaTop.size = CGSizeMake(kColumnSize * self.boardColumns, kTapAreaWidth);
    self.tapAreaTop.anchorPoint = CGPointMake(0.0, 0.0);
    self.tapAreaTop.position = CGPointMake(40.0, 390.0);
    self.tapAreaTop.name = @"tapAreaTop";
    [self addChild:self.tapAreaTop];
    [self.tapAreaTop runAction:fadeOut];
    
    self.tapAreaBottom = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area" ];
    self.tapAreaBottom.size = CGSizeMake(kColumnSize * self.boardColumns, kTapAreaWidth);
    self.tapAreaBottom.anchorPoint = CGPointMake(0.0, 0.0);
    self.tapAreaBottom.position = CGPointMake(40.0, 110.0);
    self.tapAreaBottom.name = @"tapAreaBottom";
    [self addChild:self.tapAreaBottom];
    [self.tapAreaBottom runAction:fadeOut];
}

- (void)setupBoardCorners {
    SKSpriteNode *corner1 = [SKSpriteNode spriteNodeWithImageNamed:@"board_corner" ];
    corner1.size = CGSizeMake(kTapAreaWidth, kTapAreaWidth);
    corner1.anchorPoint = CGPointMake(0.0, 0.0);
    corner1.position = CGPointMake(0.0, kGridYOffset + (kBoardRows * kRowSize));
    corner1.alpha = 0.5;
    [self addChild:corner1];
    
    SKSpriteNode *corner2 = [SKSpriteNode spriteNodeWithImageNamed:@"board_corner" ];
    corner2.size = CGSizeMake(kTapAreaWidth, kTapAreaWidth);
    corner2.anchorPoint = CGPointMake(0.0, 0.0);
    corner2.position = CGPointMake(kGridXOffset + (kBoardColumns * kColumnSize), kGridYOffset + (kBoardRows * kRowSize));
    corner2.alpha = 0.5;
    [self addChild:corner2];
    
    SKSpriteNode *corner3 = [SKSpriteNode spriteNodeWithImageNamed:@"board_corner" ];
    corner3.size = CGSizeMake(kTapAreaWidth, kTapAreaWidth);
    corner3.anchorPoint = CGPointMake(0.0, 0.0);
    corner3.position = CGPointMake(kGridXOffset + (kBoardColumns * kColumnSize), kGridYOffset - kTapAreaWidth);
    corner3.alpha = 0.5;
    [self addChild:corner3];
    
    SKSpriteNode *corner4 = [SKSpriteNode spriteNodeWithImageNamed:@"board_corner" ];
    corner4.size = CGSizeMake(kTapAreaWidth, kTapAreaWidth);
    corner4.anchorPoint = CGPointMake(0.0, 0.0);
    corner4.position = CGPointMake(0.0, kGridYOffset - kTapAreaWidth);
    corner4.alpha = 0.5;
    [self addChild:corner4];
}

-(GamePiece *)gamePieceAtPosition:(FPosition)position {
    if (position.row >= self.dimension || position.col >= self.dimension ||
        position.row < 0 || position.col < 0) return nil;
    return [[self.grid objectAtIndex:position.row] objectAtIndex:position.col];
}

-(NSNumber *)tokenAtPosition:(FPosition)position {
    if (position.row >= self.dimension || position.col >= self.dimension ||
        position.row < 0 || position.col < 0) return nil;
    return [[self.tokens objectAtIndex:position.row] objectAtIndex:position.col];
}

-(void)printBoard {
    NSLog(@" ");
    NSString *rowString = @"";
    for (int row = self.boardRows-1; row >= 0; row--) {
		for (int col = 0; col < self.boardColumns; col++) {
            if ([self gamePieceAtPosition:FPositionMake(row, col)].player == Player1) {
                rowString = [rowString stringByAppendingString:@"1 "];
            } else if ([self gamePieceAtPosition:FPositionMake(row, col)].player == Player2) {
                rowString = [rowString stringByAppendingString:@"2 "];
            } else {
                rowString = [rowString stringByAppendingString:@"0 "];
            }
		}
        NSLog(@"%@", rowString);
        rowString = @"";
	}
}

-(void)resetBoardTokens {
    for (int col = 0; col < self.boardColumns; col++) {
		for (int row = 0; row < self.boardRows; row++) {
			[[self.tokens objectAtIndex:row] setObject:[NSNumber numberWithInteger:None] atIndex:col];
            //boardTokens[col][row] = None;
		}
	}
}

-(void)resetGame {
	[self enumerateChildNodesWithName:kGamePieceName usingBlock:^(SKNode* node, BOOL* stop) {
        [node removeFromParent];
	}];
    
    [self enumerateChildNodesWithName:kTokenName usingBlock:^(SKNode* node, BOOL* stop) {
        [node removeFromParent];
	}];
    
    [self initWithDimension:self.boardRows];
    [self resetBoardTokens];
    [self initTokensWithDimention:self.boardRows];
    SKLabelNode *winner = (SKLabelNode*)[self childNodeWithName:kWinnerLabelName];
    winner.hidden = YES;
    
    self.currentPlayer = Player1;
}

-(void) addMenuButton
{
    SKSpriteNode *menuButton = [[SKSpriteNode alloc] initWithImageNamed:@"menu_button"];
    menuButton.anchorPoint = CGPointMake(0.0, 0.0);
    menuButton.position = CGPointMake(self.frame.size.width - menuButton.frame.size.width, self.frame.size.height - menuButton.frame.size.height);
	[self addChild:menuButton];
	
	//KKButtonBehavior* buttonBehavior = [KKButtonBehavior behavior];
	//buttonBehavior.selectedScale = 1.2;
	//[menuButton addBehavior:buttonBehavior];
	
	//[self observeNotification:KKButtonDidExecuteNotification selector:@selector(menuButtonDidExecute:) object:menuButton];
}

-(void) menuButtonDidExecute:(NSNotification*)notification
{
    //[self setTokenLayout];
    //[[OALSimpleAudio sharedInstance] playEffect:@"menu.mp3"];
    //[Flurry logEvent:@"Menu_Button_Press"];
    //[self resetGame];
    //[self layoutMatch:self.currentMatch];
    //[[GameKitTurnBasedMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 showExistingMatches:YES];
}

-(void) addBackButton
{
    SKSpriteNode *backButton = [[SKSpriteNode alloc] initWithImageNamed:@"left_arrow_token"];
    backButton.anchorPoint = CGPointMake(0.0, 0.0);
    backButton.position = CGPointMake(0, self.frame.size.height - backButton.frame.size.height);
	[self addChild:backButton];

//	KKButtonBehavior* buttonBehavior = [KKButtonBehavior behavior];
//	buttonBehavior.selectedScale = 1.2;
//	[backButton addBehavior:buttonBehavior];
//	
//	[self observeNotification:KKButtonDidExecuteNotification selector:@selector(backButtonDidExecute:) object:backButton];
}

-(void) backButtonDidExecute:(NSNotification*)notification
{
	//[[OALSimpleAudio sharedInstance] playEffect:@"menu.wav"];
    //[Flurry logEvent:@"Back_Button_Press"];
    SKTransition *slide = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:1];
    
    //FIXME: transition
    //[self.view popSceneWithTransition:slide];

    [[GameKitTurnBasedMatchHelper sharedInstance] loadMatches];
}

-(void)addTokenAt:(NSInteger)row andColumn:(NSInteger)column andType:(TokenType)tokenType {
    CGFloat x = column * kColumnSize + kGridXOffset;
    CGFloat y = row * kRowSize +  kGridYOffset;
    NSString *gamePieceImage = @"magnet";
    
    if (tokenType == Sticky) {
        gamePieceImage = @"sticky_token";
    } else if (tokenType == UpArrow) {
        gamePieceImage = @"up_arrow_token";
    } else if (tokenType == DownArrow) {
        gamePieceImage = @"down_arrow_token";
    } else if (tokenType == LeftArrow) {
        gamePieceImage = @"left_arrow_token";
    } else if (tokenType == RightArrow) {
        gamePieceImage = @"right_arrow_token";
    } else if (tokenType == Blocker) {
        gamePieceImage = @"blocker_token";
    } 

    GamePiece *piece = [[GamePiece alloc] initWithImageNamed:gamePieceImage];
    piece.position = CGPointMake(x, y);
    piece.size = CGSizeMake(30.0, 30.0);
    piece.position = CGPointMake(piece.position.x, piece.position.y);
    piece.name = kGamePieceName;
    [self addChild:piece];
}

- (void)removeHighlights {
    for (SKNode *node in self.children) {
        if ([node.name  isEqual: @"highlight"]) {
            [node removeFromParent];
        }
    }
}

- (void)addGamePieceHighlightFrom:(Direction)direction {

    [self removeHighlights];
    
    for (GamePiece *piece in self.currentPieces) {
        
        NSInteger startColumn = floor((piece.position.x - kGridXOffset) / kColumnSize);
        NSInteger startRow = floor((piece.position.y - kGridYOffset) / kRowSize);
        
        if (startRow  < 0) {
            startRow = 0;
        }
        
        if (startColumn < 0) {
            startColumn = 0;
        }
        
        for (GridPosition *position in [piece.moveDestinations reverseObjectEnumerator]) {
            SKSpriteNode *highlight = [SKSpriteNode spriteNodeWithImageNamed:@"highlight"];
            highlight.alpha = 0.2;
            if (piece.player == Player1) {
                highlight.color = [UIColor orangeColor];
                highlight.colorBlendFactor = 0.9;
            } else if (piece.player == Player2) {
                highlight.color = [UIColor blueColor];
                highlight.colorBlendFactor = 0.5;
            }

            highlight.anchorPoint = CGPointMake(0.0, 0.0);
            highlight.name = @"highlight";
            
            if (position.direction == Down) {
                highlight.size = CGSizeMake(kColumnSize, (startRow - position.row) * kRowSize);
                highlight.position = CGPointMake(position.column * kColumnSize + kGridXOffset, kGridYOffset + (position.row * kRowSize));
            } else if (position.direction == Up) {
                highlight.size = CGSizeMake(kColumnSize, (position.row - startRow + 1) * kRowSize);
                highlight.position = CGPointMake(position.column * kColumnSize + kGridXOffset, (startRow * kRowSize) + kGridYOffset);
            } else if (position.direction == Right) {
                highlight.size = CGSizeMake((position.column - startColumn + 1) * kColumnSize, kRowSize);
                highlight.position = CGPointMake((startColumn * kColumnSize) + kGridXOffset, position.row * kRowSize + kGridYOffset);
            } else if (position.direction == Left) {
                highlight.size = CGSizeMake((startColumn - position.column) * kColumnSize, kRowSize);
                highlight.position = CGPointMake(kGridXOffset + (position.column * kColumnSize), position.row * kRowSize + kGridYOffset);
            }

            startRow = position.row;
            startColumn = position.column;
            
            [self addChild:highlight];
        }
    }
}

- (void)endGameWithWinner:(PieceType)pieceType {
    SKLabelNode *winnerLabel = (SKLabelNode*)[self childNodeWithName:kWinnerLabelName];
    NSString *winner = @"";
    
    if (pieceType == Player1) {
        winner = @"Player 1";
        winnerLabel.text =  [NSString stringWithFormat:@"%@", @"Player 1 Wins!"];
        winnerLabel.hidden = NO;
    } else if (pieceType == Player2) {
        winner = @"Player 2";
        winnerLabel.text = [NSString stringWithFormat:@"%@", @"Player 2 Wins!"];
        winnerLabel.hidden = NO;
    } else if (pieceType == Tie) {
        winner = @"Tie";
        winnerLabel.text = [NSString stringWithFormat:@"%@", @"Tie!"];
        winnerLabel.hidden = NO;
    }
    
    NSDictionary *winParams = @{@"Winner": winner};
    //[[OALSimpleAudio sharedInstance] playEffect:@"win1.mp3"];
    //[Flurry logEvent:@"Game_Over" withParameters:winParams];
}

-(void)makeMoveFromRow:(NSInteger)row andColumn:(NSInteger)column andDirection:(Direction)direction andPieceType:(PieceType)pieceType {
    [self executeMoveFromRow:row andColumn:column andDirection:direction andPieceType:pieceType];
    for (GamePiece *currentPiece in self.currentPieces) {
        GridPosition *position = currentPiece.moveDestinations[0];
        [[self.grid objectAtIndex:position.row] setObject:currentPiece atIndex:position.column];

        //gameBoard[position.row][position.column] = currentPiece;
        //    return [[self.grid objectAtIndex:position.row] objectAtIndex:position.col];
    }
    [self.currentPieces removeAllObjects];
}

-(void)renderGameBoard {
    for (int row = self.boardRows-1; row >= 0; row--) {
		for (int column = 0; column < self.boardColumns; column++) {
            if ([self gamePieceAtPosition:FPositionMake(row, column)].player != Empty) {
                GamePiece *gamePiece = [self gamePieceAtPosition:FPositionMake(row, column)];
                //GamePiece *gamePiece = gameBoard[row][column];
                CGPoint location = CGPointMake(column * kColumnSize + kGridXOffset, row * kRowSize +  kGridYOffset);
                gamePiece.position = location;
                [self addChild:gamePiece];
            }
		}
	}
}

#if TARGET_OS_IPHONE // iOS
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.currentPiece hasActions]) {
        return;
    }
    
	NSArray *touchesArray = [touches allObjects];
    CGPoint touchLocation = [touchesArray[0] locationInNode:self];
    NSMutableArray *winners = [[NSMutableArray alloc] init];
    PieceType winner = Empty;
    
    if ([self.currentPieces count] > 0) {
        GamePiece *curPiece = self.currentPieces[0];
        CGRect touchRect;
        if (curPiece.direction == Up || curPiece.direction == Down) {
            touchRect = CGRectMake(curPiece.position.x - 8, curPiece.position.y - 50, 46.0, 130.0);
        } else {
            touchRect = CGRectMake(curPiece.position.x - 50, curPiece.position.y - 8, 130.0, 46.0);
        }
        
        if (CGRectContainsPoint(touchRect, touchLocation)) {
            //[[OALSimpleAudio sharedInstance] playEffect:@"sticky1.mp3"];
            
            for (GamePiece *piece in self.currentPieces) {
                [piece generateActions];
            }
            
            GamePiece *piece = self.currentPieces[0];
            [self.currentPieces removeObjectAtIndex:0];
            self.currentPiece = piece;
            
            SKAction *sequence = [SKAction sequence:piece.actions];
            [piece removeAllActions];
            [piece setSize:CGSizeMake(kPieceSize, kPieceSize)];
            
            [piece runAction:sequence completion:^(void) {}];
            
            // update gameboard model with destination of gamepiece
            GridPosition *desinationPosition = piece.moveDestinations[0];
            [[self.grid objectAtIndex:desinationPosition.row] setObject:piece atIndex:desinationPosition.column];
            //gameBoard[desinationPosition.row][desinationPosition.column] = piece;

            if (self.currentPlayer == Player1) {
                self.currentPlayer = Player2;
            } else {
                self.currentPlayer = Player1;
            }
            
            [self removeHighlights];
            
            winner = [self checkForWinnerAtRow:desinationPosition.row andColumn:desinationPosition.column];
            if (winner != Empty) {
                [winners addObject:[NSNumber numberWithInt:winner]];
            }
            
            for (GamePiece *currentPiece in self.currentPieces) {
                GridPosition *position = currentPiece.moveDestinations[0];
                [[self.grid objectAtIndex:position.row] setObject:currentPiece atIndex:position.column];
                //gameBoard[position.row][position.column] = currentPiece;
                
                winner = [self checkForWinnerAtRow:position.row andColumn:position.column];
                if (winner != Empty) {
                    [winners addObject:[NSNumber numberWithInt:winner]];
                }
            }
            
            [self printBoard];
            
            if (winners.count > 0) {
                int player1Wins = 0;
                int player2Wins = 0;
                for (NSNumber *pieceType in winners) {
                    if ([pieceType  isEqual: @(Player1)]) {
                        player1Wins++;
                    } else if ([pieceType  isEqual: @(Player2)]) {
                        player2Wins++;
                    }
                }
                if (player1Wins > 0 && player2Wins > 0) {
                    [self endGameWithWinner:Tie];
                } else if (player1Wins > 0) {
                    [self endGameWithWinner:Player1];
                } else if (player2Wins > 0) {
                    [self endGameWithWinner:Player2];
                }
            }
            
            //TODO: Tie if no more possible moves
            if (self.isMultiplayer) {
                [self advanceTurn];
            }
        } else {
            [self calculateMoveFromLocation:touchLocation];
        }
    } else {
        [self calculateMoveFromLocation:touchLocation];
    }

	// (optional) call super implementation to allow KKScene to dispatch touch events
	[super touchesBegan:touches withEvent:event];
}
#else // Mac OS X
-(void) mouseDown:(NSEvent *)event
{
	CGPoint location = [event locationInNode:self];
	[self addSpaceshipAt:location];
    
	// (optional) call super implementation to allow KKScene to dispatch mouse events
	[super mouseDown:event];
}
#endif

- (void)calculateMoveFromLocation:(CGPoint)touchLocation {
    Direction direction = -1;
    int startingRow = -1;
    int startingColumn = -1;
    int column = floor((touchLocation.x - kGridXOffset) / kColumnSize);
    int row = floor((touchLocation.y - kGridYOffset) / kRowSize);
    
    if ([self.currentPieces count] > 0) {
        [self.currentPieces[0] removeFromParent];
    }
    
    [self removeHighlights];
    [self.currentPieces removeAllObjects];
    
    if ([self.tapAreaTop containsPoint:touchLocation]) {
        startingRow = self.boardRows-1;
        startingColumn = column;
        direction = Down;
    } else if ([self.tapAreaBottom containsPoint:touchLocation]) {
        startingRow = 0;
        startingColumn = column;
        direction = Up;
    } else if ([self.tapAreaRight containsPoint:touchLocation]) {
        startingRow = row;
        startingColumn = self.boardColumns-1;
        direction = Left;
    } else if ([self.tapAreaLeft containsPoint:touchLocation]) {
        startingRow = row;
        startingColumn = 0;
        direction = Right;
    } else {
        return;
    }
    
    [self calculateMoveFromRow:startingRow andColumn:startingColumn andDirection:direction];
}

- (void)calculateMoveFromRow:(int)row andColumn:(int)column andDirection:(Direction)direction {
    CGPoint location = CGPointMake(0.0, 0.0);
    
    if (direction == Up) {
        location = CGPointMake(column * kColumnSize + kGridXOffset, kGridYOffset - kRowSize - 5);
    } else if (direction == Down) {
        location = CGPointMake(column * kColumnSize + kGridXOffset, kGridYOffset + kRowSize * self.boardRows + 5);
    } else if (direction == Left) {
        location = CGPointMake(self.boardColumns * kColumnSize + kGridXOffset + 5, row * kRowSize +  kGridYOffset);
    } else if (direction == Right) {
        location = CGPointMake(5, row * kRowSize + kGridYOffset);
    }
    
    //if (gameBoard[row][column] != nil || boardTokens[row][column] == Blocker) {
    if ([self gamePieceAtPosition:FPositionMake(row, column)].player != Empty) {
        //validMove = NO;
    } else {
        NSString *gamePieceImage;
        if (self.currentPlayer == Player1) {
            gamePieceImage = @"gamepiece4";
        } else {
            gamePieceImage = @"gamepiece6";
        }
        
        self.gameData.currentMove = @[@(row),@(column),[NSNumber numberWithInt:direction]];
        
        GamePiece *gamePiece = [[GamePiece alloc] initWithImageNamed:gamePieceImage];
        gamePiece.position = location;
        gamePiece.name = kGamePieceName;
        gamePiece.player = self.currentPlayer;
        gamePiece.direction = direction;
        [self.currentPieces addObject:gamePiece];
        //gamePiece.anchorPoint = CGPointMake(0.5, 0.5);
        NSMutableArray *pulseActions = [[NSMutableArray alloc] init];
        NSMutableArray *moveActions = [[NSMutableArray alloc] init];
        SKAction *growAction = [SKAction resizeToWidth:kPieceSize + 10 height:kPieceSize + 10 duration:0.5];
        SKAction *growMove = [SKAction moveByX:-5 y:-5 duration:0.5];
        SKAction *shrinkAction = [SKAction resizeToWidth:kPieceSize height:kPieceSize duration:0.5];
        SKAction *skrinkMove = [SKAction moveByX:5 y:5 duration:0.5];

        [pulseActions addObject:growAction];
        [moveActions addObject:growMove];
        [pulseActions addObject:shrinkAction];
        [moveActions addObject:skrinkMove];
        SKAction *sequence1 = [SKAction sequence:pulseActions];
        SKAction *sequence2 = [SKAction sequence:moveActions];
        SKAction *pulse = [SKAction repeatActionForever:sequence1];
        SKAction *move = [SKAction repeatActionForever:sequence2];
        [gamePiece runAction:pulse];
        [gamePiece runAction:move];
        
        [self getDestinationForDirection:direction withGamePiece:gamePiece andStartingRow:row andStartingColumn:column];
        
        [self addChild:gamePiece];
        
        [self addGamePieceHighlightFrom:direction];
    }
}

- (void)executeMoveFromRow:(NSInteger)row andColumn:(NSInteger)column andDirection:(Direction)direction andPieceType:(PieceType)pieceType {
    //CGPoint location = CGPointMake(0.0, 0.0);
    
    //if (gameBoard[row][column] != nil || boardTokens[row][column] == Blocker) {
        //validMove = NO;
    //} else {
        NSString *gamePieceImage;
        if (pieceType == Player1) {
            gamePieceImage = @"gamepiece4";
        } else {
            gamePieceImage = @"gamepiece6";
        }
        
        GamePiece *gamePiece = [[GamePiece alloc] initWithImageNamed:gamePieceImage];
        //gamePiece.position = CGPointMake(0, 0);
        gamePiece.name = kGamePieceName;
        gamePiece.player = pieceType;
        gamePiece.direction = direction;
        [self.currentPieces addObject:gamePiece];
        
        [self getDestinationForDirection:direction withGamePiece:gamePiece andStartingRow:row andStartingColumn:column];
    //}
}

// assumption: only call this method with a valid row and column that is within the bounds of the board and does not contain a piece
- (void)getDestinationForDirection:(Direction)direction withGamePiece:(GamePiece*)gamePiece andStartingRow:(NSInteger)startingRow andStartingColumn:(NSInteger)startingColumn {
    GridPosition *position = [[GridPosition alloc] init];

    switch (direction) {
        case Down:
            position.row = 0;
            position.column = startingColumn;
            position.direction = Down;
            
            for (NSInteger row = startingRow; row >= 0;row--) {
                if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == Sticky) {
                    if ([self gamePieceAtPosition:FPositionMake(row, startingColumn)].player != Empty) {
                    //if (gameBoard[row][startingColumn] != nil) {
                        // If the piece in the sticky square can move
                        if (row - 1 >= 0 && [self gamePieceAtPosition:FPositionMake(row - 1, startingColumn)].player == Empty){
                        //if (row - 1 >= 0 && gameBoard[row-1][startingColumn] == nil){
                            GamePiece *stuckPiece = [self gamePieceAtPosition:FPositionMake(row, startingColumn)];
                            //GamePiece *stuckPiece = gameBoard[row][startingColumn];
                            [stuckPiece resetMovement];
                            [self getDestinationForDirection:Down withGamePiece:stuckPiece andStartingRow:row - 1 andStartingColumn:startingColumn];
                            [self.currentPieces addObject:stuckPiece];
                            
                            position.row = row;
                            break;
                        } else {
                            // piece in sticky square cannot move
                            position.row = row + 1;
                            break;
                        }
                    } else {
                        position.row = row;
                        break;
                    }
                } else if ([self gamePieceAtPosition:FPositionMake(row, startingColumn)].player != Empty) {
                    position.row = row + 1;
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == UpArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Up withGamePiece:gamePiece andStartingRow:row + 1 andStartingColumn:startingColumn];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == DownArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Down withGamePiece:gamePiece andStartingRow:row - 1 andStartingColumn:startingColumn];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == LeftArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Left withGamePiece:gamePiece andStartingRow:row andStartingColumn:startingColumn - 1];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == RightArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Right withGamePiece:gamePiece andStartingRow:row andStartingColumn:startingColumn + 1];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == Blocker) {
                    position.row = row + 1;
                    break;
                }
                
                position.row = row;
            }
            break;
        
        case Up:
            position.row = self.boardRows-1;
            position.column = startingColumn;
            position.direction = Up;
            
            for (NSInteger row = startingRow; row <= self.boardRows-1;row++) {
                if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == Sticky) {
                    if ([self gamePieceAtPosition:FPositionMake(row, startingColumn)].player != Empty) {
                        // If the piece in the sticky square can move
                        if (row + 1 < kBoardRows && [self gamePieceAtPosition:FPositionMake(row + 1, startingColumn)].player == Empty){
                            GamePiece *stuckPiece = [self gamePieceAtPosition:FPositionMake(row, startingColumn)];
                            [stuckPiece resetMovement];
                            [self getDestinationForDirection:Up withGamePiece:stuckPiece andStartingRow:row + 1 andStartingColumn:startingColumn];
                            [self.currentPieces addObject:stuckPiece];
                            
                            position.row = row;
                            break;
                        } else {
                            // piece in sticky square cannot move
                            position.row = row - 1;
                            break;
                        }
                    } else {
                        position.row = row;
                        break;
                    }
                } else if ([self gamePieceAtPosition:FPositionMake(row, startingColumn)].player != Empty) {
                    position.row = row - 1;
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == UpArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Up withGamePiece:gamePiece andStartingRow:row + 1 andStartingColumn:startingColumn];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == DownArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Down withGamePiece:gamePiece andStartingRow:row - 1 andStartingColumn:startingColumn];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == LeftArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Left withGamePiece:gamePiece andStartingRow:row andStartingColumn:startingColumn - 1];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == RightArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Right withGamePiece:gamePiece andStartingRow:row andStartingColumn:startingColumn + 1];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(row, startingColumn)] integerValue] == Blocker) {
                    position.row = row - 1;
                    break;
                }
                
                position.row = row;
            }
            break;
            
        case Left:
            position.column = 0;
            position.row = startingRow;
            position.direction = Left;
            
            for (NSInteger column = startingColumn; column >= 0;column--) {
                if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == Sticky) {
                    if ([self gamePieceAtPosition:FPositionMake(startingRow, column)].player != Empty) {
                        // If the piece in the sticky square can move
                        if (column - 1 >= 0 && [self gamePieceAtPosition:FPositionMake(startingRow, column - 1)].player == Empty){
                            GamePiece *stuckPiece = [self gamePieceAtPosition:FPositionMake(startingRow, column)];
                            [stuckPiece resetMovement];
                            [self getDestinationForDirection:Left withGamePiece:stuckPiece andStartingRow:startingRow andStartingColumn:column - 1];
                            [self.currentPieces addObject:stuckPiece];
                            
                            position.column = column;
                            break;
                        } else {
                            // piece in sticky square cannot move
                            position.column = column + 1;
                            break;
                        }
                    } else {
                        position.column = column;
                        break;
                    }
                } else if ([self gamePieceAtPosition:FPositionMake(startingRow, column)].player != Empty) {
                    position.column = column + 1;
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == UpArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Up withGamePiece:gamePiece andStartingRow:startingRow + 1 andStartingColumn:column];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == DownArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Down withGamePiece:gamePiece andStartingRow:startingRow - 1 andStartingColumn:column];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == LeftArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Left withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:column - 1];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == RightArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Right withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:column + 1];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == Blocker) {
                    position.column = column + 1;
                    break;
                }
                
                position.column = column;
            }
            break;
            
        case Right:
            position.column = self.boardColumns-1;
            position.row = startingRow;
            position.direction = Right;
            
            for (NSInteger column = startingColumn; column <= self.boardColumns-1;column++) {
                if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == Sticky) {
                    if ([self gamePieceAtPosition:FPositionMake(startingRow, column)].player != Empty) {
                        // If the piece in the sticky square can move
                        if (column + 1 < kBoardColumns && [self gamePieceAtPosition:FPositionMake(startingRow, column + 1)].player == Empty){
                            GamePiece *stuckPiece = [self gamePieceAtPosition:FPositionMake(startingRow, column)];
                            [stuckPiece resetMovement];
                            [self getDestinationForDirection:Right withGamePiece:stuckPiece andStartingRow:startingRow andStartingColumn:column + 1];
                            [self.currentPieces addObject:stuckPiece];
                            
                            position.column = column;
                            break;
                        } else {
                            // piece in sticky square cannot move
                            position.column = column - 1;
                            break;
                        }
                    } else {
                        position.column = column;
                        break;
                    }
                } else if ([self gamePieceAtPosition:FPositionMake(startingRow, column)].player != Empty) {
                    position.column = column - 1;
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == UpArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Up withGamePiece:gamePiece andStartingRow:startingRow + 1 andStartingColumn:column];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == DownArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Down withGamePiece:gamePiece andStartingRow:startingRow - 1 andStartingColumn:column];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == LeftArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Left withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:column - 1];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == RightArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Right withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:column + 1];
                    break;
                } else if ([[self tokenAtPosition:FPositionMake(startingRow, column)] integerValue] == Blocker) {
                    position.column = column - 1;
                    break;
                }
                
                position.column = column;
            }
            break;
        default:
            break;
    }
    
    [gamePiece.moveDestinations addObject:position];
}

- (void)update:(CFTimeInterval)currentTime
{
	/* Called before each frame is rendered */
	if ([self.currentPiece hasActions]) {
        CGRect destinationRect = CGRectMake(self.currentPiece.moveDestination.x, self.currentPiece.moveDestination.y, kPieceSize, kPieceSize);
        if (CGRectIntersectsRect(destinationRect, self.currentPiece.frame)) {
            if (self.currentPieces.count > 0) {
                self.currentPiece = self.currentPieces[self.currentPieces.count-1];
                [self.currentPieces removeObjectAtIndex:self.currentPieces.count-1];
                SKAction *sequence = [SKAction sequence:self.currentPiece.actions];
                [self.currentPiece runAction:sequence];
            }
        }
    }
	// (optional) call super implementation to allow KKScene to dispatch update events
	[super update:currentTime];
}

- (PieceType)checkForWinnerAtRow:(NSInteger)row andColumn:(NSInteger)column {
    PieceType winner = Empty;
    self.winningPositions = [[NSMutableArray alloc] init];
    NSString *winMethod = @"";
    
    winner = [self checkForWinnerInRow:row];
    if (winner != Empty) {
        winMethod = @"row";
    }
    if (winner == Empty) {
        winner = [self checkForWinnerInColumn:column];
        if (winner != Empty) {
            winMethod = @"column";
        }
    }
    if (winner == Empty) {
        winner = [self checkDiagonalForWinnerAtRow:row andColumn:column];
        if (winner != Empty) {
            winMethod = @"diagonal";
        }
    }
    
    return winner;
}

-(NSInteger)updateWinCounterWithRow:(NSInteger)row andColumn:(NSInteger)column andPlayer:(PieceType)player andWinCounter:(NSInteger)winCounter {
    if ([self gamePieceAtPosition:FPositionMake(row, column)].player != Empty) {
        if ([self gamePieceAtPosition:FPositionMake(row, column)].player == player) {
            winCounter++;
        } else {
            winCounter = 0;
        }
    } else {
        winCounter = 0;
    }
    
    return winCounter;
}

-(NSInteger)checkForWinnerInRow:(NSInteger)row {
    PieceType currentPiece;
    NSInteger winCounter = 0;
    
    for (NSInteger column = 0; column < self.boardRows; column++) {
        if (column > 0 && [self gamePieceAtPosition:FPositionMake(row, column)].player != [self gamePieceAtPosition:FPositionMake(row, column - 1)].player) {
            winCounter = 0;
            [self.winningPositions removeAllObjects];
        }
        currentPiece = [self gamePieceAtPosition:FPositionMake(row, column)].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            [self.winningPositions removeAllObjects];
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    return 0;
}

-(NSInteger)checkForWinnerInColumn:(NSInteger)column {
    PieceType currentPiece;
    NSInteger winCounter = 0;
    
    for (NSInteger row = 0; row < self.boardRows; row++) {
        if (row > 0 && [self gamePieceAtPosition:FPositionMake(row, column)].player != [self gamePieceAtPosition:FPositionMake(row - 1, column)].player) {
            winCounter = 0;
            [self.winningPositions removeAllObjects];
        }
        currentPiece = [self gamePieceAtPosition:FPositionMake(row, column)].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            [self.winningPositions removeAllObjects];
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    return 0;
}

-(NSInteger)checkDiagonalForWinnerAtRow:(NSInteger)currentRow andColumn:(NSInteger)currentColumn {
    PieceType currentPiece;
    NSInteger winCounter = 0;
    NSInteger startingRow = 0;
    NSInteger startingColumn = 0;
    NSInteger row, column;
    
    for (row = currentRow, column = currentColumn; row >= 0 && column >= 0;row--,column--) {
        startingRow = row;
        startingColumn = column;
    }
    
    for (row = startingRow, column = startingColumn; row < self.boardRows && column < self.boardColumns; row++,column++) {
        if (row > startingRow && column > startingColumn && [self gamePieceAtPosition:FPositionMake(row, column)].player != [self gamePieceAtPosition:FPositionMake(row - 1, column - 1)].player) {
            winCounter = 0;
            [self.winningPositions removeAllObjects];
        }
        currentPiece = [self gamePieceAtPosition:FPositionMake(row, column)].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            [self.winningPositions removeAllObjects];
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    winCounter = 0;
    
    for (row = currentRow, column = currentColumn; row < self.boardRows && column >= 0;row++,column--) {
        startingRow = row;
        startingColumn = column;
    }
    
    for (row = startingRow, column = startingColumn; row >= 0 && column < self.boardColumns;row--,column++) {
        if (row < startingRow && column > startingColumn && [self gamePieceAtPosition:FPositionMake(row, column)].player != [self gamePieceAtPosition:FPositionMake(row + 1, column - 1)].player) {
            winCounter = 0;
            [self.winningPositions removeAllObjects];
        }
        currentPiece = [self gamePieceAtPosition:FPositionMake(row, column)].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            [self.winningPositions removeAllObjects];
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    return 0;
}

#pragma mark - GCTurnBasedMatchHelperDelegate

-(void)enterNewGame:(GKTurnBasedMatch *)match
{
    NSLog(@"Entering new game...");
    
    [[GameKitTurnBasedMatchHelper sharedInstance] cachePlayerData];
    [GameKitTurnBasedMatchHelper sharedInstance].currentMatch = match;
    
    //    [self loadMatches];
}

-(void)layoutMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"Viewing match where it's not our turn...");
    NSString *statusString;
    [GameKitTurnBasedMatchHelper sharedInstance].currentMatch = match;
    
    self.gameData = [[GameKitMatchData alloc] initWithData:match.matchData];
    
    if (self.gameData.tokenLayout) {
        [self initTokensWithDimention:self.boardRows];
    }
    if (self.gameData.moves) {
        self.currentPlayer = Player1;
        for (int i = 0;i < self.gameData.moves.count / 3; i = i + 3) {
            Direction direction = (Direction)[(NSNumber*)self.gameData.moves[i * 3 + 2] intValue];
            NSNumber *row = self.gameData.moves[i * 3];
            NSNumber *col = self.gameData.moves[i * 3 + 1];
            
            [self makeMoveFromRow:[row integerValue] andColumn:[col integerValue] andDirection:direction
                     andPieceType:self.currentPlayer];
            if (self.currentPlayer == Player1) {
                self.currentPlayer = Player2;
            } else {
                self.currentPlayer = Player1;
            }
        }
        [self renderGameBoard];
    }
    
    if (match.status == GKTurnBasedMatchStatusEnded)
    {
        statusString = @"Match Ended";
    }
    else
    {
        NSInteger playerNum = [match.participants indexOfObject:match.currentParticipant] + 1;
        statusString = [NSString stringWithFormat:@"Player %ld's Turn", (long)playerNum];
    }
}

-(void)takeTurn:(GKTurnBasedMatch *)match
{
    NSLog(@"Taking turn for existing game...");
    
    NSInteger playerNum = [match.participants indexOfObject:match.currentParticipant] + 1;
    NSString *statusString = [NSString stringWithFormat:@"Player %ld's Turn (that's you)", (long)playerNum];
    NSLog(@"takeTurn: %@", statusString);
    
    [[GameKitTurnBasedMatchHelper sharedInstance] cachePlayerData];
    [GameKitTurnBasedMatchHelper sharedInstance].currentMatch = match;
    
}

-(void)receiveEndGame:(GKTurnBasedMatch *)match
{
    [self layoutMatch:match];
}

-(void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:
                       @"Another game needs your attention!"
                                                 message:notice
                                                delegate:self
                                       cancelButtonTitle:@"Sweet!"
                                       otherButtonTitles:nil];
    [av show];
}

//- (void)didFetchMatches:(NSArray*)matches
//{
//    [self loadMatches];
//    //[self.menuCollection reloadData];
//    [[GameKitTurnBasedMatchHelper sharedInstance] cachePlayerData];
//}

//- (void)loadMatches
//{
//    // TODO: Sort by last move time.
//    self.sortedMatches = [NSMutableArray arrayWithArray:[[GameKitTurnBasedMatchHelper sharedInstance].matches allValues]];
//    //[self.menuCollection reloadData];
//    
//}

- (void)advanceTurn {
    GKTurnBasedMatch *currentMatch = [GameKitTurnBasedMatchHelper sharedInstance].currentMatch;
    
    NSData *updatedMatchData = [self.gameData encodeMatchData];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant = (currentMatch.participants)[((currentIndex + 1) % [currentMatch.participants count])];
    NSArray *sortedPlayerOrder = @[nextParticipant, currentMatch.currentParticipant];
    
    [currentMatch endTurnWithNextParticipants:sortedPlayerOrder turnTimeout:GKTurnTimeoutDefault matchData:updatedMatchData completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    
    NSLog(@"Send Turn, %@, %@", updatedMatchData, nextParticipant);
}

@end
