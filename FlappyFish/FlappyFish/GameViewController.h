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

@property (nonatomic, strong) UILabel *gameOverLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *topScoreLabel;

@property (nonatomic, strong) NSTimer *createNewWallTimer;

@property int gameState;

@property int currentScore;
@property int topScore;
@property int extraLives;

- (IBAction)backgroundButtonPressed:(id)sender;

@end
