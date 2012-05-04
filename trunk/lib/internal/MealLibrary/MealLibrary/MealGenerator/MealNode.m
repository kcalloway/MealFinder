//
//  MealNode.m
//  MealLibrary
//
//  Created by sebbecai on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MealNode.h"

@implementation MealNode
@dynamic uniqueId;
@synthesize isGoal;
@synthesize isStart;
@synthesize nodeData = _meal;
@synthesize restaurant;

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [[super description] stringByAppendingString:self.uniqueId];
}

-(BOOL)getVector:(int *)vector forLength:(int)vectorLen;
{
    if (isGoal) {
        return [_projection goalVector:vector forLength:vectorLen];
    }
    return [_projection vector:vector forMeal:_meal andLength:vectorLen];
}

#pragma mark GraphNode
-(NSNumber *)heuristicEstimateToNode:(id<GraphNode>)otherNode
{
    int hCost = [[self costToNode:otherNode] intValue];
    if (hCost > 0) {
        hCost = hCost + log((double)hCost);
//        hCost *= 2;
//        hCost *= hCost;
//        hCost = 0;
    }

    return [NSNumber numberWithInt:hCost];
}

-(NSNumber *)costToNode:(id<GraphNode>)otherNode
{
    int len = [_projection vectorLength];
    int myVector[GOAL_MEAL_PROJECTION_VECTORLENGTH];
    int otherVector[GOAL_MEAL_PROJECTION_VECTORLENGTH];
    int magnitude = 0;

    [self getVector:myVector forLength:len];
    [otherNode getVector:otherVector forLength:len];

    for (int i = 0; i < len; i++) {
        myVector[i] = otherVector[i] - myVector[i];
        myVector[i] *=myVector[i];
        magnitude += myVector[i];
    }
    magnitude = sqrt(magnitude);
    return [NSNumber numberWithInt:magnitude];
}

-(NSString *)uniqueId
{
    if (isGoal) {
        return @"Goal";
    }
    else if (isStart) {
        return @"Start";
    }
    return _meal.uniqueId;
}

-(BOOL)isEqualToNode:(id<GraphNode>)otherNode
{
    return [self.uniqueId isEqualToString:otherNode.uniqueId];
}

-(NSArray *)neighborNodes
{
    NSArray *neighborFood;
    BOOL bothSideAndEntree = NO;

    if ([_meal.menuItems count]) {
        id<MenuItem> menuItem = [[_meal menuItems] objectAtIndex:0];
        bothSideAndEntree = (menuItem.isSide && menuItem.isEntree);
    }

    if (_meal.isValidMeal || bothSideAndEntree) {
        neighborFood = _menuItems;
    }
    else {
        neighborFood = _entreeMatches;
    }

    NSMutableArray *nextNodes = [NSMutableArray array];
    id<Meal>      curMeal = nil;
    for (id<MenuItem> menuItem in neighborFood) {
        NSMutableArray *curItems =[NSMutableArray arrayWithArray:_meal.menuItems];
        [curItems addObject:menuItem];
        if (_meal.origin == nil) {
            curMeal = [Meal createWithRestaurant:restaurant andMenuItems:curItems];
        }
        else {
            curMeal = [Meal createWithRestaurant:_meal.origin andMenuItems:curItems];
        }

        if ([_diet allowsMeal:curMeal]) {
            if (isStart) {
                [nextNodes addObject:[MealNode createWithMeal:curMeal andDiet:_diet andMenuItems:_menuItems]];                
            }
            else {
                [nextNodes addObject:[MealNode createWithMeal:curMeal andDiet:_diet andMenuItems:_menuItems andEntreeMatches:_entreeMatches]];
            }
        }
    }
    
    if (_meal.isValidMeal && [nextNodes count] == 0)
    {
        [nextNodes addObject:[MealNode goalNodeForDiet:_diet]];
    }
    return nextNodes;
}

+(id<QuantitativeDietaryConstraint>)boundingConstraintForDiet:(id<Diet>)diet
{
    id<QuantitativeDietaryConstraint> boundingConstraint = nil;
    for (id<QuantitativeDietaryConstraint> constraint in diet.dietaryConstraints) {
        if ([constraint.selectorName isEqualToString:@"kcal"]) {
            boundingConstraint = constraint;
        }
    }

    return boundingConstraint;
}

+(NSArray *)entreeMatchesForAllMenuItems:(NSArray *)menuItems
{
    NSMutableArray *matches = [NSMutableArray array];
    for (id<MenuItem> foodItem in menuItems) {
        if (foodItem.isSide) {
            [matches addObject:foodItem];
        }
        else if (foodItem.isMeal) {
            [matches addObject:foodItem];
        }
    }
    
    return matches;
}

#pragma mark Create/Destroy
-(id)initWithMeal:(id<Meal>)meal andDiet:(id<Diet>)diet andMenuItems:(NSArray *)menuItems andEntreeMatches:(NSArray *)entreeMatches andBoundingConstraint:(id<QuantitativeDietaryConstraint>)constraint andMealProjection:(id<GoalMealProjection>)projection
{
    self = [super init];
    if (self) {
        _meal             = meal;
        _diet             = diet;
        _menuItems        = menuItems;
        _entreeMatches    = entreeMatches;
        caloricConstraint = constraint;
        _projection       = projection;

        [_meal             retain];
        [_diet             retain];
        [_menuItems        retain];
        [_entreeMatches    retain];
        [caloricConstraint retain];
        [_projection       retain];
    }
    return self;
}

-(void)dealloc
{
    [_meal             release];
    [_diet             release];
    [_menuItems        release];
    [_entreeMatches    release];
    [caloricConstraint release];
    [_projection       release];

    [super dealloc];
}

+(id<GraphNode>)startNodeForMenuItems:(NSArray *)menuItems andDiet:(id<Diet>)diet andRestaurant:(id<Restaurant>) restaurant
{
    NSMutableArray *startFood = [NSMutableArray array];
    NSMutableArray *validFood = [NSMutableArray array];
    for (id<MenuItem> food in menuItems) {
        if (food.isEntree || food.isMeal) {
            [startFood addObject:food];
        }
        if (food.isEntree || food.isMeal || food.isSide) {
            [validFood addObject:food];
        }
    }

    MealNode *node = [MealNode createWithMeal:nil andDiet:diet andMenuItems:validFood andEntreeMatches:startFood];
    node.isStart = YES;
    node.restaurant = restaurant;
    return node;
}

+(id<GraphNode>)createWithMeal:(id<Meal>)meal andDiet:(id<Diet>)curDiet andMenuItems:(NSArray *)menuItems andEntreeMatches:(NSArray *)entreeMatches
{
    id<QuantitativeDietaryConstraint> boundingConstraint = [MealNode boundingConstraintForDiet:curDiet];
    
    GoalMealProjection *projection = [GoalMealProjection createWithDiet:curDiet andCaloricConstraint:boundingConstraint];
    MealNode * mealNode = [[MealNode alloc] initWithMeal:meal andDiet:curDiet andMenuItems:menuItems andEntreeMatches:entreeMatches andBoundingConstraint:boundingConstraint andMealProjection:projection];
    [mealNode autorelease];
    return mealNode;
}

+(id<GraphNode>)createWithMeal:(id<Meal>)meal andDiet:(id<Diet>)curDiet andMenuItems:(NSArray *)menuItems
{
    MealNode * mealNode = [MealNode createWithMeal:meal andDiet:curDiet andMenuItems:menuItems andEntreeMatches:[MealNode entreeMatchesForAllMenuItems:menuItems]];
    return mealNode;
}

+(id<GraphNode>)goalNodeForDiet:(id<Diet>)diet 
{
    MealNode *node = [MealNode createWithMeal:nil andDiet:diet andMenuItems:nil andEntreeMatches:nil];
    node.isGoal = YES;
    return node;
}

@end
