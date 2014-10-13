//
//  GridPosition.m
//  Fours
//
//  Created by Halko, Jaayden on 4/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GridPosition.h"

@implementation GridPosition

- (id)initWithRow:(NSInteger)row andColumn:(NSInteger)column {
    if (self = [super init]) {
        self.row = row;
        self.column = column;
    }
    return self;
}

@end
