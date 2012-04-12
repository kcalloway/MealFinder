//
//  MealCellInfo.m
//  MealFinder
//
//  Created by sebbecai on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MealCellInfo.h"

@implementation MealCellInfo

-(NSString *)title
{
    return [_meal.origin uniqueId];
}

-(NSString *)subtitle
{
    return @"";
}

#pragma Create/Destroy
-(id)initWithMeal:(id<Meal>)meal
{
    self = [super init];
    if (self) {
        _meal = meal;
        [_meal retain];
    }
    
    return self;
}

-(void)dealloc
{
    [_meal release];
    [super dealloc];
}

+(id<MealCellInfo>)createWithMeal:(id<Meal>)meal
{
    MealCellInfo *mealInfo = [[MealCellInfo alloc] init];
    [mealInfo autorelease];
    return mealInfo;
}
@end
