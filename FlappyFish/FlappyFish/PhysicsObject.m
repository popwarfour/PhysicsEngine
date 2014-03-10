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
        
        self.physicsPosition = [[PhysicsObjectPosition alloc] initWithX:self.layer.position.x andY:self.layer.position.y];
    }
    return self;
}

-(void)updateVelocity
{
    float currentVelocityHeight = self.velocity.height;
    float currentVelocityWidth = self.velocity.width;
    
    float currentAccelerationHeight = 0;
    float currentAccelerationWidth = 0;
    
    NSMutableArray *forcesToRemove = [[NSMutableArray alloc] init];
    for(Force *force in self.forces)
    {
        if(force.isVelocity)
        {
            //Velocity Sum
            float tempVelocityWidth = force.velocity.width;
            float tempVelocityHeight = force.velocity.height;
            
            if(force.added == FALSE || force.maxStepsToApply >= force.currentStep)
            {
                currentVelocityHeight += tempVelocityHeight;
                currentVelocityWidth += tempVelocityWidth;
                
                force.added = TRUE;
            }
            else
            {
                [forcesToRemove addObject:force];
            }
        }
        else
        {
            //Acceleration Sum
            float tempAccelerationWidth = force.acceleration.width;
            float tempAccelerationHeight = force.acceleration.height;
            
            if(force.maxStepsToApply == -1 || force.maxStepsToApply >= force.currentStep)
            {
                currentAccelerationHeight += tempAccelerationHeight;
                currentAccelerationWidth += tempAccelerationWidth;
                
                force.added = TRUE;
            }
            else
            {
                [forcesToRemove addObject:force];
            }
        }
        
        force.currentStep++;
    }
    
    self.velocity = [[PhysicsVector alloc] initWithWidth:currentVelocityWidth + currentAccelerationWidth andHeight:currentVelocityHeight + currentAccelerationHeight];
    for(Force *removeForce in forcesToRemove)
    {
        [self.forces removeObject:removeForce];
    }

    PhysicsVector *currentVelocity = self.velocity;
    float height = currentVelocity.height;
    float width = currentVelocity.width;
    
    self.velocity = [[PhysicsVector alloc] initWithWidth:width andHeight:height];
}

-(void)updatePositionWithInterval:(float)interval
{
    [self updateVelocity];
    
    if([self.objectTag isEqualToString:@"snowflaik"])
        NSLog(@"NUM FORCES: %d", self.forces.count);
    
    PhysicsObjectPosition *currentPosition = self.physicsPosition;
    PhysicsObjectPosition *newPosition = [[PhysicsObjectPosition alloc] initWithX:currentPosition.x + self.velocity.width andY:currentPosition.y + self.velocity.height];
    
    CGPoint roundedCurrentPosition = CGPointMake(abs(currentPosition.x), abs(currentPosition.y));
    CGPoint roundedNewPosition = CGPointMake(abs(newPosition.x), abs(newPosition.y));
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setFromValue:[NSValue valueWithCGPoint:roundedCurrentPosition]];
    [animation setToValue:[NSValue valueWithCGPoint:roundedNewPosition]];
    self.layer.position = roundedNewPosition;
    self.physicsPosition = newPosition;
    animation.duration = interval;
    animation.removedOnCompletion = FALSE;
    
    [self.layer addAnimation:animation forKey:nil];

}

-(void)printRect:(CGRect)rect
{
    NSLog(@"X: %.0f - Y: %.0f - W: %.0f - H: %.0f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    NSLog(@"-------------------------------");
}

@end
