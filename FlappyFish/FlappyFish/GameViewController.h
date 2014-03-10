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

- (IBAction)upButtonPressed:(id)sender;

@end
