//
//  ProjectionDimension.h
//  MealLibrary
//
//  Created by sebbecai on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DietaryConstraint.h"

@protocol ProjectionDimension <NSObject>
-(int)magnitudeForMeal:(id<Meal>)meal;
-(int)goalMagnitude;
@end

@interface ProjectionDimension : NSObject <ProjectionDimension> {
    id<QuantitativeDietaryConstraint> _constraint;
    float weight;
}

@property float weight;
+(id<ProjectionDimension>)createCaloricWithConstraint:(id<QuantitativeDietaryConstraint>)constraint;
+(NSMutableArray *)createDefaultDimensionsWithCaloricDimension:(id<ProjectionDimension>)constraint;
@end
