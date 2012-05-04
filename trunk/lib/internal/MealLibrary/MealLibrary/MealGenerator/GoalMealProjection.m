//
//  GoalMealProjection.m
//  MealLibrary
//
//  Created by sebbecai on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GoalMealProjection.h"

@implementation GoalMealProjection 

// Currently, this tries to maximize only for calories
-(BOOL)vector:(int *)vector forMeal:(id<Meal>)meal andLength:(int)vectorLen
{
    BOOL canReadVector = vectorLen < [self vectorLength];

    // Get number as a percentage of the maxValue
    float percent = ((float)[meal.kcal intValue]/(float)_boundingConstraint.maxValue);

    // Convert percent into 1000 point space
    vector[0] = percent * 1000;
    
    return canReadVector;
}

-(BOOL)goalVector:(int *)vector forLength:(int)vectorLen
{
    BOOL canSetVector = vectorLen <= [self vectorLength];
    if (canSetVector) {
        vector[0] = 1000;
    }
    return canSetVector;
}

-(int)vectorLength
{
    return 1;
}

#pragma mark Create/Destroy
-(void) checkCreatePreconditions
{
    if (!_boundingConstraint)
	{
        [NSException raise:NSDestinationInvalidException 
                    format:@"A _boundingConstraint MUST be defined for a GoalMealProjection, but we got nil!"];
    }
}
-(id)initWithDiet:(id<Diet>)diet andCaloricConstraint:(id<QuantitativeDietaryConstraint>)constraint
{
    self = [super init];
    
    if (self) {
        _diet              = diet;
        _boundingConstraint = constraint;

        [_diet              retain];
        [_boundingConstraint retain];
    }

    return self;
}

-(void)dealloc
{
    [_diet              release];
    [_boundingConstraint release];
    [super dealloc];
}

+(id<GoalMealProjection>)createWithDiet:(id<Diet>)diet andCaloricConstraint:(id<QuantitativeDietaryConstraint>)constraint
{
    GoalMealProjection *projection = [[GoalMealProjection alloc] initWithDiet:diet andCaloricConstraint:constraint];
    [projection checkCreatePreconditions];
    [projection autorelease];
    return projection;
}

@end
