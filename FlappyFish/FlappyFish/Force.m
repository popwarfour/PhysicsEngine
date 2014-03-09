//
//  Force.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "Force.h"

@implementation Force

-(id)initWithInitialVector:(CGSize)initialVector andIsVelocity:(BOOL)isVelocity andMaxSteps:(int)maxSteps andTag:(NSString *)tag
{
    if(self = [super init])
    {
        self.currentStep = 1;
        self.maxStepsToApply = maxSteps;
        
        self.isVelocity = isVelocity;
        
        if(self.isVelocity)
        {
            self.velocity = initialVector;
        }
        else
        {
            self.acceleration = initialVector;
        }
        
        self.added = FALSE;

        self.tag = tag;
    }
    return self;
}

@end
