//
//  GameViewController.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect curFrame = self.view.frame;
    self.gameView = [[PhysicsLandscape alloc] initWithFrame:curFrame andPhysicsObjects:[self createFishAndWalls] andUpdateInterval:1.0/60.0];
    [self.gameView setPhysicsLandscapeDelegate:self];
    [self.view addSubview:self.gameView];
    
    [self.view bringSubviewToFront:self.upButton];
    
    [self.gameView setShouldUpdate:TRUE];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(addNewMovingWalls) userInfo:nil repeats:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)createFishAndWalls
{
    float gravityDown = 8/60.0;
    Force *gravityForce = [[Force alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:gravityDown] andIsVelocity:FALSE andMaxSteps:-1 andTag:@"gravity"];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    //Create Fish
    int startX = 320/3;
    int startY = 568/2;
    self.fish = [[PhysicsObject alloc] initWithFrame:CGRectMake(startX, startY, 10, 10) initialForces:@[gravityForce] andImage:nil];
    self.fish.objectTag = @"fish";
    [objects addObject:self.fish];
    
    //Create Ground
    PhysicsObject *top = [[PhysicsObject alloc] initWithFrame:CGRectMake(0, -5, 320, 5) initialForces:@[] andImage:nil];
    top.objectTag = @"top";
    [objects addObject:top];
    
    
    PhysicsObject *bottom = [[PhysicsObject alloc] initWithFrame:CGRectMake(0, 568, 320, 5) initialForces:@[] andImage:nil];
    bottom.objectTag = @"bottom";
    [objects addObject:bottom];
    
    return objects;
}


-(NSMutableArray *)createSnowWithFlaiks:(int)numFlaiks
{
    float gravityDown = 8/60.0;
    //float gravityDown = 10.0/60.0;
    Force *gravityForce = [[Force alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:gravityDown] andIsVelocity:FALSE andMaxSteps:-1 andTag:@"gravity"];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < numFlaiks; i++)
    {
        NSMutableArray *forces = [[NSMutableArray alloc] init];
        [forces addObject:gravityForce];
        
        int randX = 175;//(arc4random() % 310) + 5;
        int randY = 5;
        PhysicsObject *newSnowFlaik = [[PhysicsObject alloc] initWithFrame:CGRectMake(randX, randY, 10, 10) initialForces:forces andImage:nil];
        newSnowFlaik.objectTag = @"snowflaik";
        
        [objects addObject:newSnowFlaik];
    }
    
    PhysicsObject *ground = [[PhysicsObject alloc] initWithFrame:CGRectMake(0, 300, 320, 10) initialForces:nil andImage:nil];
    ground.objectTag = @"ground";
    [ground setBackgroundColor:[UIColor brownColor]];
    [objects addObject:ground];
    
    return objects;
}

-(void)resetSnowFlaik:(PhysicsObject *)snowFlaik
{
    //int randX = (arc4random() % 310) + 5;
    //[snowFlaik setFrame:CGRectMake(randX, -5, 5, 5)];
    //[snowFlaik setVelocity:CGSizeMake(0, 0)];
}

- (IBAction)upButtonPressed:(id)sender
{
    self.fish.velocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:0];
    
    Force *upForce = [[Force alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:-4] andIsVelocity:TRUE andMaxSteps:1 andTag:@"up"];
    NSMutableArray *forces = self.fish.forces;
    [forces addObject:upForce];
}




#pragma mark - PhysicsLandscapeViewControllerDelegate Methods
-(void)collisionDidOccurWithPhysicsLandscape:(PhysicsLandscape *)_landscape andObjects:(NSMutableArray *)_objects
{
    NSArray *firstCollisionsSet = [[_objects firstObject] allObjects];
    PhysicsObject *object1 = [firstCollisionsSet firstObject];
    PhysicsObject *object2 = [firstCollisionsSet lastObject];
    
    //Add Bounce!
    if([object1.objectTag isEqualToString:@"fish"])
    {
        PhysicsVector *newVelocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:object1.velocity.height * -0.9];
        Force *upForce = [[Force alloc] initWithInitialVector:newVelocity andIsVelocity:TRUE andMaxSteps:1 andTag:@"bounce"];
        NSMutableArray *forces = object1.forces;
        [forces addObject:upForce];
        
        [object1 setVelocity:[[PhysicsVector alloc] initWithWidth:0 andHeight:0]];
    }
    if([object2.objectTag isEqualToString:@"fish"])
    {
        PhysicsVector *newVelocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:object2.velocity.height * -0.9];
        Force *upForce = [[Force alloc] initWithInitialVector:newVelocity andIsVelocity:TRUE andMaxSteps:1 andTag:@"bounce"];
        NSMutableArray *forces = object2.forces;
        [forces addObject:upForce];
        
        [object2 setVelocity:[[PhysicsVector alloc] initWithWidth:0 andHeight:0]];
    }
}

-(void)landscapeDidUpdateObject:(PhysicsObject *)object forLandscape:(PhysicsLandscape *)_landscape
{
    if([object.objectTag isEqualToString:@"bottomWall"] || [object.objectTag isEqualToString:@"topWall"])
    {
        if((object.frame.origin.x + object.frame.size.width) <= 0)
        {
            [self.gameView removePhysicsObject:object];
        }
    }
}

#pragma mark - Game Methods

-(void)addNewMovingWalls
{
    NSArray *walls = [self generateNewMovingWalls];
    [self.gameView.physicObjects addObjectsFromArray:walls];
    [self.gameView addSubview:[walls firstObject]];
    [self.gameView addSubview:[walls lastObject]];
}

-(NSArray *)generateNewMovingWalls
{
    int randGapHeight = (arc4random() % 50) + 80;
    int randTopHeight = (arc4random() % 200) + 50;
    int bottomHeight = self.view.frame.size.height - (randGapHeight + randTopHeight);
    
    Force *leftForceTop = [[Force alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:-1 * (80.0/60.0) andHeight:0] andIsVelocity:TRUE andMaxSteps:-1 andTag:@"leftForceTop"];
    Force *leftForceBottom = [[Force alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:-1 * (80.0/60.0) andHeight:0] andIsVelocity:TRUE andMaxSteps:-1 andTag:@"leftForceBottom"];
    
    PhysicsObject *topWall = [[PhysicsObject alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 50, randTopHeight) initialForces:@[leftForceTop] andImage:nil];
    topWall.objectTag = @"topWall";
    [topWall setBackgroundColor:[UIColor blackColor]];
    
    PhysicsObject *bottomWall = [[PhysicsObject alloc] initWithFrame:CGRectMake(self.view.frame.size.width, randTopHeight + randGapHeight, 50, bottomHeight) initialForces:@[leftForceBottom] andImage:nil];
    bottomWall.objectTag = @"bottomWall";
    [topWall setBackgroundColor:[UIColor grayColor]];
    
    return @[topWall, bottomWall];
}

@end
