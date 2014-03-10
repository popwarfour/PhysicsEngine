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
#import "Force.h"
#import "PhysicsVector.h"
#import "PhysicsObjectPosition.h"

@interface PhysicsObject : UIView

@property PhysicsVector *velocity;
@property (nonatomic, strong) NSMutableArray *forces;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) NSString *objectTag;
@property (nonatomic, strong) PhysicsObjectPosition *physicsPosition;

- (id)initWithFrame:(CGRect)frame initialForces:(NSMutableArray *)initialForces andImage:(NSString *)image;
-(void)updatePositionWithInterval:(float)interval;

@end
