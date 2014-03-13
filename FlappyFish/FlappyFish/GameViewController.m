//
//  GameViewController.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "GameViewController.h"

#define GAME_STATE_STARTED 0
#define GAME_STATE_ENDED 1

@interface GameViewController ()

@property int previousScoreTag;

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
    
    self.previousScoreTag = 1;
    
    self.gameState = GAME_STATE_ENDED;
    
    //Buttons & Labels
    self.gameOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 100)];
    [self.gameOverLabel setTextAlignment:NSTextAlignmentCenter];
    [self.gameOverLabel  setFont:[self.gameOverLabel.font fontWithSize:40]];
    [self.gameOverLabel  setText:@"Are You Ready?"];
    
    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320 / 2, 30)];
    [self.scoreLabel setFont:[self.scoreLabel.font fontWithSize:30]];
    [self.scoreLabel setTextAlignment:NSTextAlignmentCenter];
    [self.scoreLabel setText:@"0"];
    
    self.topScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(320 / 2, 20, 320 / 2, 30)];
    [self.topScoreLabel setFont:[self.topScoreLabel.font fontWithSize:30]];
    [self.topScoreLabel setTextAlignment:NSTextAlignmentCenter];
    [self.topScoreLabel setText:@"0"];
    
    
    CGRect curFrame = self.view.frame;
    self.gameView = [[PhysicsLandscape alloc] initWithFrame:curFrame andPhysicsObjects:[self createFishAndWalls] andUpdateInterval:1.0/60.0];
    [self.gameView setPhysicsLandscapeDelegate:self];
    [self.gameView setShouldShowFrameRate:TRUE];
    [self.view addSubview:self.gameView];
    
    [self.view bringSubviewToFront:self.upButton];
    
    [self.gameView setShouldUpdate:FALSE];
    
    [self.view addSubview:self.gameOverLabel];
    [self.view addSubview:self.scoreLabel];
    [self.view addSubview:self.topScoreLabel];
}

-(void)viewDidAppear:(BOOL)animated
{
    //[self startGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)createFishAndWalls
{
    float gravityDown = 15.0/60.0;
    PhysicsForce *gravityForce = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:gravityDown] andIsVelocity:FALSE andMaxSteps:-1 andTag:@"gravity"];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    //Create Fish
    int startX = 320/3;
    int startY = 568/2;
    
    self.fish = [[PhysicsObject alloc] initWithFrame:CGRectMake(startX, startY, 30, 25) initialForces:@[gravityForce] andImage:[UIImage imageNamed:@"test.png"] withImageFrame:CGRectMake(0, 0, 30, 25) andDoesAnimateChanges:FALSE];
    self.fish.objectTag = @"fish";
    [objects addObject:self.fish];
    
    //Create Ground
    PhysicsObject *top = [[PhysicsObject alloc] initWithFrame:CGRectMake(0, -5, 320, 5) initialForces:@[] andImage:nil withImageFrame:CGRectZero  andDoesAnimateChanges:FALSE];
    top.objectTag = @"top";
    [objects addObject:top];
    
    
    PhysicsObject *bottom = [[PhysicsObject alloc] initWithFrame:CGRectMake(0, 568, 320, 5) initialForces:@[] andImage:nil withImageFrame:CGRectZero andDoesAnimateChanges:FALSE];
    bottom.objectTag = @"bottom";
    [objects addObject:bottom];
    
    return objects;
}


-(NSMutableArray *)createSnowWithFlaiks:(int)numFlaiks
{
    float gravityDown = 1.0/60.0;
    //float gravityDown = 10.0/60.0;
    PhysicsForce *gravityForce = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:gravityDown] andIsVelocity:FALSE andMaxSteps:-1 andTag:@"gravity"];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < numFlaiks; i++)
    {
        NSMutableArray *forces = [[NSMutableArray alloc] init];
        [forces addObject:gravityForce];
        
        int randX = 175;//(arc4random() % 310) + 5;
        int randY = 5;
        PhysicsObject *newSnowFlaik = [[PhysicsObject alloc] initWithFrame:CGRectMake(randX, randY, 10, 10) initialForces:forces andImage:nil withImageFrame:CGRectZero andDoesAnimateChanges:FALSE];
        newSnowFlaik.objectTag = @"snowflaik";
        
        [objects addObject:newSnowFlaik];
    }
    
    PhysicsObject *ground = [[PhysicsObject alloc] initWithFrame:CGRectMake(0, 300, 320, 10) initialForces:nil andImage:nil withImageFrame:CGRectZero andDoesAnimateChanges:FALSE];
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

- (IBAction)backgroundButtonPressed:(id)sender
{
    if(self.gameState == GAME_STATE_STARTED)
    {
        self.fish.velocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:0];
        
        PhysicsForce *upForce = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:-5.5] andIsVelocity:TRUE andMaxSteps:1 andTag:@"up"];
        NSMutableArray *forces = self.fish.forces;
        [forces addObject:upForce];
    }
    else if(self.gameState == GAME_STATE_ENDED)
    {
        [self startGame];
    }
}




#pragma mark - PhysicsLandscapeViewControllerDelegate Methods
-(void)collisionDidOccurWithPhysicsLandscape:(PhysicsLandscape *)_landscape andObjects:(NSMutableArray *)_objects
{
    NSArray *firstCollisionsSet = [[_objects firstObject] allObjects];
    PhysicsObject *object1 = [firstCollisionsSet firstObject];
    PhysicsObject *object2 = [firstCollisionsSet lastObject];
    
    //[self checkForGameOverCollisionWithObject1:object1 andObject2:object2];
    
    //[self checkBounceCollisionsWithObject1:object1 andObject2:object2];
}


-(void)landscapeWillUpdateForPhysicsLandscape:(PhysicsLandscape *)_landscape
{
    for(PhysicsObject *annoyingObject in _landscape.physicObjects)
    {
        if([annoyingObject.objectTag isEqualToString:@"annoyingObject"])
        {
            [annoyingObject.forces removeAllObjects];
            
            int xObjectCenter = annoyingObject.frame.origin.x + (annoyingObject.frame.size.width / 2);
            int yObjectCenter = annoyingObject.frame.origin.y + (annoyingObject.frame.size.height / 2);
            
            
            int xFrameCenter = self.fish.frame.origin.x + (self.fish.frame.size.width / 2);
            int yFrameCenter = self.fish.frame.origin.y + (self.fish.frame.size.height / 2);
            
            //int xFrameCenter = 320 / 2;
            //int yFrameCenter = self.view.frame.size.height / 2;
            
            int xDistanceToCenter = xFrameCenter - xObjectCenter;
            int yDistanceToCenter = yFrameCenter - yObjectCenter;
            
            //NSLog(@"NORMALIZED X: %f", xDistanceToCenter / 320.0);
            //NSLog(@"NORMALIZED Y: %f", yDistanceToCenter / 568.0);
            PhysicsForce *newForce = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:(xDistanceToCenter / 320.0) andHeight:(yDistanceToCenter / 568.0)] andIsVelocity:TRUE andMaxSteps:1 andTag:@"funForce"];
            [annoyingObject.forces addObject:newForce];
        }
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

-(void)landscapeDidUpdateForPhysicsLandscape:(PhysicsLandscape *)_landscape
{
    int fishXLocation = self.fish.frame.origin.x;
    NSArray *physicsObjects = self.gameView.physicObjects;
    for(PhysicsObject *object in physicsObjects)
    {
        if([object.objectTag isEqualToString:@"topWall"] && (object.frame.origin.x + object.frame.size.width < fishXLocation) && object.tag > self.currentScore)
        {
            self.currentScore = object.tag;
            [self didLevelUp];
        }
    }
}

#pragma mark - Game Methods
-(void)didLevelUp
{
    [self updateScoreLabel];
    

    if(self.currentScore == 1)
    {
        NSArray *temp = [self addAnnoyingThing:6];
        [self.gameView addNewPhysicsObjects:temp];
    }
    else if(self.currentScore == 3)
    {
        for(PhysicsObject *temp in self.gameView.physicObjects)
        {
            if([temp.objectTag isEqualToString:@"annoyingObject"])
            {
                [self.gameView removePhysicsObject:temp];
            }
        }
    }
    else if(self.currentScore == 5)
    {
        NSArray *temp = [self addAnnoyingThing:12];
        [self.gameView addNewPhysicsObjects:temp];
    }
    else if(self.currentScore == 7)
    {
        for(PhysicsObject *temp in self.gameView.physicObjects)
        {
            if([temp.objectTag isEqualToString:@"annoyingObject"])
            {
                [self.gameView removePhysicsObject:temp];
            }
        }
    }
}
-(void)startGame
{
    self.gameState = GAME_STATE_STARTED;
    
    //Remove Labels & Buttons
    [self.gameOverLabel removeFromSuperview];
    
    self.previousScoreTag = 1;
    self.currentScore = 0;
    self.extraLives = 0;
    
    [self updateScoreLabel];
    
    //Remove Walls
    for(PhysicsObject *object in self.gameView.physicObjects)
    {
        if(![object.objectTag isEqualToString:@"fish"] && ![object.objectTag isEqualToString:@"top"] && ![object.objectTag isEqualToString:@"bottom"])
        {
            [self.gameView removePhysicsObject:object];
        }
    }
    
    //Reset Fish
    int startX = 320/3;
    int startY = 568/2;
    [self.fish setFrame:CGRectMake(startX, startY, self.fish.frame.size.width, self.fish.frame.size.height)];
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
    
    [self addNewMovingWalls];
    self.createNewWallTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(addNewMovingWalls) userInfo:nil repeats:TRUE];
}

-(void)gameOver
{
    self.gameState = GAME_STATE_ENDED;
    
    [self.gameView setShouldUpdate:FALSE];
    
    [self.createNewWallTimer invalidate];
    
    [self.gameOverLabel setText:@"Game Over!"];
    
    [self.view addSubview:self.gameOverLabel];
}


-(void)checkBounceCollisionsWithObject1:(PhysicsObject *)object1 andObject2:(PhysicsObject *)object2
{
    if(([object1.objectTag isEqualToString:@"fish"] || [object1.objectTag isEqualToString:@"bottom"]) &&
       ([object2.objectTag isEqualToString:@"fish"] || [object2.objectTag isEqualToString:@"bottom"]))
    {
        PhysicsVector *newVelocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:object1.velocity.height * -0.9];
        PhysicsForce *bounceForce = [[PhysicsForce alloc] initWithInitialVector:newVelocity andIsVelocity:TRUE andMaxSteps:1 andTag:@"bounce"];
        NSMutableArray *forces = self.fish.forces;
        [forces addObject:bounceForce];
        
        [self.fish setVelocity:[[PhysicsVector alloc] initWithWidth:0 andHeight:0]];
    }
}

-(void)checkForGameOverCollisionWithObject1:(PhysicsObject *)object1 andObject2:(PhysicsObject *)object2
{
    //Add Bounce!
    if([object1.objectTag isEqualToString:@"fish"] && ![object2.objectTag isEqualToString:@"annoyingObject"])
    {
        if(TRUE)//![object2.objectTag isEqualToString:@"bottom"])
        {
            [self gameOver];
        }
        else
        {
            self.extraLives--;
        }
    }
    if([object2.objectTag isEqualToString:@"fish"] && ![object1.objectTag isEqualToString:@"annoyingObject"])
    {
        if(TRUE)//![object1.objectTag isEqualToString:@"bottom"])
        {
            [self gameOver];
        }
    }
}

-(void)updateScoreLabel
{
    NSString *score = [NSString stringWithFormat:@"%d", self.currentScore];
    [self.scoreLabel setText:score];
    
    if(self.currentScore > self.topScore)
    {
        self.topScore = self.currentScore;
    }

    NSString *topScore = [NSString stringWithFormat:@"%d", self.topScore];
    [self.topScoreLabel setText:topScore];
}

-(void)addNewMovingWalls
{
    NSArray *walls = [self generateNewMovingWalls];
    
    [self.gameView addNewPhysicsObjects:walls];
}

-(NSMutableArray *)addAnnoyingThing:(int)count
{
    NSMutableArray *test = [[NSMutableArray alloc] init];
    for(int i = 0; i < count; i++)
    {
        PhysicsForce *force = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:0 andHeight:0] andIsVelocity:TRUE andMaxSteps:-1 andTag:@"funForce"];
        PhysicsObject *fun = [[PhysicsObject alloc] initWithFrame:CGRectMake(i * (100), -30 * i, 30, 30) initialForces:@[force] andImage:nil withImageFrame:CGRectZero andDoesAnimateChanges:FALSE];
        fun.objectTag = @"annoyingObject";
        [test addObject:fun];
    }
    return test;
}


-(NSArray *)generateNewMovingWalls
{
    int randGapHeight = 100;//(arc4random() % 50) + 80;
    int randTopHeight = (arc4random() % 400) + 50;
    int bottomHeight = self.view.frame.size.height - (randGapHeight + randTopHeight);
    
    PhysicsForce *leftForceTop = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:-1 * (120.0/60.0) andHeight:0] andIsVelocity:TRUE andMaxSteps:-1 andTag:@"leftForceTop"];
    PhysicsForce *leftForceBottom = [[PhysicsForce alloc] initWithInitialVector:[[PhysicsVector alloc] initWithWidth:-1 * (120.0/60.0) andHeight:0] andIsVelocity:TRUE andMaxSteps:-1 andTag:@"leftForceBottom"];
    
    PhysicsObject *topWall = [[PhysicsObject alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 50, randTopHeight) initialForces:@[leftForceTop] andImage:nil withImageFrame:CGRectZero andDoesAnimateChanges:FALSE];
    topWall.objectTag = @"topWall";
    topWall.tag = self.previousScoreTag;
    self.previousScoreTag++;
    [topWall setBackgroundColor:[UIColor grayColor]];
    
    PhysicsObject *bottomWall = [[PhysicsObject alloc] initWithFrame:CGRectMake(self.view.frame.size.width, randTopHeight + randGapHeight, 50, bottomHeight) initialForces:@[leftForceBottom] andImage:nil withImageFrame:CGRectZero andDoesAnimateChanges:FALSE];
    bottomWall.objectTag = @"bottomWall";
    [bottomWall setBackgroundColor:[UIColor grayColor]];
    
    return @[topWall, bottomWall];
}

@end
