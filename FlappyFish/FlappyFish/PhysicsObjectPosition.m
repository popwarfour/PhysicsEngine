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

@end
