//
//  GameViewController.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhysicsEngineHeader.h"

@interface GameViewController : UIViewController <PhysicsLandscapeDelegate2>

@property (nonatomic, strong) PhysicsLandscape *gameView;

@property (nonatomic, strong) PhysicsObject *fish;
@property (weak, nonatomic) IBOutlet UIButton *upButton;

@property (nonatomic, strong) PhysicsObject *nearestTopWall;

@property (nonatomic, strong) UILabel *gameOverLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *topScoreLabel;
@property (nonatomic, strong) UILabel *gameCountLabel;

@property (nonatomic, strong) NSTimer *createNewWallTimer;

@property (nonatomic, strong) UIButton *quitButton;

@property int gameState;

@property int currentScore;
@property int topScore;
@property int extraLives;
@property float fitness;

@property int wallGap;

-(void)startGame;
- (IBAction)backgroundButtonPressed:(id)sender;
-(NSDictionary *)getInformation;
-(void)gameOver;

@end
