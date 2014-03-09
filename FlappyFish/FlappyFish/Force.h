//
//  Force.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Force : NSObject

@property CGSize velocity;
@property CGSize acceleration;

@property int maxStepsToApply;
@property int currentStep;

@property BOOL isVelocity;

@property BOOL added;

@property (nonatomic, strong) NSString *tag;

-(id)initWithInitialVector:(CGSize)initialVector andIsVelocity:(BOOL)isVelocity andMaxSteps:(int)maxSteps andTag:(NSString *)tag;

@end
