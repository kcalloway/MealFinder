//
//  GoalMealProjection.h
//  MealLibrary
//
//  Created by sebbecai on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectionDimension.h"
#import "DietaryConstraint.h"
#import "Diet.h"

// For use if the user wants to create the vector statically
#define GOAL_MEAL_PROJECTION_VECTORLENGTH     1
@protocol GoalMealProjection <NSObject>
-(BOOL)vector:(int *)vector forMeal:(id<Meal>)meal andLength:(int)vectorLen;
-(BOOL)goalVector:(int *)vector forLength:(int)vectorLen;
-(int)vectorLength;
@end

/** 
 * Represents the projection of the optimum
 * meal into a point in N-dimensional space

 * Each dimension represents an axis on which
 * we'd like to optimise. Meal Generation 
 * searches for the meal whose values are 
 * closest to the the goal point in this space
 **/
@interface GoalMealProjection : NSObject <GoalMealProjection> {
    NSArray                 *_axes;
    id<ProjectionDimension> _boundingDimension;
}

+(id<GoalMealProjection>)createWithDiet:(id<Diet>)diet andCaloricConstraint:(id<QuantitativeDietaryConstraint>)constraint;
@end
