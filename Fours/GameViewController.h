//
//  GameViewController.h
//  Fours
//

//  Copyright (c) 2014 Party Troll. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "HomeScene.h"

@interface GameViewController : UIViewController

@property(nonatomic, weak)UIView *clearContentView;
@property(nonatomic, strong)HomeScene *homeScene;
@property(nonatomic, strong) NSArray *matches;

@end
