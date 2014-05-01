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
        
        self.currentGameCount = 1;
        
        self.evolutionState = EVOLUTION_STATE_MENU;
        self.gameModeState = GAME_MODE_FREE;
        
        self.currentGapHeight = MAX_GAP_HEIGHT;
        
        self.rules = [[NSMutableArray alloc] init];
        
        self.menuView = [[UIView alloc] initWithFrame:self.view.frame];
        
        UIButton *hideKeyboard = [[UIButton alloc] initWithFrame:self.view.frame];
        [hideKeyboard addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:hideKeyboard];
        
        self.startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.startButton setFrame:CGRectMake(0, 90, (self.view.frame.size.width / 3) * 2, 50)];
        [self.startButton setTitle:@"Start Free Game" forState:UIControlStateNormal];
        [self.startButton addTarget:self action:@selector(startEvolution) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:self.startButton];
        
        UILabel *numGameLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 6) * 3, 90, (self.view.frame.size.width / 6) * 2, 50)];
        [numGameLabel setText:@"Num Games: "];
        [numGameLabel setTextAlignment:NSTextAlignmentRight];
        
        [self.menuView addSubview:numGameLabel];
        
        self.maxGamesTextField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 6) * 5 + 5, 90, (self.view.frame.size.width / 6) * 0.9, 50)];
        [self.maxGamesTextField setKeyboardType:UIKeyboardTypeDecimalPad];
        [self.maxGamesTextField setText:@"5"];
        [self.menuView addSubview:self.maxGamesTextField];
        [self.maxGamesTextField setEnabled:FALSE];
        [self.maxGamesTextField setTextColor:[UIColor grayColor]];
        
        self.gameTypeSegment = [[UISegmentedControl alloc] initWithItems:@[@"Free", @"AI", @"S1 T1", @"S1 T2", @"S1 T3", @"S2 T1", @"S2 T2", @"S2 T3", @"S3 T1"]];
        [self.gameTypeSegment setSelectedSegmentIndex:0];
        [self.gameTypeSegment addTarget:self action:@selector(gameTypeSegmentChanged:) forControlEvents:UIControlEventValueChanged];
        [self.gameTypeSegment setFrame:CGRectMake(2, 130, self.view.frame.size.width, 50)];
        [self.menuView addSubview:self.gameTypeSegment];
        
        self.infoField = [[UILabel alloc] initWithFrame:CGRectMake(50, 185, self.view.frame.size.width - 100, 130)];
        [self.infoField setTextAlignment:NSTextAlignmentCenter];
        [self.infoField setNumberOfLines:0];
        [self.infoField setBackgroundColor:[UIColor lightGrayColor]];
        [self.infoField setText:@"Free games have no AI or mined rules. It lets you play the game. Simply tap the screen and keep morgan freeman from touching the ceiling, floor or walls and get as far as you can!"];
        [self.menuView addSubview:self.infoField];
        
        [self.view addSubview:self.menuView];
        
        //Register CallsBacks
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameDidEnd) name:@"gameDidEnd" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEvolutionWithData:) name:@"checkEvolution" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitGame) name:@"quitGame" object:nil];
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

-(void)hideKeyboard
{
    [self.maxGamesTextField resignFirstResponder];
}

-(void)gameTypeSegmentChanged:(UISegmentedControl *)sender
{
    [self.maxGamesTextField resignFirstResponder];
    
    self.gameModeState = sender.selectedSegmentIndex;
    
    if(sender.selectedSegmentIndex == 0)
    {
        [self.startButton setTitle:@"Start Free Game" forState:UIControlStateNormal];
        
        [self.infoField setText:@"Free games have no AI or mined rules. It lets you play the game. Simply tap the screen and keep morgan freeman from touching the ceiling, floor or walls and get as far as you can!"];
        
        [self.maxGamesTextField setEnabled:FALSE];
        [self.maxGamesTextField setTextColor:[UIColor grayColor]];
    }
    else if(sender.selectedSegmentIndex == 1)
    {
        [self.startButton setTitle:@"Start AI Rules Game" forState:UIControlStateNormal];
        
        [self.infoField setText:@"The Anders AI is designed to be a great FlappyFreeman player but still make random periodic mistakes"];
        
        [self.maxGamesTextField setEnabled:TRUE];
        [self.maxGamesTextField setTextColor:[UIColor blackColor]];
    }
    else
    {
        [self.maxGamesTextField setEnabled:TRUE];
        [self.maxGamesTextField setTextColor:[UIColor blackColor]];
        
        [self.startButton setTitle:@"Start Mined Rules Game" forState:UIControlStateNormal];
        
        if(sender.selectedSegmentIndex == 2)
        {
            [self.infoField setText:@"Set 1 Test 1 contains rules mined from 18500 training instances gathered from 6 games of AI play. The model is a J48 classifier with a min-conf of 1.0E-6 and a min-object of 2. Tree size of 27 with 14 nodes. 96.713% accuracy with three fold test."];
        }
        else if(sender.selectedSegmentIndex == 3)
        {
            [self.infoField setText:@"Set 1 Test 2 contains rules mined from 18500 training instances gathered from 6 games of AI play. The model is a J48 classifier with a min-conf of 1.0E-8 and a min-object of 2. Tree size of 37 with 19 nodes. 96.653% accuracy with three fold test."];
        }
        else if(sender.selectedSegmentIndex == 4)
        {
            [self.infoField setText:@"Set 1 Test 3 contains rules mined from 18500 training instances gathered from 6 games of AI play. The model is a J48 classifier with a min-conf of 1.0E-8 and a min-object of 1. Tree size of 39 with 20 nodes. 96.659% accuracy with three fold test."];
        }
        else if(sender.selectedSegmentIndex == 5)
        {
            [self.infoField setText:@"Set 2 Test 1 contains rules mined from 41500 training instances gathered from 10 games of AI play. The model is a J48 classifier with a min-conf of 1.0E-6 and a min-object of 2. Tree size of 53 with 27 nodes. 97.127% accuracy with three fold test."];
        }
        else if(sender.selectedSegmentIndex == 6)
        {
            [self.infoField setText:@"Set 2 Test 2 contains rules mined from 41500 training instances gathered from 10 games of AI play. The model is a J48 classifier with a min-conf of 1.0E-8 and a min-object of 2. Tree size of 45 with 23 nodes. 96.723% accuracy with three fold test."];
        }
        else if(sender.selectedSegmentIndex == 7)
        {
            [self.infoField setText:@"Set 2 Test 3 contains rules mined from 41500 training instances gathered from 10 games of AI play. The model is a J48 classifier with a min-conf of 1.0E-8 and a min-object of 1. Tree size of 45 with 23 nodes. 96.723% accuracy with three fold test."];
        }
        else if(sender.selectedSegmentIndex == 8)
        {
            [self.infoField setText:@"Set 3 Test 1 contains rules mined from 250000 training instances gathered from over 100 games of AI play. The model is a J48 classifier with a min-conf of 1.0E-6 and a min-object of 2. Tree size of 87 with 44 nodes. 97.973% accuracy with three fold test."];
        }
    }
}

-(void)quitGame
{
    [self.gameVC gameOver];
    [self removeGameView];
    
}

-(void)startEvolution
{
    self.currentGapHeight = MAX_GAP_HEIGHT;
    self.evolutionState = EVOLUTION_STATE_RUNNING;
    self.currentGameCount = 1;
    [self.gameVC.gameCountLabel setText:[NSString stringWithFormat:@"%d", self.currentGameCount]];
    [self.menuView removeFromSuperview];
    
    [self.view addSubview:self.gameVC.view];
    [self.gameVC setWallGap:self.currentGapHeight];
    [self.gameVC backgroundButtonPressed:nil];
}

#pragma mark - Game CallsBacks
-(void)removeGameView
{
    self.currentGameCount = 1;
    [self.gameVC.view removeFromSuperview];
    [self.view addSubview:self.menuView];
}

-(void)gameDidEnd
{
    if(self.gameModeState == GAME_MODE_FREE)
    {
        [self removeGameView];
    }
    else
    {
        //Remove last couple rules because they got us killed!
        for(int i = 0; i < 10; i++)
            [self.rules removeLastObject];
        
        if(self.currentGameCount < self.maxGamesTextField.text.intValue)
        {
            self.currentGameCount++;
            
            [self.gameVC.gameCountLabel setText:[NSString stringWithFormat:@"%d", self.currentGameCount]];

            [self.gameVC startGame];
        }
        else
        {
            //ArffFormatter *formatter = [[ArffFormatter alloc] init];
            //[formatter convertArrayToArffFormat:self.rules forTraining:FALSE];
            
            [self removeGameView];
        }
    }
}


-(void)checkEvolutionWithData:(NSNotification *)notification
{
    NSDictionary *data = [notification object];
    
    
    BOOL pressUp = FALSE;
    
    if(self.gameModeState == GAME_MODE_FREE)
    {
        //nothing in free mode...
    }
    else if(self.gameModeState == GAME_MODE_AI)
    {
        pressUp = [self ruleRulesForAI:data];
    }
    else if(self.gameModeState == GAME_MODE_MINED_SET_1_TEST_1)
    {
        pressUp = [self runRulesFor6GameTest1WithData:data];
    }
    else if(self.gameModeState == GAME_MODE_MINED_SET_1_TEST_2)
    {
        pressUp = [self runRulesFor6GameTest2WithData:data];
    }
    else if(self.gameModeState == GAME_MODE_MINED_SET_1_TEST_3)
    {
        pressUp = [self runRulesFor6GameTest3WithData:data];
    }
    else if(self.gameModeState == GAME_MODE_MINED_SET_2_TEST_1)
    {
        pressUp = [self runRulesFor10GameTest1WithData:data];
    }
    else if(self.gameModeState == GAME_MODE_MINED_SET_2_TEST_2)
    {
        pressUp = [self runRulesFor10GameTest2WithData:data];
    }
    else if(self.gameModeState == GAME_MODE_MINED_SET_2_TEST_3)
    {
        pressUp = [self runRulesFor10GameTest3WithData:data];
    }
    else if(self.gameModeState == GAME_MODE_MINED_SET_3_TEST_1)
    {
        pressUp = [self runRulesForThe250KTestWithData:data];
    }
    
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    if(pressUp == TRUE && self.gameModeState != GAME_MODE_FREE)
    {
        NSArray *newKeys = [[NSArray alloc] initWithObjects:@"morganY", @"morganX", @"morganHeight", @"morganWidth", @"wallX", @"wallY", @"wallWidth", @"wallHeight", @"class", nil];
        NSArray *newObjects = [[NSArray alloc] initWithObjects:morganY, morganX, morganHeight, @20, wallX, wallY, wallWidth, wallHeight, @"jump", nil];
        NSDictionary *newData = [[NSDictionary alloc] initWithObjects:newObjects forKeys:newKeys];
        
        [self.rules addObject:newData];
        [self.gameVC backgroundButtonPressed:nil];
    }
    else if(pressUp == FALSE && self.gameModeState != GAME_MODE_FREE)
    {
        NSArray *newKeys = [[NSArray alloc] initWithObjects:@"morganY", @"morganX", @"morganHeight", @"morganWidth", @"wallX", @"wallY", @"wallWidth", @"wallHeight", @"class", nil];
        NSArray *newObjects = [[NSArray alloc] initWithObjects:morganY, morganX, morganHeight, @20, wallX, wallY, wallWidth, wallHeight, @"noJump", nil];
        NSDictionary *newData = [[NSDictionary alloc] initWithObjects:newObjects forKeys:newKeys];
        
        [self.rules addObject:newData];
    }
}

#pragma mark - AI Model

-(BOOL)ruleRulesForAI:(NSDictionary *)data
{
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    
    BOOL pressUp = FALSE;
    
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
    
    if((morganX.intValue > (wallX.intValue - wallWidth.intValue)) && (morganX.intValue < (wallX.intValue + (wallWidth.intValue * 2))))
    {
        if(morganBottom + 10 >= wallHeight.intValue + self.currentGapHeight)
        {
            pressUp = TRUE;
        }
    }
    
    return pressUp;
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

#pragma mark Testing Set 1 With 45000 Examples

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

#pragma mark Testing Set 1 With 250000 Examples
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
