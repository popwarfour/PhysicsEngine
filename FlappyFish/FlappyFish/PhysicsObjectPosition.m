//
//  PhysicsObjectPosition.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "PhysicsObjectPosition.h"

@implementation PhysicsObjectPosition

-(id)initWithX:(float)x andY:(float)y
{
    if(self = [super init])
    {
        self.x = x;
        self.y = y;
    }
    return self;
}
-(CGPoint)roundValueToCGPoint
{
    //X
    int roundedX = roundf(self.x);
    int roundedY = roundf(self.y);
    return CGPointMake(roundedX, roundedY);
}
@end
