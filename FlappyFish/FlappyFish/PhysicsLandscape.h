//
//  Test.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhysicsEngineHeader.h"

@class PhysicsLandscape, PhysicsObject;

@protocol PhysicsLandscapeDelegate2 <NSObject>

@optional
-(void) landscapeWillBeginUpdatesForPhysicsLandscape:(PhysicsLandscape *)_landscape;
-(void) landscapeDidEndUpdatesForPhysicsLandscape:(PhysicsLandscape *)_landscape;
-(void) collisionDidOccurWithPhysicsLandscape: (PhysicsLandscape *) _landscape andObjects:(NSMutableArray *)_objects;
-(void) landscapeWillUpdateForPhysicsLandscape:(PhysicsLandscape *)_landscape;
-(void) landscapeDidUpdateForPhysicsLandscape:(PhysicsLandscape *)_landscape;
-(void) landscapeWillUpdateObject:(PhysicsObject *)objet forLandscape:(PhysicsLandscape *)_landscape;
-(void) landscapeDidUpdateObject:(PhysicsObject *)object forLandscape:(PhysicsLandscape *)_landscape;

@end

@interface PhysicsLandscape : UIView

@property (nonatomic, weak) id <PhysicsLandscapeDelegate2> physicsLandscapeDelegate;

//Updating
@property float updateInterval;
@property BOOL isUpdating;

//Objects
@property (nonatomic, strong) NSMutableArray *physicObjects;

//Cache For Objects
@property (nonatomic, strong) NSMutableArray *objectsToRemove;
@property (nonatomic, strong) NSMutableArray *objectsToAdd;

//Display Link
@property (nonatomic, strong) CADisplayLink *mainDisplayLink;
@property (nonatomic, strong) NSDate *lastUpdate;
@property float lag;

//Frame Rate Label
@property (nonatomic, strong) UILabel *frameRate;
@property (nonatomic, strong) NSDate *oldFrameRateDate;
@property BOOL displayFrameRate;

@property BOOL renderOffScreen;

- (IBAction)upButtonPressed:(id)sender;
-(void)setShouldShowFrameRate:(BOOL)showFrameRate;
-(void)setShouldUpdate:(BOOL)shouldUpdate;
- (id)initWithFrame:(CGRect)frame andPhysicsObjects:(NSMutableArray *)physicsObjects andUpdateInterval:(float)updateInteral;
-(void)addNewPhysicsObject:(PhysicsObject *)object;
-(void)addNewPhysicsObjects:(NSArray *)objects;
-(void)removePhysicsObject:(PhysicsObject *)object;
-(void)removePhysicsObjects:(NSArray *)objects;
-(void)updatePhysicsObjectFromAddAndRemoveCache;

@end
