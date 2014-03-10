//
//  AppDelegate.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhysicsEngineHeader.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PhysicsLandscapeDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableSet *collidingSets;

@end
