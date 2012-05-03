//
//  MealGeneratorTests.m
//  MealGeneratorTests
//
//  Created by sebbecai on 3/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MealGeneratorTests.h"
#import "Restaurant.h"
#import "Diet.h"
#import "DietaryConstraint.h"
#import "Meal.h"

@implementation MealGeneratorTests
BOOL MealGeneratorTestsImportedCSV = 0;

-(void)processResultMeals:(NSArray*) meals forLocationId:(NSString *)locationId
{
    [resultMeals addObjectsFromArray:meals];
}

- (void)setUp
{
    [super setUp];

    id<DataStore> dataStore = [DataStore createForTestWithCSV:@"chain_nutrition"];
    if (!MealGeneratorTestsImportedCSV) {
        [dataStore clearWorkingData];
        [dataStore seedDataStore];
        MealGeneratorTestsImportedCSV = 1;
    }
    testGenerator = [MealGenerator alloc];
    [testGenerator initWithDataStore:dataStore];
    testGenerator.taskDelegate = self;
    
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

-(void)test_findMealsWithUnrecognizedRestaurant
{
    restaurants = [NSArray arrayWithObjects:[Restaurant createWithId:@"FAKEPLACE"], nil];
    [testGenerator findMealsForRestaurants:restaurants andDiet:[NSArray array]];

    STAssertTrue([resultMeals count] == 0, @"Since we don't recognize the Restaurant, we expected 0 results, but got %d!", [resultMeals count]);
}

-(void)test_findMealsUnder500kcal
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    NSArray *diet = [NSArray arrayWithObject:[DietaryConstraint createCaloricWithMax:500]];
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet];
    
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 17, @"We expected 17 meals, but got %d!", [resultMeals count]);
}

//-(void)test_findAndGenerateMealsNoDiet
-(void)test_findAndGenerateMealsUnder6Carbs
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    id<Diet> diet = [Diet createWithConstraints:[NSArray arrayWithObjects:[DietaryConstraint createCarbohydrateWithMax:6], [DietaryConstraint createCaloricWithMax:800], nil]];
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet startingAtIndex:0 endingAtIndex:10];
    
    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 10, @"We expected 10 meals, but got %d!", [resultMeals count]);
    id<Meal> meal = [resultMeals objectAtIndex:0];
    NSLog(@"meal.uniqueid = %@\n", meal.uniqueId);
    STAssertTrue([meal.carbs intValue] < 6, @"we expected 20 but got %d", [meal.carbs intValue]);
    STAssertTrue([meal.restaurantId isEqualToString:@"KFC"],@"The expected restaurantId is KFC, but got %@!",meal.restaurantId);
}

-(void)test_findAndGenerateVegetarianMealsUnder500kcal
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    id<Diet> diet = [Diet createWithConstraints:[NSArray arrayWithObjects:[DietaryConstraint createCaloricWithMax:500], [DietaryConstraint createVegetarian], nil]];
    [testGenerator findMealsForRestaurants:restaurants andDiet:diet startingAtIndex:0 endingAtIndex:1];

    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 1, @"We expected 1 meals, but got %d!", [resultMeals count]);
    id<Meal> meal = [resultMeals objectAtIndex:0];
     NSLog(@"meal.uniqueid = %@\n", meal.uniqueId);
    STAssertTrue([meal.kcal intValue] <= 500, @"we expected 500 but got %d", [meal.kcal intValue]);
    STAssertTrue([meal.restaurantId isEqualToString:@"KFC"],@"The expected restaurantId is KFC, but got %@!",meal.restaurantId);
}

-(void)test_findMealsFailsOnInvalidInput
{
    STAssertThrows([testGenerator findMealsForRestaurants:nil andDiet:[NSArray array]],
                   @"getMealsForRestaurants no longer throws exception on nil");
}

- (void)test_canCreateMealGenerator
{
    STAssertNotNil(testGenerator, @"Failed to create a Meal Generator");
}

@end
