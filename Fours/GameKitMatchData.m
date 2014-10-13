//
//  GameKitMatchData.m
//  Fours
//
//  Created by Halko, Jaayden on 5/26/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GameKitMatchData.h"

@implementation GameKitMatchData

- (id)initWithData:(NSData*)matchData {
    if (self = [super init]) {
        NSArray *combinedDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:matchData];
        if ([combinedDataArray count] >= (kBoardRows * kBoardColumns)) {
            self.tokenLayout = [[NSArray alloc] init];
            self.moves = [[NSArray alloc] init];
            
            NSRange tokenLayoutRange;
            tokenLayoutRange.location = 0;
            tokenLayoutRange.length = kBoardRows * kBoardColumns;
            self.tokenLayout = [combinedDataArray subarrayWithRange:tokenLayoutRange];
            
            NSRange movesRange;
            movesRange.location = kBoardRows * kBoardColumns;
            movesRange.length = [combinedDataArray count] - (kBoardRows * kBoardColumns);
            self.moves = [combinedDataArray subarrayWithRange:movesRange];
        } else {
            //TODO: throw error here
            NSLog(@"Match data is corrupt when initializing matchdata");
        }
    }
    return self;
}

- (NSData*)encodeMatchData {
    NSArray *combinedDataArray = [self.tokenLayout arrayByAddingObjectsFromArray:self.moves];
    NSArray *finalDataArray;
    if ([self.currentMove count] > 0) {
        finalDataArray = [combinedDataArray arrayByAddingObjectsFromArray:self.currentMove];
    }
    
    NSData *matchData = [NSKeyedArchiver archivedDataWithRootObject:finalDataArray];
    
    return matchData;
}

@end
