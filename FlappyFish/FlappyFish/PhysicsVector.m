//
//  PhysicsVector.m
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "PhysicsVector.h"

@implementation PhysicsVector

-(id)initWithWidth:(float)width andHeight:(float)height
{
    if(self = [super init])
    {
        self.width = width;
        self.height = height;
    }
    return self;
}

@end
