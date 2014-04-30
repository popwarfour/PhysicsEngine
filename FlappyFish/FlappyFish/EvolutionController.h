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

#define NUM_EVOLUTIONS_PER_EPIC 9

#define DELTA_GAP_HEIGHT 0
#define MIN_GAP_HEIGHT 115
#define MAX_GAP_HEIGHT 115

#define EVOLUTION_STATE_RUNNING 0
#define EVOLUTION_STATE_MENU 1



@interface EvolutionController : UIViewController

@property (nonatomic, strong) GameViewController *gameVC;
@property float parentFitness;

@property int currentGapHeight;

@property int currentEnvolution;
@property int currentEpic;

@property (strong, nonatomic) NSMutableArray *rules;

@property int evolutionState;

@property (nonatomic, strong) id parentNeuralModel;
@property (nonatomic, strong) id childNeuralModel;

@property (nonatomic, strong) UIView *menuView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGameViewController:(GameViewController *)gameVC;

@end
