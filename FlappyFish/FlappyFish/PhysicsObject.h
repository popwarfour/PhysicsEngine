//
//  PhysicsObject.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "PhysicsForce.h"
#import "PhysicsVector.h"
#import "PhysicsObjectPosition.h"

@class PhysicsLandscape;

@interface PhysicsObject : UIView

@property PhysicsVector *velocity;
@property PhysicsLandscape *landscape;
@property (nonatomic, strong) NSMutableArray *forces;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) NSString *objectTag;
@property (nonatomic, strong) PhysicsObjectPosition *currentPhysicsPosition;
@property (nonatomic, strong) PhysicsObjectPosition *updatedPhysicsPosition;
@property BOOL doesAnimateChanges;

//Constructor
- (id)initWithFrame:(CGRect)frame initialForces:(id)initialForces andImage:(UIImage *)image withImageFrame:(CGRect)imageFrame andDoesAnimateChanges:(BOOL)animateChanges andLandscape:(PhysicsLandscape *)landscape;

//Physics Engine Methods
-(void)updatePosition:(float)frequency;
-(void)renderNewPosition:(float)interval;

//Utility Methods
-(void)printObjectInformation;

@end
