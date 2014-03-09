//
//  GravityViewController.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhysicsObject.h"
#import "PhysicsLandscape.h"

@interface GravityViewController : UIViewController <PhysicsLandscapeDelegate>
@property (nonatomic, strong) NSMutableArray *physicObjects;
@property (nonatomic, strong) PhysicsLandscape *mainLandscape;

- (IBAction)upButtonPressed:(id)sender;

@end
