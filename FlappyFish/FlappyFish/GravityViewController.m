//
//  GravityViewController.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "GravityViewController.h"

@interface GravityViewController ()

@end

@implementation GravityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSMutableArray *objects = [self createSnowWithFlaiks:1];
        self.mainLandscape = [[PhysicsLandscape alloc] initWithFrame:self.view.frame andPhysicsObjects:objects andUpdateInterval:5];
        [self.mainLandscape setPhysicsLandscapeDelegate:self];
        [self.mainLandscape setShouldUpdate:TRUE];
        [self.view addSubview:self.mainLandscape.view];
    }
    return self;
}

-(NSMutableArray *)createSnowWithFlaiks:(int)numFlaiks
{
    Force *gravityForce = [[Force alloc] initWithInitialVector:CGSizeMake(0, 8) andIsVelocity:TRUE andMaxSteps:-1 andTag:@"gravity"];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < numFlaiks; i++)
    {
        NSMutableArray *forces = [[NSMutableArray alloc] init];
        [forces addObject:gravityForce];
        
        int randX = (arc4random() % 310) + 5;
        int randY = -5;
        PhysicsObject *newSnowFlaik = [[PhysicsObject alloc] initWithFrame:CGRectMake(randX, randY, 10, 10) initialForces:forces andImage:nil];
        
        [objects addObject:newSnowFlaik];
    }
    
    return objects;
}

-(void)resetSnowFlaik:(PhysicsObject *)snowFlaik
{
    int randX = (arc4random() % 310) + 5;
    [snowFlaik setFrame:CGRectMake(randX, -5, 5, 5)];
    [snowFlaik setVelocity:CGSizeMake(0, 0)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)upButtonPressed:(id)sender
{
    PhysicsObject *obj = [self.physicObjects firstObject];
    obj.velocity = CGSizeMake(0, 0);
    
    NSLog(@"NUM FORCES: %d", obj.forces.count);
    
    Force *upForce = [[Force alloc] initWithInitialVector:CGSizeMake(0, -35) andIsVelocity:FALSE andMaxSteps:1 andTag:@"up"];
    NSMutableArray *forces = obj.forces;
    [forces addObject:upForce];
}

#pragma mark - PhysicsLandscapeDelegate

#pragma mark OBJECTS
-(void)landscapeWillUpdateObject:(PhysicsObject *)objet forLandscape:(PhysicsLandscape *)_landscape
{
    
}

-(void)landscapeDidUpdateObject:(PhysicsObject *)objet forLandscape:(PhysicsLandscape *)_landscape
{
    
}

#pragma mark BEING AND END UPDATING
-(void)landscapeDidBeginUpdatingForPhysicsLandscape:(PhysicsLandscape *)_landscape
{
    NSLog(@"DID BEGIN UPDATING!");
}

-(void)landscapeDidEndUpdatingForPhysicsLandscape:(PhysicsLandscape *)_landscape
{
    NSLog(@"DID END UPDATING!");
}

#pragma mark UPDATES
-(void)landscapeWillUpdateForPhysicsLandscape:(PhysicsLandscape *)_landscape
{
    
}
-(void)landscapeDidUpdateForPhysicsLandscape:(PhysicsLandscape *)_landscape
{
    
}

#pragma mark COLLISIONS
-(void)collisionDidOccurWithPhysicsLandscape:(PhysicsLandscape *)_landscape andObjects:(NSMutableArray *)_objects
{
    
}

@end
