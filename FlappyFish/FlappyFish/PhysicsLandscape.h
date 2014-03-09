//
//  PhysicsLandscape.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhysicsLandscape, PhysicsObject;

@protocol PhysicsLandscapeDelegate <NSObject>

@optional
-(void) landscapeDidBeginUpdatingForPhysicsLandscape:(PhysicsLandscape *)_landscape;
-(void) landscapeDidEndUpdatingForPhysicsLandscape:(PhysicsLandscape *)_landscape;
-(void) collisionDidOccurWithPhysicsLandscape: (PhysicsLandscape *) _landscape andObjects:(NSMutableArray *)_objects;
-(void) landscapeWillUpdateForPhysicsLandscape:(PhysicsLandscape *)_landscape;
-(void) landscapeDidUpdateForPhysicsLandscape:(PhysicsLandscape *)_landscape;
-(void) landscapeWillUpdateObject:(PhysicsObject *)objet forLandscape:(PhysicsLandscape *)_landscape;
-(void) landscapeDidUpdateObject:(PhysicsObject *)objet forLandscape:(PhysicsLandscape *)_landscape;

@end

@interface PhysicsLandscape : NSObject

@property (nonatomic, weak) id <PhysicsLandscapeDelegate> physicsLandscapeDelegate;

@property (nonatomic, strong) NSMutableArray *physicObjects;
@property (nonatomic, strong) UIView *view;
@property float updateInterval;
@property BOOL isUpdating;
@property (nonatomic, strong) NSTimer *loopTimer;

-(void)checkForCollisions;
-(void)setShouldUpdate:(BOOL)shouldUpdate;
-(id)initWithFrame:(CGRect)frame andPhysicsObjects:(NSMutableArray *)physicsObjects andUpdateInterval:(float)updateInterval;
@end
