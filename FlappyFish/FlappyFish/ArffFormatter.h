//
//  ArffFormatter.h
//  FlappyFish
//
//  Created by Jordan Rouille on 4/29/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArffFormatter : NSObject

-(void)convertArrayToArffFormat:(NSMutableArray *)rules forTraining:(BOOL)forTraining;
-(void)createTestingData;

@end
