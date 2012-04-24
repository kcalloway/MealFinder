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

-(void)getVector
{
}

#pragma mark GraphNode
-(NSNumber *)costToNode:(id<GraphNode>)otherNode
{
}

-(NSString *)uniqueId
{
    return _meal.uniqueId;
}

-(BOOL)isEqualToNode:(id<GraphNode>)otherNode
{
    if (_meal.uniqueId == otherNode.uniqueId) {
        return YES;
    }
    else {
        return [_meal.uniqueId isEqualToString:otherNode.uniqueId];
    }
}

//-(NSNumber *)heuristicEstimateToNode:(id<GraphNode>)otherNode;
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

        curMeal = [Meal createWithRestaurant:_meal.origin andMenuItems:curItems];

        if ([_diet allowsMeal:curMeal]) {
            [nextNodes addObject:[MealNode createWithMeal:curMeal andDiet:_diet andMenuItems:_menuItems andEntreeMatches:_entreeMatches]];            
        }
    }
    
    if (_meal.isValidMeal && [nextNodes count] == 0)
    {
        [nextNodes addObject:[MealNode goalNodeForDiet:_diet]];
    }
    return nextNodes;
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
-(id)initWithMeal:(id<Meal>)meal andDiet:(id<Diet>)diet andMenuItems:(NSArray *)menuItems andEntreeMatches:(NSArray *)entreeMatches
{
    self = [super init];
    if (self) {
        _meal          = meal;
        _diet          = diet;
        _menuItems     = menuItems;
        _entreeMatches = entreeMatches;

        [_meal          retain];
        [_diet          retain];
        [_menuItems     retain];
        [_entreeMatches retain];

    }
    return self;
}

-(void)dealloc
{
    [_meal          release];
    [_diet          release];
    [_menuItems     release];
    [_entreeMatches release];

    [super dealloc];
}

+(id<GraphNode>)createWithMeal:(id<Meal>)meal andDiet:(id<Diet>)curDiet andMenuItems:(NSArray *)menuItems andEntreeMatches:(NSArray *)entreeMatches
{
    MealNode * mealNode = [[MealNode alloc] initWithMeal:meal andDiet:curDiet andMenuItems:menuItems andEntreeMatches:entreeMatches];
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
    return [MealNode createWithMeal:nil andDiet:diet andMenuItems:nil andEntreeMatches:nil];
}

@end
