//
//  PhysicsObject.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "PhysicsObject.h"

@implementation PhysicsObject

- (id)initWithFrame:(CGRect)frame initialForces:(id)initialForces andImage:(UIImage *)image withImageFrame:(CGRect)imageFrame andDoesAnimateChanges:(BOOL)animateChanges
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        if(image == nil)
        {
            [self setBackgroundColor:[UIColor redColor]];
        }
        else
        {
            //[self setBackgroundColor:[UIColor blueColor]];
            
            self.image = [[UIImageView alloc] initWithFrame:imageFrame];
            [self.image setImage:image];
        }
        
        [self addSubview:self.image];
        
        if([initialForces isKindOfClass:[NSMutableArray class]])
        {
            self.forces = initialForces;
        }
        else if([initialForces isKindOfClass:[NSArray class]])
        {
            self.forces = [[NSMutableArray alloc] initWithArray:initialForces];
        }
        else
        {
            NSAssert(FALSE, @"Invalid type of object as initial forces. Must be of type NSArray or NSMutableArray");
        }
        
        self.doesAnimateChanges = animateChanges;
        
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
    for(PhysicsForce *force in self.forces)
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
    for(PhysicsForce *removeForce in forcesToRemove)
    {
        [self.forces removeObject:removeForce];
    }

    /*
    PhysicsVector *currentVelocity = self.velocity;
    float height = currentVelocity.height;
    float width = currentVelocity.width;
    
    self.velocity = [[PhysicsVector alloc] initWithWidth:width andHeight:height];*/
}

-(void)updatePositionWithInterval:(float)interval
{
    if(self.doesAnimateChanges)
        [self.layer removeAllAnimations];
    
    [self updateVelocity];
    
    PhysicsObjectPosition *currentPosition = self.physicsPosition;
    PhysicsObjectPosition *newPosition = [[PhysicsObjectPosition alloc] initWithX:currentPosition.x + self.velocity.width andY:currentPosition.y + self.velocity.height];
    
    
    //Render & Update Position Only If We're On The Screen!
    if(TRUE)//[self shouldUpdateWithNewPosition:newPosition])
    {
        //Render & Update We're On the Screen!
        CGPoint roundedNewPosition = [newPosition roundValueToCGPoint];
        
        if(self.doesAnimateChanges)
        {
            //Smooth Animate Changes
            CGPoint roundedCurrentPosition = [currentPosition roundValueToCGPoint];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setFromValue:[NSValue valueWithCGPoint:roundedCurrentPosition]];
            [animation setToValue:[NSValue valueWithCGPoint:roundedNewPosition]];
            self.layer.position = roundedNewPosition;
            self.physicsPosition = newPosition;
            animation.duration = interval;
            animation.removedOnCompletion = FALSE;
            [self.layer addAnimation:animation forKey:nil];
        }
        else
        {
            //Hard Update Changes
            self.layer.position = roundedNewPosition;
            self.physicsPosition = newPosition;
        }
    }
    else
    {
        //Just Update its position for later
        self.physicsPosition = newPosition;
    }
}

-(BOOL)shouldUpdateWithNewPosition:(PhysicsObjectPosition *)newPosition
{
    PhysicsObjectPosition *currentPosition = self.physicsPosition;
    
    NSLog(@"Object: %@", self.objectTag);
    BOOL newPositionOutside = FALSE;
    BOOL oldPositionOutside = FALSE;
    if((newPosition.x + self.frame.size.width) < 0 || newPosition.y < 0 || newPosition.y > 568 || newPosition.x > 320)
    {
        newPositionOutside = TRUE;
    }
    if((currentPosition.x + self.frame.size.width) < 0 || currentPosition.y < 0 || currentPosition.y > 568 || currentPosition.x > 320)
    {
        oldPositionOutside = TRUE;
    }
    
    if(newPositionOutside && oldPositionOutside)
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

-(void)printRect:(CGRect)rect
{
    NSLog(@"X: %.0f - Y: %.0f - W: %.0f - H: %.0f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    NSLog(@"-------------------------------");
}

@end
