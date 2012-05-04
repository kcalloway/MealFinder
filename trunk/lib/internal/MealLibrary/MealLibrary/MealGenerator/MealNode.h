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
#import "GoalMealProjection.h"

@interface MealNode : NSObject <GraphNode> {
    id<Meal> _meal;
    NSArray  *_menuItems;
    NSArray  *_entreeMatches;
    id<Diet> _diet;
    id<QuantitativeDietaryConstraint> caloricConstraint;
    id<GoalMealProjection> _projection;

    id<Restaurant> restaurant;
    BOOL isGoal;
    BOOL isStart;
}
@property (retain) id<Restaurant> restaurant;
@property BOOL isGoal;
@property BOOL isStart;

+(id<GraphNode>)createWithMeal:(id<Meal>)meal andDiet:(id<Diet>)curDiet andMenuItems:(NSArray *)menuItems;
+(id<GraphNode>)goalNodeForDiet:(id<Diet>)diet;
+(id<GraphNode>)startNodeForMenuItems:(NSArray *)menuItems andDiet:(id<Diet>)diet andRestaurant:(id<Restaurant>) restaurant;
@end
