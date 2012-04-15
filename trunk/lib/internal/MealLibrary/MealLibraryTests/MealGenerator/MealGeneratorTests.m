//
//  MealGeneratorTests.m
//  MealGeneratorTests
//
//  Created by sebbecai on 3/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MealGeneratorTests.h"
#import "Restaurant.h"
#import "DietaryConstraint.h"
#import "Meal.h"

@implementation MealGeneratorTests

-(void)processResultMeals:(NSArray*) meals forLocationId:(NSString *)locationId
{
    [resultMeals addObjectsFromArray:meals];
}

- (void)setUp
{
    [super setUp];

    id<FoodDataStore> dataStore = [DataStore createForTest];
    testGenerator = [MealGenerator alloc];
    [testGenerator initWithDataStore:dataStore];
    testGenerator.taskDelegate = self;
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
    STAssertTrue([resultMeals count] == 13, @"We expected 6 meals, but got %d!", [resultMeals count]);
}

-(void)test_findMeals
{
    restaurants = [NSArray arrayWithObject:[Restaurant createWithId:@"KFC"]];
    [testGenerator findMealsForRestaurants:restaurants andDiet:[NSArray array]];

    STAssertNotNil(resultMeals, @"getMeals should always return an array");
    STAssertTrue([resultMeals count] == 23, @"We expected 23 meals, but got %d!", [resultMeals count]);
    id<Meal> meal = [resultMeals objectAtIndex:0];
    STAssertTrue([meal.kcal intValue] == 310, @"we expected 310 but got %d", [meal.kcal intValue]);
    STAssertFalse([meal.isVegetarian boolValue], @"This meal is not Vegetarian!");
    STAssertFalse([meal.isVegan boolValue], @"This meal is not Vegan!");
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
