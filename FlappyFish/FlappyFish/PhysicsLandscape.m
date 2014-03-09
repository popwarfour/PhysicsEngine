//
//  PhysicsLandscape.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "PhysicsLandscape.h"
#import "PhysicsObject.h"

@implementation PhysicsLandscape

-(id)initWithFrame:(CGRect)frame andPhysicsObjects:(NSMutableArray *)physicsObjects andUpdateInterval:(float)updateInterval
{
    if(self = [super init])
    {
        self.view = [[UIView alloc] initWithFrame:frame];
        self.physicObjects = physicsObjects;
        self.updateInterval = updateInterval;
        [self setShouldUpdate:TRUE];
        
        for(PhysicsObject *obj in self.physicObjects)
        {
            [self.view addSubview:obj];
        }
    }
    return self;
}

-(void)setShouldUpdate:(BOOL)shouldUpdate
{
    self.isUpdating = shouldUpdate;
    if(self.isUpdating)
    {
        [self.physicsLandscapeDelegate landscapeDidBeginUpdatingForPhysicsLandscape:self];
        self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(loop) userInfo:nil repeats:TRUE];
    }
    else
    {
        [self.loopTimer invalidate];
        [self.physicsLandscapeDelegate landscapeDidEndUpdatingForPhysicsLandscape:self];
    }
}

-(void)loop
{
    [self.physicsLandscapeDelegate landscapeWillUpdateForPhysicsLandscape:self];
    for(PhysicsObject *object in self.physicObjects)
    {
        [self.physicsLandscapeDelegate landscapeWillUpdateObject:object forLandscape:self];
        [object updatePositionWithInterval:self.updateInterval];
        [self.physicsLandscapeDelegate landscapeDidUpdateObject:object forLandscape:self];
    }
    [self.physicsLandscapeDelegate landscapeDidUpdateForPhysicsLandscape:self];
}

-(void)checkForCollisions
{
    NSMutableArray *collisionsObjects = [[NSMutableArray alloc] init];
    if(collisionsObjects.count > 0)
    {
        [self.physicsLandscapeDelegate collisionDidOccurWithPhysicsLandscape:self andObjects:collisionsObjects];
    }
}

@end
