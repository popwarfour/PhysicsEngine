//
//  GravityViewController.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhysicsEngineHeader.h"

@class PhysicsLandscapeViewController, PhysicsObject;

@protocol PhysicsLandscapeDelegate <NSObject>

@optional
-(void) landscapeDidBeginUpdatingForPhysicsLandscape:(PhysicsLandscapeViewController *)_landscape;
-(void) landscapeDidEndUpdatingForPhysicsLandscape:(PhysicsLandscapeViewController *)_landscape;
-(void) collisionDidOccurWithPhysicsLandscape: (PhysicsLandscapeViewController *) _landscape andObjects:(NSMutableArray *)_objects;
-(void) landscapeWillUpdateForPhysicsLandscape:(PhysicsLandscapeViewController *)_landscape;
-(void) landscapeDidUpdateForPhysicsLandscape:(PhysicsLandscapeViewController *)_landscape;
-(void) landscapeWillUpdateObject:(PhysicsObject *)objet forLandscape:(PhysicsLandscapeViewController *)_landscape;
-(void) landscapeDidUpdateObject:(PhysicsObject *)objet forLandscape:(PhysicsLandscapeViewController *)_landscape;

@end

@interface PhysicsLandscapeViewController : UIViewController

@property (nonatomic, weak) id <PhysicsLandscapeDelegate> physicsLandscapeDelegate;
@property float updateInterval;
@property BOOL isUpdating;
@property (nonatomic, strong) NSTimer *loopTimer;
@property (nonatomic, strong) NSMutableArray *physicObjects;

- (IBAction)upButtonPressed:(id)sender;
-(void)setShouldUpdate:(BOOL)shouldUpdate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPhysicsObjects:(NSMutableArray *)physicsObjects andUpdateInterval:(float)updateInteral;


@end
