//
//  EvolutionController.m
//  FlappyFish
//
//  Created by Jordan Rouille on 4/28/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "EvolutionController.h"

@interface EvolutionController ()

@end

@implementation EvolutionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGameViewController:(GameViewController *)gameVC
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        //ArffFormatter *formatter = [[ArffFormatter alloc] init];
        //[formatter createTestingData];
        
        self.gameVC = gameVC;
        
        self.currentEnvolution = 0;
        self.currentEpic = 0;
        self.parentFitness = 0;
        
        self.evolutionState = EVOLUTION_STATE_MENU;
        
        self.currentGapHeight = MAX_GAP_HEIGHT;
        
        self.rules = [[NSMutableArray alloc] init];
        
        self.menuView = [[UIView alloc] initWithFrame:self.view.frame];
        UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [startButton setFrame:CGRectMake(0, 130, self.view.frame.size.width, 50)];
        [startButton setTitle:@"Start Gathering Training Data" forState:UIControlStateNormal];
        [startButton addTarget:self action:@selector(startEvolution) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:startButton];
        
        [self.view addSubview:self.menuView];
        
        //Register CallsBacks
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameDidEnd) name:@"gameDidEnd" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEvolutionWithData:) name:@"checkEvolution" object:nil];
    }
    return self;
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

#pragma mark - Controller Methods


-(void)startEvolution
{
    self.currentGapHeight = MAX_GAP_HEIGHT;
    self.evolutionState = EVOLUTION_STATE_RUNNING;
    [self.menuView removeFromSuperview];
    
    [self.view addSubview:self.gameVC.view];
    [self.gameVC setWallGap:self.currentGapHeight];
    [self.gameVC backgroundButtonPressed:nil];
}

#pragma mark - Game CallsBacks
-(void)gameDidEnd
{
    //Update Fitnes
    if(self.gameVC.fitness > self.parentFitness)
        self.parentFitness = self.gameVC.fitness;
    
    //Remove last couple rules because they got us killed!
    for(int i = 0; i < 10; i++)
        [self.rules removeLastObject];
    
    if(self.currentEnvolution < NUM_EVOLUTIONS_PER_EPIC)
    {
        self.currentEnvolution++;
        
        NSLog(@"CURRENT EVOLUTION: %d", self.currentEnvolution);
    }
    else
    {
        ArffFormatter *formatter = [[ArffFormatter alloc] init];
        [formatter convertArrayToArffFormat:self.rules forTraining:FALSE];
        
        [self.gameVC.view removeFromSuperview];
        [self.view addSubview:self.menuView];
    }
    
    /*
    //Next Round
    if(self.currentGapHeight >= MIN_GAP_HEIGHT)
    {
        if(self.currentEnvolution < NUM_EVOLUTIONS_PER_EPIC)
        {
            self.currentEnvolution++;
        }
        else
        {
            self.currentEnvolution = 0;
            self.currentEpic++;
            
            NSLog(@"CURRENT EPIC: %d", self.cur);
            
            self.currentGapHeight -= DELTA_GAP_HEIGHT;
        }
        
        [self startNewGeneration];
    }
    else
    {
        ArffFormatter *formatter = [[ArffFormatter alloc] init];
        [formatter convertArrayToArffFormat:self.rules forTraining:FALSE];
        
        [self.gameVC.view removeFromSuperview];
        [self.view addSubview:self.menuView];
    }*/
}

-(void)startNewGeneration
{
    [self.gameVC setWallGap:self.currentGapHeight];
    [self.gameVC setTopScore:self.parentFitness];
    
    [self perterbModel];
    [self.gameVC startGame];
}


-(void)evolutionStepWithInfo:(NSDictionary *)gameInfo
{
    NSNumber *morganY = [gameInfo objectForKey:@"morganY"];
    NSNumber *wallX = [gameInfo objectForKey:@"wallY"];
    
}

-(void)checkEvolutionWithData:(NSNotification *)notification
{
    NSDictionary *data = [notification object];
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = false;
    
    int morganBottom = (morganY.intValue + morganHeight.intValue);
    
    if(morganBottom > 270)
    {
        pressUp = true;
    }
    

    int xDistance = (wallX.intValue - morganX.intValue);
    int temp = (wallY.intValue + wallHeight.intValue + self.currentGapHeight);
    int yDistance = (morganBottom - temp);
    float ratio = (float)yDistance / (float)xDistance;
    
    if(yDistance < 0)
        ratio = 0;
    
    if(ratio > 0.7 && ratio < 0.8)
    {
        pressUp = true;
    }
    
    ;
    ;
    if((morganX.intValue > (wallX.intValue - wallWidth.intValue)) && (morganX.intValue < (wallX.intValue + (wallWidth.intValue * 2))))
    {
        if(morganBottom + 10 >= wallHeight.intValue + self.currentGapHeight)
        {
            pressUp = true;
        }
    }
    
    if(pressUp)
    {
        NSArray *newKeys = [[NSArray alloc] initWithObjects:@"morganY", @"morganX", @"morganHeight", @"morganWidth", @"wallX", @"wallY", @"wallWidth", @"wallHeight", @"class", nil];
        NSArray *newObjects = [[NSArray alloc] initWithObjects:morganY, morganX, morganHeight, @20, wallX, wallY, wallWidth, wallHeight, @"jump", nil];
        NSDictionary *newData = [[NSDictionary alloc] initWithObjects:newObjects forKeys:newKeys];
        
        [self.rules addObject:newData];
        [self.gameVC backgroundButtonPressed:nil];
    }
    else
    {
        NSArray *newKeys = [[NSArray alloc] initWithObjects:@"morganY", @"morganX", @"morganHeight", @"morganWidth", @"wallX", @"wallY", @"wallWidth", @"wallHeight", @"class", nil];
        NSArray *newObjects = [[NSArray alloc] initWithObjects:morganY, morganX, morganHeight, @20, wallX, wallY, wallWidth, wallHeight, @"noJump", nil];
        NSDictionary *newData = [[NSDictionary alloc] initWithObjects:newObjects forKeys:newKeys];
        
        [self.rules addObject:newData];
    }
}

#pragma mark - Neural Model Methods
-(void)perterbModel
{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
