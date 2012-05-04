//
//  ProjectionDimension.m
//  MealLibrary
//
//  Created by sebbecai on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectionDimension.h"
#define DEFAULT_PROJ_MAGNITUDE  1000

@implementation ProjectionDimension
@synthesize weight;

-(int)magnitudeForMeal:(id<Meal>)meal
{
    // Get number as a percentage of the maxValue
    float percent = ((float)[meal.kcal intValue]/(float)_constraint.maxValue);
    
    // Convert percent into a large (1000?) point space
    return percent * [self goalMagnitude];
}

-(int)goalMagnitude
{
   return DEFAULT_PROJ_MAGNITUDE*weight;
}

#pragma mark Create/Destroy
-(void) checkCreatePreconditions
{
    if (!_constraint)
	{
        [NSException raise:NSDestinationInvalidException 
                    format:@"A _boundingConstraint MUST be defined for a ProjectionDimension, but we got nil!"];
    }
    else if (weight < 0)
	{
        [NSException raise:NSDestinationInvalidException 
                    format:@"The weight for a ProjectionDimension must be greater than 0!"];
    }
}

-(id)initWithConstraint:(id<QuantitativeDietaryConstraint>)constraint  andWeight:(float)weighting
{
    self = [super init];
    if (self) {
        _constraint = constraint;
        [_constraint retain];

        weight = weighting;
    }
    return self;
}

-(void)dealloc
{
    [_constraint release];
    [super dealloc];
}

+(id<ProjectionDimension>)createWithConstraint:(id<QuantitativeDietaryConstraint>)constraint andWeight:(float)weighting
{
    ProjectionDimension *dimension = [[ProjectionDimension alloc] initWithConstraint:constraint andWeight:weighting];
    [dimension checkCreatePreconditions];
    [dimension autorelease];
    return dimension;
}

+(id<ProjectionDimension>)createCaloricWithConstraint:(id<QuantitativeDietaryConstraint>)constraint
{
    return [ProjectionDimension createWithConstraint:constraint andWeight:1];
}

+(NSMutableArray *)createDefaultDimensionsWithCaloricDimension:(id<ProjectionDimension>)constraint
{
    return [NSArray arrayWithObject:constraint];
}
@end
