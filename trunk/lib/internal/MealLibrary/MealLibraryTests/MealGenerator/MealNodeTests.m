//
//  MealNodeTests.m
//  MealLibrary
//
//  Created by sebbecai on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MealNodeTests.h"
#import "DietaryConstraint.h"
#import "Meal.h"

@implementation MealNodeTests
BOOL _importedCSV = 0;

- (void)setUp
{
    [super setUp];
    dataStore = [DataStore createForTestWithCSV:@"chain_nutrition"];
    if (!_importedCSV) {
        [dataStore clearWorkingData];
        [dataStore seedDataStore];
        _importedCSV = 1;
    }
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark Tests
-(void)test_costToNode
{
    
}

-(void)test_isEqualToNodeGoal
{
    diet         = [Diet createWithConstraints:[NSMutableArray arrayWithObject:[DietaryConstraint createVegetarian]]];
    testMealNode = [MealNode goalNodeForDiet:diet];
    
    // Check expectations
    STAssertTrue([testMealNode isEqualToNode:testMealNode], @"The two nodes should be equivalent but we think they're different!");
}

-(void)test_isEqualToNodeDifferent
{
    // Set up the test
    id<Meal> meal;
    diet = [Diet createWithConstraints:[NSMutableArray arrayWithObject:[DietaryConstraint createVegetarian]]];
    menuItems = [dataStore getAllMenuItemsForRestaurant:[Restaurant createWithId:@"KFC"] andDiet:[diet dietaryConstraints]];
    
    for (id<MenuItem> food in menuItems) {
        meal = [Meal createWithRestaurant:nil andMenuItems:[NSArray arrayWithObject:food]];
        if (food.isMeal) {
            break;
        }
    }
    testMealNode = [MealNode createWithMeal:meal andDiet:diet andMenuItems:menuItems];
    
    // Run the test
    NSArray *neighbors = [testMealNode neighborNodes];
    
    // Check expectations
    STAssertFalse([testMealNode isEqualToNode:[neighbors objectAtIndex:0]], @"The two nodes should be different but we think they're equivalent!");
}

-(void)test_isEqualToNodeEquivalent
{
    // Set up the test
    id<Meal> meal;
    diet      = [Diet createWithConstraints:[NSMutableArray arrayWithObject:[DietaryConstraint createVegetarian]]];
    menuItems = [dataStore getAllMenuItemsForRestaurant:[Restaurant createWithId:@"KFC"] andDiet:[diet dietaryConstraints]];
    meal      = [Meal createWithRestaurant:nil andMenuItems:[NSArray arrayWithObject:[menuItems objectAtIndex:0]]];
    
    testMealNode = [MealNode createWithMeal:meal andDiet:diet andMenuItems:menuItems];

    // Check expectations
    STAssertTrue([testMealNode isEqualToNode:testMealNode], @"The two nodes should be equivalent but we think they're different!");
}

-(void)test_neighborNodesHasGoal
{
    // Set up the test
    id<Meal> meal;
    diet = [Diet createWithConstraints:[NSMutableArray arrayWithObject:[DietaryConstraint createCaloricWithMax:260]]];
    menuItems = [dataStore getAllMenuItemsForRestaurant:[Restaurant createWithId:@"KFC"] andDiet:[diet dietaryConstraints]];
    
    for (id<MenuItem> food in menuItems) {
        meal = [Meal createWithRestaurant:nil andMenuItems:[NSArray arrayWithObject:food]];
        if (food.isMeal) {
            break;
        }
    }
    testMealNode = [MealNode createWithMeal:meal andDiet:diet andMenuItems:menuItems];
    
    // Run the test
    NSArray *neighbors = [testMealNode neighborNodes];
    
    // Check expectations
    STAssertTrue([neighbors count] == 1, @"We expected 1 neighbors, but got %d", [neighbors count]);
}

-(void)test_neighborNodesFromEntree
{
    // Set up the test
    id<Meal> meal;
    diet = [Diet createWithConstraints:[NSMutableArray arrayWithObject:[DietaryConstraint createVegetarian]]];
    menuItems = [dataStore getAllMenuItemsForRestaurant:[Restaurant createWithId:@"KFC"] andDiet:[diet dietaryConstraints]];
    
    for (id<MenuItem> food in menuItems) {
        meal = [Meal createWithRestaurant:nil andMenuItems:[NSArray arrayWithObject:food]];
        if (food.isMeal) {
            break;
        }
    }
    testMealNode = [MealNode createWithMeal:meal andDiet:diet andMenuItems:menuItems];
    
    // Run the test
    NSArray *neighbors = [testMealNode neighborNodes];
    
    // Check expectations
    STAssertTrue([neighbors count] == 15, @"We expected 15 neighbors, but got %d", [neighbors count]);
}

-(void)test_neighborNodesFromMeal
{
    // Set up the test
    id<Meal> meal;
    diet = [Diet createWithConstraints:[NSMutableArray arrayWithObject:[DietaryConstraint createCaloricWithMax:600]]];
    menuItems = [dataStore getAllMenuItemsForRestaurant:[Restaurant createWithId:@"KFC"] andDiet:[diet dietaryConstraints]];

    for (id<MenuItem> food in menuItems) {
        meal = [Meal createWithRestaurant:nil andMenuItems:[NSArray arrayWithObject:food]];
        if (food.isMeal) {
            break;
        }
    }
    testMealNode = [MealNode createWithMeal:meal andDiet:diet andMenuItems:menuItems];
    
    // Run the test
    NSArray *neighbors = [testMealNode neighborNodes];

//    NSLog(@"%@\n",testMealNode.uniqueId);
//    for (id<GraphNode> node in neighbors) {
//        NSLog(@"neighbornode = %@\n",node.uniqueId);
//    }

    // Check expectations
    STAssertTrue([neighbors count] == 48, @"We expected 48 neighbors, but got %d", [neighbors count]);
}

-(void)test_getUniqueId
{
    // Set up the test
    id<Meal> meal;
    diet      = [Diet createWithConstraints:[NSMutableArray arrayWithObject:[DietaryConstraint createVegetarian]]];
    menuItems = [dataStore getAllMenuItemsForRestaurant:[Restaurant createWithId:@"KFC"] andDiet:[diet dietaryConstraints]];
    meal      = [Meal createWithRestaurant:nil andMenuItems:[NSArray arrayWithObject:[menuItems objectAtIndex:0]]];

    testMealNode = [MealNode createWithMeal:meal andDiet:diet andMenuItems:menuItems];

    // Set expectations
    NSString *expectedString = @"KFC:Caesar Side Salad without Dressing & Croutons";

    // Check expectations
    STAssertTrue([[testMealNode uniqueId] isEqualToString:expectedString], @"uniqueId should have been %@, but was %@", expectedString, [testMealNode uniqueId]);
}

@end
