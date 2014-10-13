//
//  GridPosition.h
//  Fours
//
//  Created by Halko, Jaayden on 4/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@interface GridPosition : NSObject

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) Direction direction;

- (id)initWithRow:(NSInteger)row andColumn:(NSInteger)column;

@end
