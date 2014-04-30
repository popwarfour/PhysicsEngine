//
//  ArffFormatter.m
//  FlappyFish
//
//  Created by Jordan Rouille on 4/29/14.
//  Copyright (c) 2014 anders. All rights reserved.
//

#import "ArffFormatter.h"

@implementation ArffFormatter

-(void)convertArrayToArffFormat:(NSMutableArray *)rules forTraining:(BOOL)forTraining
{
    NSMutableString *rulesString = [[NSMutableString alloc] init];
    
    //Create Header
    [self appendNewLine:@"% 1. Title: Hand Made Rules" toMutableString:rulesString];
    [self appendNewLine:@"@RELATION handMadeRules" toMutableString:rulesString];
    [self appendNewLine:@"" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE morganHeight  NUMERIC" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE morganWidth  NUMERIC" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE morganX   NUMERIC" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE morganY  NUMERIC" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE wallHeight   NUMERIC" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE wallWidth   NUMERIC" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE wallX   NUMERIC" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE wallY   NUMERIC" toMutableString:rulesString];
    [self appendNewLine:@"@ATTRIBUTE class        {jump,noJump}" toMutableString:rulesString];
    [self appendNewLine:@"" toMutableString:rulesString];
    
    //Add Datea
    [self appendNewLine:@"@DATA" toMutableString:rulesString];
    [self appendNewLine:@"" toMutableString:rulesString];
    
    for(NSDictionary *data in rules)
    {
        if(forTraining)
        {
            [self appendNewDataLineForTraining:data toMutableString:rulesString];
        }
        else
        {
            [self appendNewDataLine:data toMutableString:rulesString];
        }
    }
    
    NSLog(@"%@", rulesString);
    
}

-(void)appendNewLine:(NSString *)newLine toMutableString:(NSMutableString *)rulesString
{
    [rulesString appendFormat:@"%@\n", newLine];
}

-(void)appendNewDataLine:(NSDictionary *)data toMutableString:(NSMutableString *)rulesString
{
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *morganWidth = @20;
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    NSString *class = [data objectForKey:@"class"];
    
    
    NSString *formattedLine = [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%@", morganHeight.intValue, morganWidth.intValue, morganX.intValue, morganY.intValue, wallHeight.intValue, wallWidth.intValue, wallX.intValue, wallY.intValue, class];
    
    [rulesString appendString:formattedLine];
    [rulesString appendString:@"\n"];
}

-(void)appendNewDataLineForTraining:(NSDictionary *)data toMutableString:(NSMutableString *)rulesString
{
    NSNumber *morganHeight = [data objectForKey:@"morganHeight"];
    NSNumber *morganWidth = @20;
    NSNumber *morganY = [data objectForKey:@"morganY"];
    NSNumber *morganX = [data objectForKey:@"morganX"];
    
    NSNumber *wallHeight = [data objectForKey:@"wallHeight"];
    NSNumber *wallWidth = [data objectForKey:@"wallWidth"];
    NSNumber *wallX = [data objectForKey:@"wallX"];
    NSNumber *wallY = [data objectForKey:@"wallY"];
    
    
    NSString *formattedLine = [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d", morganHeight.intValue, morganWidth.intValue, morganX.intValue, morganY.intValue, wallHeight.intValue, wallWidth.intValue, wallX.intValue, wallY.intValue];
    
    [rulesString appendString:formattedLine];
    [rulesString appendString:@"\n"];
}

-(NSMutableArray *)createTestingDataSetWithMorganDelta:(int)morganDelta andMorganMaxHeight:(int)morganMaxHeight andWallDelta:(int)wallDelta andWallMaxHeight:(int)wallMaxHeight
{
    NSMutableArray *testArray = [[NSMutableArray alloc] init];
    for(int i = 100; i <= morganMaxHeight; i += morganDelta)
    {
        NSNumber *morganHeight = @40;
        NSNumber *morganWidth = @20;
        NSNumber *morganY = [NSNumber numberWithInt:i];
        NSNumber *morganX = [NSNumber numberWithInt:189];
        
        int max = morganMaxHeight - 100;
        int current = i - 100;
        
        float percent = ((float)max / (float)current) * 100;
        
        NSLog(@"Percent %f", floorf(current));
        
        for(int j = wallMaxHeight; j >= 40; j -= wallDelta)
        {
            NSNumber *wallHeight = [NSNumber numberWithInt:j];
            NSNumber *wallWidth = [NSNumber numberWithInt:50];
            
            for(int k = 120; k < 400; k += morganDelta)
            {
                NSNumber *wallX = [NSNumber numberWithInt:k];
                NSNumber *wallY = [NSNumber numberWithInt:(320 - (20 + 5 + 40 + j))];
                
                NSArray *keys = [[NSArray alloc] initWithObjects:@"morganY", @"morganX", @"wallX", @"wallY", @"morganWidth", @"wallHeight", @"morganHeight", @"wallWidth", nil];
                NSArray *objects = [[NSArray alloc] initWithObjects:morganY, morganX, wallX, wallY, morganWidth, wallHeight, morganHeight, wallWidth, nil];
                
                NSDictionary *data = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
                [testArray addObject:data];
            }
        }
    }
    
    return testArray;
}

-(void)createTestingData
{
    NSMutableArray *testArray = [self createTestingDataSetWithMorganDelta:10 andMorganMaxHeight:270 andWallDelta:10 andWallMaxHeight:135];
    
    [self convertArrayToArffFormat:testArray forTraining:TRUE];
}


@end
