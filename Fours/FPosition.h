//
//  M2Position.h
//  Fours
//
//  Created by Halko, Jaayden on 9/1/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#ifndef Fours_M2Position_h
#define Fours_M2Position_h

typedef struct Position {
    NSInteger row;
    NSInteger col;
} FPosition;

CG_INLINE FPosition FPositionMake(NSInteger row, NSInteger col)
{
    FPosition position;
    position.row = row; position.col = col;
    return position;
}

#endif
