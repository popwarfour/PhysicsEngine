//
//  Force.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhysicsVector.h"

@interface Force : NSObject

@property PhysicsVector *velocity;
@property PhysicsVector *acceleration;

@property int maxStepsToApply;
@property int currentStep;

@property BOOL isVelocity;

@property BOOL added;

@property (nonatomic, strong) NSString *tag;

-(id)initWithInitialVector:(PhysicsVector *)initialVector andIsVelocity:(BOOL)isVelocity andMaxSteps:(int)maxSteps andTag:(NSString *)tag;

@end
