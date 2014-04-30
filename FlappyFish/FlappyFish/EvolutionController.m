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
    
    if(self.currentEnvolution < NUM_EVOLUTIONS_PER_EPIC)//self.rules.count < 250000)
    {
        self.currentEnvolution++;
        
        NSLog(@"CURRENT EVOLUTION: %d | NUMBER OF RULES: %d", self.currentEnvolution, self.rules.count);
        
        [self startNewGeneration];
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
    //[self.gameVC setTopScore:s];
    
    [self.gameVC startGame];
}


-(void)checkEvolutionWithData:(NSNotification *)notification
{
    BOOL training = FALSE;
    
    NSDictionary *data = [notification object];
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    
    BOOL pressUp = FALSE;
    
    if(training)
    {
        //Training "Known Rules"
        
        int morganBottom = (morganY.intValue + morganHeight.intValue);
        
        if(morganBottom > 270)
        {
            pressUp = TRUE;
        }
        
        
        int xDistance = (wallX.intValue - morganX.intValue);
        int temp = (wallY.intValue + wallHeight.intValue + self.currentGapHeight);
        int yDistance = (morganBottom - temp);
        float ratio = (float)yDistance / (float)xDistance;
        
        if(yDistance < 0)
            ratio = 0;
        
        if(ratio > 0.7 && ratio < 0.8)
        {
            pressUp = TRUE;
        }
        
        ;
        ;
        if((morganX.intValue > (wallX.intValue - wallWidth.intValue)) && (morganX.intValue < (wallX.intValue + (wallWidth.intValue * 2))))
        {
            if(morganBottom + 10 >= wallHeight.intValue + self.currentGapHeight)
            {
                pressUp = TRUE;
            }
        }
    }
    else
    {
        //Testing "Mined Rules"
        //pressUp = [self runRulesFor6GameTest1WithData:data];
        //pressUp = [self runRulesFor6GameTest2WithData:data];
        //pressUp = [self runRulesFor6GameTest3WithData:data];
        
        //pressUp = [self runRulesFor10GameTest1WithData:data];
        //pressUp = [self runRulesFor10GameTest2WithData:data];
        //pressUp = [self runRulesFor10GameTest3WithData:data];
        
        pressUp = [self runRulesForThe250KTestWithData:data];
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

#pragma mark - Mined Models
#pragma mark Testing Set 1 With 18500 Examples

-(BOOL)runRulesFor6GameTest1WithData:(NSDictionary *)data
{
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = FALSE;
    
    //6 Games - 18500 Examples - C=1.0E-6 M=2
    if(morganY.intValue <= 230)
    {
        if(wallX.intValue <= 238)
        {
            if(wallX.intValue <= 228)
            {
                if(morganY.intValue <= 116)
                {
                    //no jump
                }
                else
                {
                    if(wallHeight.intValue <= 131)
                    {
                        if(morganY.intValue <= 189)
                        {
                            if(wallHeight.intValue <= 61)
                            {
                                pressUp = TRUE;
                            }
                            else
                            {
                                //no jump
                            }
                        }
                        else
                        {
                            pressUp = TRUE;
                        }
                    }
                    else
                    {
                        //no jump
                    }
                }
            }
            else
            {
                if(wallHeight.intValue <= 137)
                {
                    if(wallHeight.intValue <= 109)
                    {
                        pressUp = TRUE;
                    }
                    else
                    {
                        if(morganY.intValue <= 192)
                        {
                            //no jump
                        }
                        else
                        {
                            pressUp = TRUE;
                        }
                    }
                }
                else
                {
                    if(morganY.intValue <= 208)
                    {
                        //no jump
                    }
                    else
                    {
                        if(wallHeight.intValue <= 150)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 224)
                            {
                                //no jump
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            //no jump
        }
    }
    else
    {
        pressUp = TRUE;
    }
    
    return pressUp;
}

-(BOOL)runRulesFor6GameTest2WithData:(NSDictionary *)data
{
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = FALSE;
    
    //6 Games - 18500 Examples - C=1.0E-8 M=2
    if(morganY.intValue <= 230)
    {
        if(wallX.intValue <= 220)
        {
            //no jump
        }
        else
        {
            if(wallX.intValue <= 238)
            {
                if(wallX.intValue <= 228)
                {
                    if(morganY.intValue <= 116)
                    {
                        //no jump
                    }
                    else
                    {
                        if(wallHeight.intValue <= 131)
                        {
                            if(morganY.intValue <= 189)
                            {
                                if(wallHeight.intValue <= 61)
                                {
                                    pressUp = TRUE;
                                }
                                else
                                {
                                    if(morganY.intValue <= 147)
                                    {
                                        //no jump
                                    }
                                    else
                                    {
                                        if(morganY.intValue <= 173)
                                        {
                                            if(wallHeight.intValue <= 104)
                                            {
                                                pressUp = TRUE;
                                            }
                                            else
                                            {
                                                //no jump
                                            }
                                        }
                                        else
                                        {
                                            if(wallHeight.intValue <= 117)
                                            {
                                                pressUp = TRUE;
                                            }
                                            else
                                            {
                                                //no jump
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                        else
                        {
                            //no jump
                        }
                    }
                }
                else
                {
                    if(wallHeight.intValue <= 137)
                    {
                        if(wallHeight.intValue <= 109)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 192)
                            {
                                //no jump
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                    else
                    {
                        if(morganY.intValue <= 208)
                        {
                            //no jump
                        }
                        else
                        {
                            if(wallHeight.intValue <= 150)
                            {
                                pressUp = TRUE;
                            }
                            else
                            {
                                if(morganY.intValue <= 224)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                //no jump
            }
        }
    }
    else
    {
        pressUp = TRUE;
    }
    
    return pressUp;
}

-(BOOL)runRulesFor6GameTest3WithData:(NSDictionary *)data
{
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = FALSE;
    
    //6 Games - 18500 Examples - C=1.0E-8 M=1
    if(morganY.intValue <= 230)
    {
        if(wallX.intValue <= 220)
        {
            //no jump
        }
        else
        {
            if(wallX.intValue <= 238)
            {
                if(wallX.intValue <= 228)
                {
                    if(morganY.intValue <= 116)
                    {
                        //no jump
                    }
                    else
                    {
                        if(wallHeight.intValue <= 131)
                        {
                            if(morganY.intValue <= 189)
                            {
                                if(wallHeight.intValue <= 61)
                                {
                                    pressUp = TRUE;
                                }
                                else
                                {
                                    if(morganY.intValue <= 147)
                                    {
                                        //no jump
                                    }
                                    else
                                    {
                                        if(morganY.intValue <= 173)
                                        {
                                            if(wallHeight.intValue <= 104)
                                            {
                                                pressUp = TRUE;
                                            }
                                            else
                                            {
                                                //no jump
                                            }
                                        }
                                        else
                                        {
                                            if(wallHeight.intValue <= 117)
                                            {
                                                pressUp = TRUE;
                                            }
                                            else
                                            {
                                                //no jump
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                        else
                        {
                            //no jump
                        }
                    }
                }
                else
                {
                    if(wallHeight.intValue <= 137)
                    {
                        if(wallHeight.intValue <= 109)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 192)
                            {
                                //no jump
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                    else
                    {
                        if(morganY.intValue <= 208)
                        {
                            //no jump
                        }
                        else
                        {
                            if(wallHeight.intValue <= 150)
                            {
                                if(morganY.intValue <= 209)
                                {
                                    pressUp = TRUE;
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                            else
                            {
                                if(morganY.intValue <= 224)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                //no jump
            }
        }
    }
    else
    {
        pressUp = TRUE;
    }
    
    return pressUp;
}

#pragma mark - Mined Models
#pragma mark Testing Set 1 With 18500 Examples

-(BOOL)runRulesFor10GameTest1WithData:(NSDictionary *)data
{
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = FALSE;
    
    //6 Games - 18500 Examples - C=1.0E-8 M=1
    if(morganY.intValue <= 230)
    {
        if(wallX.intValue <= 238)
        {
            if(wallX.intValue <= 228)
            {
                if(morganY.intValue <= 176)
                {
                    if(morganY.intValue <= 156)
                    {
                        //no jump
                    }
                    else
                    {
                        if(wallHeight.intValue <= 95)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 164)
                            {
                                //no jump
                            }
                            else
                            {
                                if(wallHeight.intValue <= 102)
                                {
                                    pressUp = TRUE;
                                }
                                else
                                {
                                    //no jump
                                }
                            }
                        }
                    }
                }
                else
                {
                    if(wallHeight.intValue <= 131)
                    {
                        if(wallHeight.intValue <= 113)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 192)
                            {
                                if(wallHeight.intValue <= 122)
                                {
                                    if(morganY.intValue <= 183)
                                    {
                                        //no jump
                                    }
                                    else
                                    {
                                        pressUp = TRUE;
                                    }
                                }
                                else
                                {
                                    //no jump
                                }
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                    else
                    {
                        //no jump
                    }
                }
            }
            else
            {
                if(wallHeight.intValue <= 126)
                {
                    if(morganY.intValue <= 188)
                    {
                        if(wallHeight.intValue <= 104)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(wallHeight.intValue <= 118)
                            {
                                if(morganY.intValue <= 170)
                                {
                                    //no jump
                                }
                                else
                                {
                                    if(wallHeight.intValue <= 110)
                                    {
                                        pressUp = TRUE;
                                    }
                                    else
                                    {
                                        if(morganY.intValue <= 177)
                                        {
                                            //no jump
                                        }
                                        else
                                        {
                                            pressUp = TRUE;
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if(morganY.intValue <= 186)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                        }
                    }
                    else
                    {
                        pressUp = TRUE;
                    }
                }
                else
                {
                    if(morganY.intValue <= 206)
                    {
                        //no jump
                    }
                    else
                    {
                        if(wallHeight.intValue <= 150)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 224)
                            {
                                //no jump
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            //no jump
        }
    }
    else
    {
        pressUp = TRUE;
    }
    
    return pressUp;
}

-(BOOL)runRulesFor10GameTest2WithData:(NSDictionary *)data
{
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = FALSE;
    
    //6 Games - 18500 Examples - C=1.0E-8 M=1
    if(morganY.intValue <= 230)
    {
        if(wallX.intValue <= 238)
        {
            if(wallX.intValue <= 228)
            {
                if(morganY.intValue <= 176)
                {
                    if(wallHeight.intValue <= 110)
                    {
                        if(morganY.intValue <= 156)
                        {
                            //no jump
                        }
                        else
                        {
                            if(wallHeight.intValue <= 95)
                            {
                                pressUp = TRUE;
                            }
                            else
                            {
                                if(morganY.intValue <= 164)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                        }
                    }
                    else
                    {
                        //no jump
                    }
                }
                else
                {
                    if(wallHeight.intValue <= 131)
                    {
                        if(wallHeight.intValue <= 113)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 192)
                            {
                                if(wallHeight.intValue <= 122)
                                {
                                    if(morganY.intValue <= 183)
                                    {
                                        //no jump
                                    }
                                    else
                                    {
                                        pressUp = TRUE;
                                    }
                                }
                                else
                                {
                                    //no jump
                                }
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                    else
                    {
                        //no jump
                    }
                }
            }
            else
            {
                if(wallHeight.intValue <= 126)
                {
                    if(morganY.intValue <= 188)
                    {
                        if(wallHeight.intValue <= 104)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(wallHeight.intValue <= 118)
                            {
                                if(morganY.intValue <= 170)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                            else
                            {
                                if(morganY.intValue <= 186)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                        }
                    }
                    else
                    {
                        pressUp = TRUE;
                    }
                }
                else
                {
                    if(morganY.intValue <= 206)
                    {
                        //no jump
                    }
                    else
                    {
                        if(wallHeight.intValue <= 150)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 224)
                            {
                                //no jump
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            //no jump
        }
    }
    else
    {
        pressUp = TRUE;
    }
    
    return pressUp;
}

-(BOOL)runRulesFor10GameTest3WithData:(NSDictionary *)data
{
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = FALSE;
    
    //6 Games - 18500 Examples - C=1.0E-8 M=1
    if(morganY.intValue <= 230)
    {
        if(wallX.intValue <= 238)
        {
            if(wallX.intValue <= 228)
            {
                if(morganY.intValue <= 176)
                {
                    if(wallHeight.intValue <= 110)
                    {
                        if(morganY.intValue <= 156)
                        {
                            //no jump
                        }
                        else
                        {
                            if(wallHeight.intValue <= 95)
                            {
                                pressUp = TRUE;
                            }
                            else
                            {
                                if(morganY.intValue <= 164)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                        }
                    }
                    else
                    {
                        //no jump
                    }
                }
                else
                {
                    if(wallHeight.intValue <= 131)
                    {
                        if(wallHeight.intValue <= 113)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 192)
                            {
                                if(wallHeight.intValue <= 122)
                                {
                                    if(morganY.intValue <= 183)
                                    {
                                        //no jump
                                    }
                                    else
                                    {
                                        pressUp = TRUE;
                                    }
                                }
                                else
                                {
                                    //no jump
                                }
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                    else
                    {
                        //no jump
                    }
                }
            }
            else
            {
                if(wallHeight.intValue <= 126)
                {
                    if(morganY.intValue <= 188)
                    {
                        if(wallHeight.intValue <= 104)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(wallHeight.intValue <= 118)
                            {
                                if(morganY.intValue <= 170)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                            else
                            {
                                if(morganY.intValue <= 186)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                        }
                    }
                    else
                    {
                        pressUp = TRUE;
                    }
                }
                else
                {
                    if(morganY.intValue <= 206)
                    {
                        //no jump
                    }
                    else
                    {
                        if(wallHeight.intValue <= 150)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 224)
                            {
                                //no jump
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            //no jump
        }
    }
    else
    {
        pressUp = TRUE;
    }
    
    return pressUp;
}

#pragma mark - Mined Models
#pragma mark Testing Set 1 With 18500 Examples
-(BOOL)runRulesForThe250KTestWithData:(NSDictionary *)data
{
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = FALSE;
    
    //6 Games - 250K Examples - C=1.0E-6 M=2
    if(morganY.intValue <= 230)
    {
        if(wallX.intValue <= 238)
        {
            if(wallHeight.intValue <= 137)
            {
                if(morganY.intValue <= 194)
                {
                    if(wallHeight.intValue <= 117)
                    {
                        if(morganY.intValue <= 105)
                        {
                            //no jump
                        }
                        else
                        {
                            if(wallHeight.intValue <= 106)
                            {
                                if(morganY.intValue <= 164)
                                {
                                    if(wallHeight.intValue <= 97)
                                    {
                                        if(morganY.intValue <= 133)
                                        {
                                            if(wallHeight.intValue <= 63)
                                            {
                                                if(morganY.intValue <= 126)
                                                {
                                                    if(wallHeight.intValue <= 56)
                                                    {
                                                        if(morganY.intValue <= 114)
                                                        {
                                                            if(wallHeight.intValue <= 48)
                                                            {
                                                                if(wallHeight.intValue <= 43)
                                                                {
                                                                    pressUp = TRUE;
                                                                }
                                                                else
                                                                {
                                                                    if(morganY.intValue <= 109)
                                                                    {
                                                                        //no jump
                                                                    }
                                                                    else
                                                                    {
                                                                        pressUp = TRUE;
                                                                    }
                                                                }
                                                            }
                                                            else
                                                            {
                                                                //no jump
                                                            }
                                                        }
                                                        else
                                                        {
                                                            if(wallHeight.intValue <= 51)
                                                            {
                                                                pressUp = TRUE;
                                                            }
                                                            else
                                                            {
                                                                if(morganY.intValue <= 118)
                                                                {
                                                                    //no jump
                                                                }
                                                                else
                                                                {
                                                                    pressUp = TRUE;
                                                                }
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        //no jump
                                                    }
                                                }
                                                else
                                                {
                                                    pressUp = TRUE;
                                                }
                                            }
                                            else
                                            {
                                                //no jump
                                            }
                                        }
                                        else
                                        {
                                            if(wallHeight.intValue <= 70)
                                            {
                                                pressUp = TRUE;
                                            }
                                            else
                                            {
                                                if(morganY.intValue <= 158)
                                                {
                                                    if(wallHeight.intValue <= 88)
                                                    {
                                                        if(morganY.intValue <= 149)
                                                        {
                                                            if(wallHeight.intValue <= 81)
                                                            {
                                                                if(morganY.intValue <= 140)
                                                                {
                                                                    //no jump
                                                                }
                                                                else
                                                                {
                                                                    pressUp = TRUE;
                                                                }
                                                            }
                                                            else
                                                            {
                                                                //no jump
                                                            }
                                                        }
                                                        else
                                                        {
                                                            pressUp = TRUE;
                                                        }
                                                    }
                                                    else
                                                    {
                                                        //no jump
                                                    }
                                                }
                                                else
                                                {
                                                    pressUp = TRUE;
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        //no jump
                                    }
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                            else
                            {
                                if(morganY.intValue <= 174)
                                {
                                    //no jump
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                        }
                    }
                    else
                    {
                        if(morganY.intValue <= 185)
                        {
                            //no jump
                        }
                        else
                        {
                            if(wallHeight.intValue <= 126)
                            {
                                pressUp = TRUE;
                            }
                            else
                            {
                                //no jump
                            }
                        }
                    }
                }
                else
                {
                    if(wallHeight.intValue <= 131)
                    {
                        pressUp = TRUE;
                    }
                    else
                    {
                        if(morganY.intValue <= 200)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            //no jump
                        }
                    }
                }
            }
            else
            {
                if(morganY.intValue <= 207)
                {
                    if(morganY.intValue <= 203)
                    {
                        //no jump
                    }
                    else
                    {
                        if(wallHeight.intValue <= 141)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            //no jump
                        }
                    }
                }
                else
                {
                    if(wallHeight.intValue <= 150)
                    {
                        if(wallHeight.intValue <= 145)
                        {
                            pressUp = TRUE;
                        }
                        else
                        {
                            if(morganY.intValue <= 212)
                            {
                                //no jump
                            }
                            else
                            {
                                pressUp = TRUE;
                            }
                        }
                    }
                    else
                    {
                        if(morganY.intValue <= 218)
                        {
                            //no jump
                        }
                        else
                        {
                            if(wallHeight.intValue <= 157)
                            {
                                if(morganY.intValue <= 221)
                                {
                                    if(wallHeight.intValue <= 154)
                                    {
                                        pressUp = TRUE;
                                    }
                                    else
                                    {
                                        //no jump
                                    }
                                }
                                else
                                {
                                    pressUp = TRUE;
                                }
                            }
                            else
                            {
                                if(morganY.intValue <= 223)
                                {
                                    //no jump
                                }
                                else
                                {
                                    if(wallHeight.intValue <= 160)
                                    {
                                        pressUp = TRUE;
                                    }
                                    else
                                    {
                                        if(morganY.intValue <= 227)
                                        {
                                            //no jump
                                        }
                                        else
                                        {
                                            pressUp = TRUE;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        else
        {
            //no jump
        }
    }
    else
    {
        pressUp = TRUE;
    }
    
    return pressUp;
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
