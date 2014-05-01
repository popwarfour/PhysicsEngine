//
//  EvolutionController.h
//  FlappyFish
//
//  Created by Jordan Rouille on 4/28/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "ArffFormatter.h"

#define NUM_EVOLUTIONS_PER_EPIC 50

#define DELTA_GAP_HEIGHT 0
#define MIN_GAP_HEIGHT 115
#define MAX_GAP_HEIGHT 115

#define EVOLUTION_STATE_RUNNING 0
#define EVOLUTION_STATE_MENU 1

#define GAME_MODE_FREE 0

#define GAME_MODE_AI 1

#define GAME_MODE_MINED_SET_1_TEST_1 2
#define GAME_MODE_MINED_SET_1_TEST_2 3
#define GAME_MODE_MINED_SET_1_TEST_3 4

#define GAME_MODE_MINED_SET_2_TEST_1 5
#define GAME_MODE_MINED_SET_2_TEST_2 6
#define GAME_MODE_MINED_SET_2_TEST_3 7

#define GAME_MODE_MINED_SET_3_TEST_1 8




@interface EvolutionController : UIViewController

@property (nonatomic, strong) GameViewController *gameVC;

@property int currentGapHeight;

@property (strong, nonatomic) NSMutableArray *rules;

@property int evolutionState;
@property int gameModeState;

@property int currentGameCount;

@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UISegmentedControl *gameTypeSegment;
@property (nonatomic, strong) UITextField *maxGamesTextField;
@property (nonatomic, strong) UILabel *infoField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGameViewController:(GameViewController *)gameVC;

@end
