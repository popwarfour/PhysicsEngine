//
//  PhysicsObject.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "PhysicsObject.h"
#import "PhysicsLandscape.h"

@implementation PhysicsObject

- (id)initWithFrame:(CGRect)frame initialForces:(id)initialForces andImage:(UIImage *)image withImageFrame:(CGRect)imageFrame andDoesAnimateChanges:(BOOL)animateChanges andLandscape:(PhysicsLandscape *)landscape
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
        
        self.landscape = landscape;
        
        self.currentPhysicsPosition = [[PhysicsObjectPosition alloc] initWithX:self.layer.position.x andY:self.layer.position.y];
        
        self.doesAnimateChanges = animateChanges;
    }
    return self;
}

#pragma mark - Physics Engine
#pragma mark Calculate New Velocity
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

#pragma mark Update Position

-(void)updatePosition:(float)frequency
{
    if(self.doesAnimateChanges)
        [self.layer removeAllAnimations];
    
    [self updateVelocity];
    
    if(self.currentPhysicsPosition == nil)
    {
        self.currentPhysicsPosition = [[PhysicsObjectPosition alloc] initWithX:self.frame.origin.x + (self.frame.size.width / 2) andY:self.frame.origin.y + (self.frame.size.height / 2)];
    }
    
    PhysicsObjectPosition *currentPosition = self.currentPhysicsPosition;
    PhysicsObjectPosition *newPosition = [[PhysicsObjectPosition alloc] initWithX:currentPosition.x + (frequency * self.velocity.width) andY:currentPosition.y + (frequency * self.velocity.height)];
    self.updatedPhysicsPosition = newPosition;
}

#pragma mark Render New Position

-(BOOL)shouldRenderWithNewPosition:(PhysicsObjectPosition *)newPosition
{
    PhysicsObjectPosition *currentPosition = self.currentPhysicsPosition;
    
    BOOL newPositionOutside = FALSE;
    BOOL oldPositionOutside = FALSE;
    
    if((newPosition.x + (self.frame.size.width / 2)) < 0 || newPosition.y + (self.frame.size.height / 2) < 0 || newPosition.y - (self.frame.size.height / 2) > self.landscape.frame.size.height || newPosition.x - (self.frame.size.width / 2) > self.landscape.frame.size.width)
    {
        newPositionOutside = TRUE;
    }
    if((currentPosition.x + (self.frame.size.width / 2)) < 0 || currentPosition.y + (self.frame.size.height / 2) < 0 || currentPosition.y - (self.frame.size.height / 2) > self.landscape.frame.size.height || currentPosition.x - (self.frame.size.width / 2) > self.landscape.frame.size.width)
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

-(void)renderNewPosition:(float)interval
{
    //Render & Update Position Only If We're On The Screen!
    if([self shouldRenderWithNewPosition:self.updatedPhysicsPosition])
    {
        //Render & Update We're On the Screen!
        CGPoint roundedNewPosition;
        if(self.updatedPhysicsPosition != nil)
        {
            roundedNewPosition = [self.updatedPhysicsPosition roundValueToCGPoint];
        }
        else
        {
            roundedNewPosition = [self.currentPhysicsPosition roundValueToCGPoint];
        }
        
        if(self.doesAnimateChanges)
        {
            //Smooth Animate Changes
            CGPoint roundedCurrentPosition = [self.currentPhysicsPosition roundValueToCGPoint];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setFromValue:[NSValue valueWithCGPoint:roundedCurrentPosition]];
            [animation setToValue:[NSValue valueWithCGPoint:roundedNewPosition]];
            self.layer.position = roundedNewPosition;
            if(self.updatedPhysicsPosition != nil)
                self.currentPhysicsPosition = self.updatedPhysicsPosition;
            animation.duration = interval;
            animation.removedOnCompletion = FALSE;
            [self.layer addAnimation:animation forKey:nil];
        }
        else
        {
            //Hard Update Changes
            self.layer.position = roundedNewPosition;
            if(self.updatedPhysicsPosition != nil)
                self.currentPhysicsPosition = self.updatedPhysicsPosition;
        }
    }
}

#pragma mark - Utility Methods
#pragma mark Print Information
-(void)printRect:(CGRect)rect
{
    NSLog(@"X: %.0f - Y: %.0f - W: %.0f - H: %.0f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}
-(void)printObjectInformation
{
    NSLog(@"Object-Tag: %@ | Tag: %d", self.objectTag, self.tag);
    NSLog(@"Frame| X: %.0f - Y: %.0f - W: %.0f - H: %.0f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    NSLog(@"Layer Frame| X: %.0f - Y: %.0f - W: %.0f - H: %.0f", self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.width, self.layer.frame.size.height);
    NSLog(@"Cur-Position| X: %f - Y: %f", self.currentPhysicsPosition.x, self.currentPhysicsPosition.y);
}

@end
