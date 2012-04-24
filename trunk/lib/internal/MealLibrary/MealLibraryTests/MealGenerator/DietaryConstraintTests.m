//
//  DietaryConstraintTests.m
//  MealLibrary
//
//  Created by sebbecai on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DietaryConstraintTests.h"
#import "DietaryConstraint.h"
#import "Meal.h"

@implementation DietaryConstraintTests
BOOL importedCSV = 0;

-(void)processResultMeals:(NSArray*) meals forLocationId:(NSString *)locationId
{
    [resultMeals addObjectsFromArray:meals];
}

- (void)setUp
{
    [super setUp];
    

    id<DataStore> dataStore = [DataStore createForTestWithCSV:@"meals_only_nutrition"];
    testGenerator = [MealGenerator alloc];
    [testGenerator initWithDataStore:dataStore];
    testGenerator.taskDelegate = self;
    if (!importedCSV) {
        [dataStore clearWorkingData];
        [dataStore seedDataStore];
        importedCSV = 1;
    }
    [testGenerator retain];
    
    resultMeals = [NSMutableArray array];
    [resultMeals retain];
}

- (void)tearDown
{
    [testGenerator release];
    [resultMeals   release];
    
    testGenerator = nil;
    resultMeals   = nil;
    restaurants   = nil;
    
    [super tearDown];
}

#pragma mark Tests
-(void)test_DietaryConstraintAllowsMealShouldPass
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"Denny's"]];
    
    NSMutableDictionary *dietaryConstraints = [DietaryConstraint namesToConstraints];
    id<QuantitativeDietaryConstraint> quantConstraint = [dietaryConstraints objectForKey:@"Sodium"];
    quantConstraint.maxValue = 10000;
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:[dietaryConstraints allValues]];
    
    // Check Expectations
    id<Meal> meal = [resultMeals objectAtIndex:0];
    for (id<DietaryConstraint> constraint in [dietaryConstraints allValues]) {
        STAssertTrue([constraint allowsMeal:meal], @"The Dietary constraint  for %@ should allow the meal, but does not!", [constraint selectorName]);        
    }
}

-(void)test_findMealsCompoundDietConfigurationControllerInput
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"Denny's"]];

    NSMutableDictionary *dietaryConstraints = [DietaryConstraint namesToConstraints];
    id<QuantitativeDietaryConstraint> quantConstraint = [dietaryConstraints objectForKey:@"Sodium"];
    quantConstraint.maxValue = 10000;

    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:[dietaryConstraints allValues]];
    
    // Check Expectations
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 26, @"We expected 26 meals, but got %d!", [resultMeals count]);
}

-(void)test_findMealsCompoundDietQualitativeEnabledDisabled
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"Denny's"]];
    NSMutableArray *diet = [NSMutableArray arrayWithObject:[DietaryConstraint createVegetarian]];
    id<QualitativeDietaryConstraint> veganConstraint = [DietaryConstraint createVegan];
    veganConstraint.enabled = NO;
    [diet addObject:veganConstraint];
    
    NSString *expectedName = @"Banana Pecan Pancake Breakfast";
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 6, @"We expected 6 meal, but got %d!", [resultMeals count]);
    id<Meal> meal = [resultMeals objectAtIndex:0];
    id<MenuItem> food = [meal.menuItems objectAtIndex:0];
    STAssertTrue([food.name isEqualToString:expectedName], @"We expected the food to be %@, but got %@", expectedName, food.name);
}

-(void)test_findMealsDisabledDietDoesNotFilter
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"Denny's"]];
    id<QualitativeDietaryConstraint> vegan = [DietaryConstraint createVegan];
    vegan.enabled = NO;
    NSArray *diet = [NSArray arrayWithObject:vegan];

    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 33, @"We expected 33 meals, but got %d!", [resultMeals count]);
}

-(void)test_findMealsCompoundDietQuantitativeAndQualitative
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"Denny's"]];
    NSDictionary   *allConstraints = [DietaryConstraint namesToConstraints];
    id<QualitativeDietaryConstraint> vegetarian = [allConstraints objectForKey:@"Vegetarian"];
    vegetarian.enabled = YES;
//    NSMutableArray *diet = [NSMutableArray arrayWithObject:vegetarian];
//    [diet addObjectsFromArray:[allConstraints allValues]];

    NSString *expectedName = @"Harvest Oatmeal Breakfast";
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:[allConstraints allValues]];
    
    // Check Expectations
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 3, @"We expected 3 meal, but got %d!", [resultMeals count]);
    id<Meal> meal = [resultMeals objectAtIndex:0];
    id<MenuItem> food = [meal.menuItems objectAtIndex:0];
    STAssertTrue([food.name isEqualToString:expectedName], @"We expected the food to be %@, but got %@", expectedName, food.name);
}

-(void)test_findMealsCompoundDietUnder20carbs1880Sodium
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    NSDictionary *quantitativeConstraints = [DietaryConstraint namesToConstraints];
    ((id<QuantitativeDietaryConstraint>)[quantitativeConstraints objectForKey:@"Carbs"]).maxValue = 20;
    ((id<QuantitativeDietaryConstraint>)[quantitativeConstraints objectForKey:@"Sodium"]).maxValue = 1880;

    NSArray *diet = [quantitativeConstraints allValues];

    NSString *expectedName = @"Double Down with OR Filet ";
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    id<Meal> meal = [resultMeals objectAtIndex:0];
    id<MenuItem> food = [meal.menuItems objectAtIndex:0];
    STAssertTrue([resultMeals count] == 1, @"We expected 1 meal, but got %d!", [resultMeals count]);
    STAssertTrue([food.name isEqualToString:expectedName], @"We expected the food to be %@, but got %@", expectedName, food.name);
}

-(void)test_findMealsUnder500kcal
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    NSArray *diet = [NSArray arrayWithObject:[DietaryConstraint createCaloricWithMax:500]];

    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 13, @"We expected 13 meals, but got %d!", [resultMeals count]);
}

-(void)test_findMealsUnder20carbs
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    NSArray *diet = [NSArray arrayWithObject:[DietaryConstraint createCarbohydrateWithMax:20]];
    NSString *expectedName = @"Double Down with OR Filet ";
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    id<Meal> meal = [resultMeals objectAtIndex:0];
    id<MenuItem> food = [meal.menuItems objectAtIndex:0];

    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 1, @"We expected 1 meal, but got %d!", [resultMeals count]);
    STAssertTrue([food.name isEqualToString:expectedName], @"We expected the food to be %@, but got %@", expectedName, food.name);
}

-(void)test_findMealsUnder500mgSodium
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    NSArray *diet = [NSArray arrayWithObject:[DietaryConstraint createSodiumWithMax:500]];
    NSString *expectedName = @"KFC Snackerﾨ, Honey BBQ";
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    id<Meal> meal = [resultMeals objectAtIndex:0];
    id<MenuItem> food = [meal.menuItems objectAtIndex:0];

    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 1, @"We expected 1 meals, but got %d!", [resultMeals count]);
    STAssertTrue([food.name isEqualToString:expectedName], @"We expected the food to be %@, but got %@", expectedName, food.name);
}

-(void)test_findMealsUnder30mgCholesterol
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    NSArray *diet = [NSArray arrayWithObject:[DietaryConstraint createCholesterolWithMax:30]];
    NSString *expectedName = @"KFC Snackerﾨ with Crispy Strip without Sauce";
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    id<Meal> meal = [resultMeals objectAtIndex:0];
    id<MenuItem> food = [meal.menuItems objectAtIndex:0];

    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 4, @"We expected 4 meals, but got %d!", [resultMeals count]);
    STAssertTrue([food.name isEqualToString:expectedName], @"We expected the food to be %@, but got %@", expectedName, food.name);
}

-(void)test_findMealsVegetarian
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"Denny's"]];
    NSArray *diet = [NSArray arrayWithObject:[DietaryConstraint createVegetarian]];
    NSString *expectedName = @"Banana Pecan Pancake Breakfast";
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    id<Meal> meal = [resultMeals objectAtIndex:0];
    id<MenuItem> food = [meal.menuItems objectAtIndex:0];
    
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 6, @"We expected 6 meals, but got %d!", [resultMeals count]);
    STAssertTrue([food.name isEqualToString:expectedName], @"We expected the food to be %@, but got %@", expectedName, food.name);
}

-(void)test_findMealsVegan
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"Denny's"]];
    NSArray *diet = [NSArray arrayWithObject:[DietaryConstraint createVegan]];
    NSString *expectedName = @"Harvest Oatmeal Breakfast";
    
    // Run Test
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    // Check Expectations
    id<Meal> meal = [resultMeals objectAtIndex:0];
    id<MenuItem> food = [meal.menuItems objectAtIndex:0];
    
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 2, @"We expected 6 meals, but got %d!", [resultMeals count]);
    STAssertTrue([food.name isEqualToString:expectedName], @"We expected the food to be %@, but got %@", expectedName, food.name);
    id<DietaryConstraint> veganConstraint = [diet objectAtIndex:0];
    STAssertTrue([veganConstraint allowsMeal:meal], @"The Dietary constraint should allow the meal, but does not!");
}

@end
