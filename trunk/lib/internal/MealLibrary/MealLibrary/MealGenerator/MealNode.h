//
//  MealNode.h
//  MealLibrary
//
//  Created by sebbecai on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphSearch.h"
#import "Meal.h"
#import "Diet.h"
#import "DietaryConstraint.h"

@interface MealNode : NSObject <GraphNode> {
    id<Meal> _meal;
    NSArray  *_menuItems;
    NSArray  *_entreeMatches;
    id<Diet> _diet;
    id<QuantitativeDietaryConstraint> caloricConstraint;
    BOOL isGoal;
    BOOL isStart;
}
@property BOOL isGoal;
@property BOOL isStart;

+(id<GraphNode>)createWithMeal:(id<Meal>)meal andDiet:(id<Diet>)curDiet andMenuItems:(NSArray *)menuItems;
+(id<GraphNode>)goalNodeForDiet:(id<Diet>)diet;
+(id<GraphNode>)startNodeForMenuItems:(NSArray *)menuItems andDiet:(id<Diet>)diet;

@end
