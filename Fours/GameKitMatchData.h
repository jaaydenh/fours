//
//  GameKitMatchData.h
//  Fours
//
//  Created by Halko, Jaayden on 5/26/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "GridPosition.h"

@interface GameKitMatchData : NSObject

@property (nonatomic, strong) NSArray *tokenLayout;
@property (nonatomic, strong) NSArray *moves;
@property NSArray *currentMove;

- (id)initWithData:(NSData*)matchData;
- (NSData*)encodeMatchData;

@end
