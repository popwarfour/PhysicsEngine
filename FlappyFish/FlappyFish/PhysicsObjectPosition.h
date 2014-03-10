//
//  PhysicsObjectPosition.h
//  FlappyFish
//
//  Created by Jordan Rouille on 3/10/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhysicsObjectPosition : NSObject

@property float x;
@property float y;

-(id)initWithX:(float)x andY:(float)y;

@end
