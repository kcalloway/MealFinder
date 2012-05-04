//
//  GoalMealProjection.m
//  MealLibrary
//
//  Created by sebbecai on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GoalMealProjection.h"

@implementation GoalMealProjection 

// Currently, this tries to optimize only for calories
-(BOOL)vector:(int *)vector forMeal:(id<Meal>)meal andLength:(int)vectorLen
{
    BOOL canReadVector = vectorLen < [self vectorLength];

    if (vectorLen >= GOAL_MEAL_PROJECTION_VECTORLENGTH) {
        for (int i =0; i < GOAL_MEAL_PROJECTION_VECTORLENGTH; i++) {
            vector[i] = [(id<ProjectionDimension>)[_axes objectAtIndex:i] magnitudeForMeal:meal];
        }
    }

    return canReadVector;
}

-(BOOL)goalVector:(int *)vector forLength:(int)vectorLen
{
    BOOL canSetVector = vectorLen <= [self vectorLength];
    if (canSetVector) {
        for (int i =0; i < GOAL_MEAL_PROJECTION_VECTORLENGTH; i++) {
            vector[i] = [(id<ProjectionDimension>)[_axes objectAtIndex:i] goalMagnitude];
        }
    }
    return canSetVector;
}

-(int)vectorLength
{
    return GOAL_MEAL_PROJECTION_VECTORLENGTH;
}

#pragma mark Create/Destroy
-(void) checkCreatePreconditions
{
    if (!_boundingDimension)
	{
        [NSException raise:NSDestinationInvalidException 
                    format:@"A _boundingConstraint MUST be defined for a GoalMealProjection, but we got nil!"];
    }
}
-(id)initWithDiet:(NSArray *)defaultDimensions andBoundingAxis:(id<ProjectionDimension>)dimension
{
    self = [super init];
    
    if (self) {
        _boundingDimension = dimension;
        _axes              = defaultDimensions;
        [_boundingDimension retain];
        [_axes              retain];
    }

    return self;
}

-(void)dealloc
{
    [_boundingDimension release];
    [_axes              release];
    [super dealloc];
}

+(id<GoalMealProjection>)createWithDiet:(id<Diet>)diet andCaloricConstraint:(id<QuantitativeDietaryConstraint>)constraint
{
    id<ProjectionDimension> dimension = [ProjectionDimension createCaloricWithConstraint:constraint];
    if (constraint == nil) {
        dimension = nil;   
    }
    NSArray *defaultDimensions  = [ProjectionDimension createDefaultDimensionsWithCaloricDimension:dimension];
    GoalMealProjection *projection = [[GoalMealProjection alloc] initWithDiet:defaultDimensions andBoundingAxis:dimension];
    [projection checkCreatePreconditions];
    [projection autorelease];
    return projection;
}

@end
