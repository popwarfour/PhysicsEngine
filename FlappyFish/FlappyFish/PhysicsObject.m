//
//  PhysicsObject.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "PhysicsObject.h"

@implementation PhysicsObject

- (id)initWithFrame:(CGRect)frame initialForces:(NSMutableArray *)initialForces andImage:(NSString *)image
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.image = [[UIImageView alloc] initWithFrame:frame];
        if(image == nil)
        {
            [self setBackgroundColor:[UIColor redColor]];
        }
        else
        {
            [self.image setImage:[UIImage imageNamed:image]];
        }
        [self addSubview:self.image];
        
        self.forces = [[NSMutableArray alloc] initWithArray:initialForces];
    }
    return self;
}

-(void)updateVelocity
{
    int currentVelocityHeight = self.velocity.height;
    int currentVelocityWidth = self.velocity.width;
    
    int currentAccelerationHeight = 0;
    int currentAccelerationWidth = 0;
    
    NSMutableArray *forcesToRemove = [[NSMutableArray alloc] init];
    for(Force *force in self.forces)
    {
        if(force.isVelocity)
        {
            //Velocity Sum
            force.added = TRUE;
            int tempVelocityWidth = force.velocity.width;
            int tempVelocityHeight = force.velocity.height;
            
            if(force.maxStepsToApply == -1 || force.maxStepsToApply >= force.currentStep)
            {
                currentVelocityHeight += tempVelocityHeight;
                currentVelocityWidth += tempVelocityWidth;
            }
            else
            {
                [forcesToRemove addObject:force];
            }
        }
        else
        {
            //Acceleration Sum
            force.added = TRUE;
            int tempAccelerationWidth = force.acceleration.width;
            int tempAccelerationHeight = force.acceleration.height;
            
            if(force.maxStepsToApply == -1 || force.maxStepsToApply >= force.currentStep)
            {
                currentAccelerationHeight += tempAccelerationHeight;
                currentAccelerationWidth += tempAccelerationWidth;
            }
            else
            {
                [forcesToRemove addObject:force];
            }
        }
        
        force.currentStep++;
    }
    
    self.velocity = CGSizeMake(currentVelocityWidth + currentAccelerationWidth, currentVelocityHeight + currentAccelerationHeight);
    for(Force *removeForce in forcesToRemove)
    {
        [self.forces removeObject:removeForce];
    }

    CGSize currentVelocity = self.velocity;
    int height = currentVelocity.height;
    int width = currentVelocity.width;
    
    self.velocity = CGSizeMake(width, height);
}

-(void)updatePositionWithInterval:(float)interval
{
    [self updateVelocity];

    CGPoint currentPosition = CGPointMake(self.frame.origin.x + (self.frame.size.width / 2), self.frame.origin.y/* + (self.frame.size.height / 2)*/);
    CGPoint newPosition = CGPointMake(self.frame.origin.x + self.velocity.width + (self.frame.size.width / 2), self.frame.origin.y + self.velocity.height + (self.frame.size.height / 2));
    
    NSLog(@"OLD-Y: %.0f", currentPosition.y);
    NSLog(@"NEW-Y: %.0f", newPosition.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setFromValue:[NSValue valueWithCGPoint:currentPosition]];
    [animation setToValue:[NSValue valueWithCGPoint:newPosition]];
    self.layer.position = newPosition;
    animation.duration = 2;
    animation.removedOnCompletion = FALSE;
    
    [self.layer addAnimation:animation forKey:nil];
}

@end
