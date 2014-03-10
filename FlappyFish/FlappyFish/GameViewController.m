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
    
    //Buttons & Labels
    self.gameOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 100)];
    [self.gameOverLabel setTextAlignment:NSTextAlignmentCenter];
    [self.gameOverLabel  setFont:[self.gameOverLabel.font fontWithSize:40]];
    [self.gameOverLabel  setText:@"Are You Ready?"];
    
    self.startNewGameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.startNewGameButton setFrame:CGRectMake(40, 250, 320 - 80, 50)];
    [self.startNewGameButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startNewGameButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    
    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 30)];
    [self.scoreLabel setFont:[self.scoreLabel.font fontWithSize:30]];
    [self.scoreLabel setTextAlignment:NSTextAlignmentCenter];
    [self.scoreLabel setText:@"0"];
    
    CGRect curFrame = self.view.frame;
    self.gameView = [[PhysicsLandscape alloc] initWithFrame:curFrame andPhysicsObjects:[self createFishAndWalls] andUpdateInterval:1.0/60.0];
    [self.gameView setPhysicsLandscapeDelegate:self];
    [self.view addSubview:self.gameView];
    
    [self.view bringSubviewToFront:self.upButton];
    
    [self.gameView setShouldUpdate:FALSE];
    
    [self.view addSubview:self.gameOverLabel];
    [self.view addSubview:self.startNewGameButton];
    [self.view addSubview:self.scoreLabel];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self startGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)createFishAndWalls
{
    float gravityDown = 8/60.0;
    PhysicsForce *gravityForce = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:gravityDown] andIsVelocity:FALSE andMaxSteps:-1 andTag:@"gravity"];
    
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
    PhysicsForce *gravityForce = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:gravityDown] andIsVelocity:FALSE andMaxSteps:-1 andTag:@"gravity"];
    
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
    
    PhysicsForce *upForce = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:-4] andIsVelocity:TRUE andMaxSteps:1 andTag:@"up"];
    NSMutableArray *forces = self.fish.forces;
    [forces addObject:upForce];
}




#pragma mark - PhysicsLandscapeViewControllerDelegate Methods
-(void)collisionDidOccurWithPhysicsLandscape:(PhysicsLandscape *)_landscape andObjects:(NSMutableArray *)_objects
{
    NSArray *firstCollisionsSet = [[_objects firstObject] allObjects];
    PhysicsObject *object1 = [firstCollisionsSet firstObject];
    PhysicsObject *object2 = [firstCollisionsSet lastObject];
    
    [self checkForGameOverCollision:object1];
    [self checkForGameOverCollision:object2];
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
-(void)startGame
{
    //Remove Labels & Buttons
    [self.gameOverLabel removeFromSuperview];
    [self.startNewGameButton removeFromSuperview];
    
    self.currentScore = -1;
    [self updateScoreLabel];
    
    //Remove Walls
    for(PhysicsObject *object in self.gameView.physicObjects)
    {
        if(![object.objectTag isEqualToString:@"fish"] && ![object.objectTag isEqualToString:@"top"] && ![object.objectTag isEqualToString:@"bottom"])
        {
            [self.gameView removePhysicsObject:object];
        }
    }
    
    [self.gameView updatePhysicsObjectFromAddAndRemoveCache];
    
    //Reset Fish
    int startX = 320/3;
    int startY = 568/2;
    [self.fish setFrame:CGRectMake(startX, startY, 10, 10)];
    [self.fish setPhysicsPosition:[[PhysicsObjectPosition alloc] initWithX:self.fish.layer.position.x andY:self.fish.layer.position.y]];
    [self.fish setVelocity:[[PhysicsVector alloc] initWithWidth:0 andHeight:0]];
    for(PhysicsForce *force in self.fish.forces)
    {
        if(![force.tag isEqualToString:@"gravity"])
        {
            [self.fish.forces removeObject:force];
        }
    }
    
    //Start Game Engine
    [self.gameView setShouldUpdate:TRUE];
    
    self.createNewWallTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(addNewMovingWalls) userInfo:nil repeats:TRUE];
}

-(void)gameOver
{
    [self.gameView setShouldUpdate:FALSE];
    
    [self.createNewWallTimer invalidate];
    [self.updateScoreTimer invalidate];
    
    [self.gameOverLabel setText:@"Game Over!"];
    [self.startNewGameButton setTitle:@"Start New Game" forState:UIControlStateNormal];
    
    [self.view addSubview:self.gameOverLabel];
    [self.view addSubview:self.startNewGameButton];
}


-(void)checkBounceCollisionsWithObject1:(PhysicsObject *)object1 andObject2:(PhysicsObject *)object2
{
    /*
     PhysicsVector *newVelocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:object1.velocity.height * -0.9];
     Force *upForce = [[Force alloc] initWithInitialVector:newVelocity andIsVelocity:TRUE andMaxSteps:1 andTag:@"bounce"];
     NSMutableArray *forces = object1.forces;
     [forces addObject:upForce];
     
     [object1 setVelocity:[[PhysicsVector alloc] initWithWidth:0 andHeight:0]];*/
}

-(void)checkForGameOverCollision:(PhysicsObject *)object
{
    //Add Bounce!
    if([object.objectTag isEqualToString:@"fish"] ||
       [object.objectTag isEqualToString:@"top"] ||
       [object.objectTag isEqualToString:@"bottom"] ||
       [object.objectTag isEqualToString:@"topWall"] ||
       [object.objectTag isEqualToString:@"bottomWall"])
    {
        [self gameOver];
    }
}

-(void)updateScoreLabelSoon
{
    self.updateScoreTimer = [NSTimer scheduledTimerWithTimeInterval:3.25 target:self selector:@selector(updateScoreLabel) userInfo:nil repeats:FALSE];
}

-(void)updateScoreLabel
{
    [self.updateScoreTimer invalidate];
    
    NSLog(@"UPDATIN SCORE");
    
    self.currentScore++;
    
    if(self.currentScore >= 0)
    {
        NSString *score = [NSString stringWithFormat:@"%d", self.currentScore];
        [self.scoreLabel setText:score];
    }
    else
    {
        [self.scoreLabel setText:@"0"];
    }
    
}

-(void)addNewMovingWalls
{
    NSArray *walls = [self generateNewMovingWalls];
    
    [self.gameView addNewPhysicsObjects:walls];
    
    [self updateScoreLabelSoon];
}

-(NSArray *)generateNewMovingWalls
{
    int randGapHeight = (arc4random() % 50) + 80;
    int randTopHeight = (arc4random() % 200) + 50;
    int bottomHeight = self.view.frame.size.height - (randGapHeight + randTopHeight);
    
    PhysicsForce *leftForceTop = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:-1 * (80.0/60.0) andHeight:0] andIsVelocity:TRUE andMaxSteps:-1 andTag:@"leftForceTop"];
    PhysicsForce *leftForceBottom = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:-1 * (80.0/60.0) andHeight:0] andIsVelocity:TRUE andMaxSteps:-1 andTag:@"leftForceBottom"];
    
    PhysicsObject *topWall = [[PhysicsObject alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 50, randTopHeight) initialForces:@[leftForceTop] andImage:nil];
    topWall.objectTag = @"topWall";
    [topWall setBackgroundColor:[UIColor grayColor]];
    
    PhysicsObject *bottomWall = [[PhysicsObject alloc] initWithFrame:CGRectMake(self.view.frame.size.width, randTopHeight + randGapHeight, 50, bottomHeight) initialForces:@[leftForceBottom] andImage:nil];
    bottomWall.objectTag = @"bottomWall";
    [topWall setBackgroundColor:[UIColor grayColor]];
    
    return @[topWall, bottomWall];
}

@end
