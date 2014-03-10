//
//  PhysicsVector.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhysicsVector : NSObject

@property float width;
@property float height;

-(id)initWithWidth:(float)width andHeight:(float)height;

@end
