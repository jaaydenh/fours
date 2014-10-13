//
//  GamePiece.m
//  Fours
//
//  Created by Halko, Jaayden on 4/12/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GamePiece.h"
#import "GridPosition.h"

@interface GamePiece() {

}

@end

@implementation GamePiece

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {
        self.anchorPoint = CGPointMake(0.0, 0.0);
        //self.isPlayed = NO;
        self.size = CGSizeMake(kPieceSize, kPieceSize);
        
        self.moveDestinations = [[NSMutableArray alloc] init];
        self.actions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)generateActions {
    CGPoint lastPosition = self.position;
    
    for (GridPosition *position in [self.moveDestinations reverseObjectEnumerator]) {
        CGPoint moveLocation = CGPointMake(position.column * kColumnSize + kGridXOffset, position.row * kRowSize + kGridYOffset);
        CGFloat distance = sqrtf((moveLocation.x - lastPosition.x)*(moveLocation.x - lastPosition.x)+
                                 (moveLocation.y - lastPosition.y)*(moveLocation.y - lastPosition.y));
        SKAction *move = [SKAction moveTo:moveLocation duration:distance/260.0];
        [self.actions addObject:move];
        lastPosition = moveLocation;
        self.moveDestination = moveLocation;
    }
}

- (void)resetMovement {
    [self.actions removeAllObjects];
    [self.moveDestinations removeAllObjects];
}

@end
