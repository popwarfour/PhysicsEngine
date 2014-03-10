//
//  GravityViewController.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "PhysicsLandscapeViewController.h"

@interface PhysicsLandscapeViewController ()

@end

@implementation PhysicsLandscapeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPhysicsObjects:(NSMutableArray *)physicsObjects andUpdateInterval:(float)updateInteral
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.physicObjects = physicsObjects;
        self.updateInterval = updateInteral;
    }
    return self;
}

-(void)addObjectsToView
{
    for(PhysicsObject *object in self.physicObjects)
    {
        [self.view addSubview:object];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self addObjectsToView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)upButtonPressed:(id)sender
{
    PhysicsObject *obj = [self.physicObjects firstObject];
    obj.velocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:0];
    
    Force *upForce = [[Force alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:-35] andIsVelocity:FALSE andMaxSteps:1 andTag:@"up"];
    NSMutableArray *forces = obj.forces;
    [forces addObject:upForce];
}

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
