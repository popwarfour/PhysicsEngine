//
//  Test.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "PhysicsLandscape.h"
#import <UIKit/UIKit.h>

@implementation PhysicsLandscape

- (id)initWithFrame:(CGRect)frame andPhysicsObjects:(NSMutableArray *)physicsObjects andUpdateInterval:(float)updateInteral
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.physicObjects = physicsObjects;
        self.updateInterval = updateInteral;
        
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [self addInitialObjectsToView];
}

#pragma mark - Added & Removing Physics Objects
#pragma mark Clearing Cache
-(void)updatePhysicsObjectFromAddAndRemoveCache
{
    for(PhysicsObject *addMe in self.objectsToAdd)
    {
        [self.physicObjects addObject:addMe];
        [self addSubview:addMe];
    }
    for(PhysicsObject *removeMe in self.objectsToRemove)
    {
        [self.physicObjects removeObject:removeMe];
        [removeMe removeFromSuperview];
    }
}
#pragma mark Adding
-(void)addInitialObjectsToView
{
    for(PhysicsObject *object in self.physicObjects)
    {
        [self addSubview:object];
    }
}

-(void)addNewPhysicsObject:(PhysicsObject *)object
{
    [self.objectsToAdd addObject:object];
}

-(void)addNewPhysicsObjects:(NSArray *)objects
{
    for(PhysicsObject *object in objects)
    {
        NSAssert([objects isKindOfClass:[PhysicsObject class]], @"Cannot add new object to landscape because it is not a valid physics object!");
        
        [self.objectsToAdd addObject:object];
    }
}

#pragma mark Removing
-(void)removePhysicsObject:(PhysicsObject *)object
{
    [self.objectsToRemove addObject:object];
}
-(void)removePhysicsObjects:(NSArray *)objects
{
    for(PhysicsObject *object in objects)
    {
        [self.objectsToAdd addObject:object];
    }
}

#pragma mark - Updating Engine
-(void)setShouldUpdate:(BOOL)shouldUpdate
{
    self.isUpdating = shouldUpdate;
    if(self.isUpdating)
    {
        if ([self.physicsLandscapeDelegate respondsToSelector: @selector(landscapeDidBeginUpdatingForPhysicsLandscape:)])
        {
            [self.physicsLandscapeDelegate landscapeDidBeginUpdatingForPhysicsLandscape:self];
        }
        self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(loop) userInfo:nil repeats:TRUE];
    }
    else
    {
        [self.loopTimer invalidate];
        if ([self.physicsLandscapeDelegate respondsToSelector: @selector(landscapeDidEndUpdatingForPhysicsLandscape:)])
        {
            [self.physicsLandscapeDelegate landscapeDidEndUpdatingForPhysicsLandscape:self];
        }
    }
}

-(void)loop
{
    if ([self.physicsLandscapeDelegate respondsToSelector: @selector(landscapeWillUpdateForPhysicsLandscape:)])
	{
		[self.physicsLandscapeDelegate landscapeWillUpdateForPhysicsLandscape:self];
	}
    
    [self updatePhysicsObjectFromAddAndRemoveCache];
    
    for(PhysicsObject *object in self.physicObjects)
    {
        if ([self.physicsLandscapeDelegate respondsToSelector: @selector(landscapeWillUpdateObject:forLandscape:)])
        {
            [self.physicsLandscapeDelegate landscapeWillUpdateObject:object forLandscape:self];
        }
        
        [object updatePositionWithInterval:self.updateInterval];
        
        if ([self.physicsLandscapeDelegate respondsToSelector: @selector(landscapeDidUpdateObject:forLandscape:)])
        {
            [self.physicsLandscapeDelegate landscapeDidUpdateObject:object forLandscape:self];
        }
    }
    
    [self checkForCollisions];
    
    if ([self.physicsLandscapeDelegate respondsToSelector: @selector(landscapeDidUpdateForPhysicsLandscape:)])
    {
        [self.physicsLandscapeDelegate landscapeDidUpdateForPhysicsLandscape:self];
    }
}

#pragma mark - Collisions
-(BOOL)checkCollisiosnForObject1:(PhysicsObject *)object1 andObject2:(PhysicsObject *)object2
{
    if(![object1 isEqual:object2])
    {
        BOOL value = CGRectIntersectsRect(object1.frame, object2.frame);
        return value;
    }
    else
    {
        return FALSE;
    }
}

-(void)checkForCollisions
{
    NSMutableArray *allCollisions = [[NSMutableArray alloc] init];
    for(PhysicsObject *object1 in self.physicObjects)
    {
        NSMutableSet *subCollisions = [[NSMutableSet alloc] init];
        for(PhysicsObject *object2 in self.physicObjects)
        {
            if([self checkCollisiosnForObject1:object1 andObject2:object2])
            {
                [subCollisions addObject:object1];
                [subCollisions addObject:object2];
            }
        }
        
        if(subCollisions.count > 0)
            [allCollisions addObject:subCollisions];
    }
    
    if(allCollisions.count > 0)
    {
        if([self.physicsLandscapeDelegate respondsToSelector:@selector(collisionDidOccurWithPhysicsLandscape:andObjects:)])
        {
            [self.physicsLandscapeDelegate collisionDidOccurWithPhysicsLandscape:self andObjects:allCollisions];
        }
    }
}

@end
