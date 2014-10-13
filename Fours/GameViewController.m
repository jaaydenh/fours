//
//  GameViewController.m
//  Fours
//
//  Created by Halko, Jaayden on 10/12/14.
//  Copyright (c) 2014 Party Troll. All rights reserved.
//

#import "GameViewController.h"
#import "GameKitTurnBasedMatchHelper.h"
#import "GameScene.h"
//#import "Flurry.h"
#import "GameKitHelper.h"
#import "AppDelegate.h"
#import "Match.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

static NSString * kViewTransformChanged = @"view transform changed";

@implementation GameViewController

UIScrollView *scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentFirstScene];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController)
                                                 name:PresentAuthenticationViewController object:nil];
    
    //[[GameKitTurnBasedMatchHelper sharedInstance] authenticateLocalPlayer];
    
    [GameKitTurnBasedMatchHelper sharedInstance].viewControllerDelegate = self;
    
    self.matches = [[NSArray alloc] init];
    
    
}

- (void)didFetchMatches:(NSArray*)matches
{
    NSLog(@"%@", matches);
    self.matches = matches;
    
    CGSize contentSize = self.view.frame.size;
    contentSize.height = self.matches.count * 100 + 100;
    contentSize.width *= 1.0;
    [self.homeScene setContentSize:contentSize];
    [self addScrollView:contentSize];
    
    [[GameKitTurnBasedMatchHelper sharedInstance] cachePlayerData:self];
}

- (void)onPlayerInfoReceived:(NSArray*)players
{
    //[APP_DELEGATE.playerCache onPlayerInfoReceived:players];
    
    [self.homeScene displayMatchList:self.matches];
}

-(void)addScrollView:(CGSize)contentSize {
    
    //homeScene
    scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){.origin = CGPointMake(0.0, 110.0), .size = CGSizeMake(320, 568)}];
    [scrollView setContentSize:contentSize];
    scrollView.delegate = self;
    //scrollView.backgroundColor = [UIColor redColor];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    UIView *clearContentView = [[UIView alloc] initWithFrame:(CGRect){.origin = CGPointMake(0.0, 0.0), .size = contentSize}];
    [clearContentView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:clearContentView];
    
    _clearContentView = clearContentView;
    
    [clearContentView addObserver:self
                       forKeyPath:@"transform"
                          options:NSKeyValueObservingOptionNew
                          context:&kViewTransformChanged];
    [self.view addSubview:scrollView];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:scrollView];
    
    for (SKNode *node in self.homeScene.spriteForScrollingGeometry.children) {
        if ([node isKindOfClass:[Match class]]) {
            Match *matchNode = (Match *)node;
            
            if ([matchNode containsPoint:touchPoint]) {
                SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:1];
                [scrollView removeFromSuperview];
                GameScene *gameScene = [GameScene sceneWithSize:self.view.bounds.size];
                gameScene.scaleMode = SKSceneScaleModeAspectFill;

                [(SKView *)self.view presentScene:gameScene transition:reveal];
                [gameScene layoutMatch:matchNode.match];
                [gameScene setCurrentMatch:matchNode.match];
            }
        }
    }
}

-(void)presentFirstScene
{
    // create and present first scene
    SKTransition *reveal = [SKTransition fadeWithDuration:3];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    self.homeScene = [HomeScene sceneWithSize:self.view.bounds.size];
    
    GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
    //    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    [skView presentScene:scene transition:reveal];
}

- (void)showAuthenticationViewController
{
    [self presentViewController:[GameKitTurnBasedMatchHelper sharedInstance].authenticationViewController animated:YES completion:nil];
}

-(void)adjustContent:(UIScrollView *)scrollView
{
    CGPoint contentOffset = [scrollView contentOffset];
    [self.homeScene setContentOffset:contentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustContent:scrollView];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.clearContentView;
}

-(void)scrollViewDidTransform:(UIScrollView *)scrollView
{
    [self adjustContent:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale; // scale between minimum and maximum. called after any 'bounce' animations
{
    [self adjustContent:scrollView];
}
#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (context == &kViewTransformChanged)
    {
        [self scrollViewDidTransform:(id)[(UIView *)object superview]];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    @try {
        [self.clearContentView removeObserver:self forKeyPath:@"transform"];
    }
    @catch (NSException *exception) {    }
    @finally {    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
