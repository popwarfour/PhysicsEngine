//
//  AppDelegate.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/9/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSMutableArray *objects = [self createSnowWithFlaiks:1];
    PhysicsLandscapeViewController *vc = [[PhysicsLandscapeViewController alloc] initWithNibName:@"GravityView" bundle:nil andPhysicsObjects:objects andUpdateInterval:1.0/60.0];
    [vc setPhysicsLandscapeDelegate:self];
    
    self.collidingSets = [[NSMutableSet alloc] init];

    [self.window setRootViewController:vc];
    
    [vc setShouldUpdate:TRUE];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - PhysicsLandscapeViewControllerDelegate Methods
-(void)collisionDidOccurWithPhysicsLandscape:(PhysicsLandscapeViewController *)_landscape andObjects:(NSMutableArray *)_objects
{
    NSArray *firstCollisionsSet = [[_objects firstObject] allObjects];
    PhysicsObject *object1 = [firstCollisionsSet firstObject];
    PhysicsObject *object2 = [firstCollisionsSet lastObject];
    
    //Add Bounce!
    if([object1.objectTag isEqualToString:@"snowflaik"])
    {
        PhysicsVector *newVelocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:object1.velocity.height * -0.9];
        Force *upForce = [[Force alloc] initWithInitialVector:newVelocity andIsVelocity:TRUE andMaxSteps:1 andTag:@"bounce"];
        NSMutableArray *forces = object1.forces;
        [forces addObject:upForce];
    
        [object1 setVelocity:[[PhysicsVector alloc] initWithWidth:0 andHeight:0]];
    }
    if([object2.objectTag isEqualToString:@"snowflaik"])
    {
        PhysicsVector *newVelocity = [[PhysicsVector alloc] initWithWidth:0 andHeight:object2.velocity.height * -0.9];
        Force *upForce = [[Force alloc] initWithInitialVector:newVelocity andIsVelocity:TRUE andMaxSteps:1 andTag:@"bounce"];
        NSMutableArray *forces = object2.forces;
        [forces addObject:upForce];
        
        [object2 setVelocity:[[PhysicsVector alloc] initWithWidth:0 andHeight:0]];
    }
}

@end
