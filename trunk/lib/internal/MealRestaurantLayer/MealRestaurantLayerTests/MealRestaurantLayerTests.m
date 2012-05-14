//
//  MealRestaurantLayerTests.m
//  MealRestaurantLayerTests
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MealRestaurantLayerTests.h"
#import "DietaryConstraint.h"

@implementation MealRestaurantLayerTests

- (void)setUp
{
    [super setUp];
    
    NSNotificationCenter *myNotCenter = [NSNotificationCenter defaultCenter];
    [myNotCenter addObserver:self 
                    selector:@selector(locationAdded:)
                        name:[MealRestaurantLayer LocationAddedNotification] 
                      object:nil];
    
    testRestLayer = [MealRestaurantLayer alloc];

    // Create the Dependencies
    id<DataStore> dataStore = [DataStore createForTestWithCSV:@"test_meals_only_nutrition"];
    [dataStore clearWorkingData];
    [dataStore seedDataStore];

    MealGenerator *mealGenerator = [MealGenerator alloc];
    [mealGenerator initWithDataStore:dataStore];
    
    NSArray *supportedRestaurants         = [RestaurantDisambiguator supportedRestaurants];
    NSMutableDictionary *meals            = [NSMutableDictionary dictionary];
    NSMutableArray *dietaryConstraints    = [NSMutableArray array];
    
    NSMutableDictionary *foundRestaurants = [NSMutableDictionary dictionaryWithObject:[Restaurant createWithId:@"Denny's"] forKey:@"Denny's"];

    
    id<RestaurantFinder> restaurantFinder     = [RestaurantFinder createForRestaurants:supportedRestaurants];
    id<RestaurantDisambiguator> disambiguator = [RestaurantDisambiguator create];
    [testRestLayer initWithRestaurantFinder:restaurantFinder
                           andMealGenerator:mealGenerator
                        andFoundRestaurants:foundRestaurants
                                   andMeals:meals
                       andDietaryConstaints:dietaryConstraints
                 andRestaurantDisambiguator:disambiguator];
    mealGenerator.taskDelegate       = testRestLayer;

    // Set-up code here.
    [myNotCenter addObserver:self 
                    selector:@selector(mealAdded:)
                        name:[MealRestaurantLayer MealAddedNotification] 
                      object:nil];
    [myNotCenter addObserver:self 
                    selector:@selector(mealRemoved:)
                        name:[MealRestaurantLayer MealRemovedNotification] 
                      object:nil];
}

- (void)tearDown
{
    // Tear-down code here.
    [testRestLayer release];
    NSNotificationCenter *myNotCenter = [NSNotificationCenter defaultCenter];
    [myNotCenter removeObserver:self];
    [super tearDown];
}

-(void)locationAdded:(NSNotification *)caughtNotification
{
    locationIds = [[caughtNotification userInfo] objectForKey:[MealRestaurantLayer userInfoDataKey]];
    [locationIds retain];
}

-(void)mealAdded:(NSNotification *)caughtNotification
{
    addedMeals = [[caughtNotification userInfo] objectForKey:curLocationId];
    [addedMeals retain];
}

-(void)mealRemoved:(NSNotification *)caughtNotification
{
    removedMeals = [[caughtNotification userInfo] objectForKey:curLocationId];
    [removedMeals retain];
}

#pragma mark tests

- (void)test_mealsRemoved
{
    // Set up the Test
    id<QuantitativeDietaryConstraint> quantConstraint = [DietaryConstraint createCaloricWithMax:800];
    curLocationId = @"Denny's";
    int expectedAdded   = 19;
    int expectedRemoved = 19;
    
    // Run the Test
    [testRestLayer findMealsForDiet:[NSArray arrayWithObject:quantConstraint]];
    NSArray *meals = [testRestLayer getMealCellInfoForUniqueId:@"Denny's"];
    
    quantConstraint.maxValue = 2;
    [testRestLayer findMealsForDiet:[NSArray arrayWithObject:quantConstraint]];
    meals = [testRestLayer getMealCellInfoForUniqueId:@"Denny's"];
    
    // Check expecations
    STAssertTrue([addedMeals count]   == expectedAdded, @"We should have added %d meals but added %d", expectedAdded, [addedMeals count]);    
    STAssertTrue([removedMeals count] == expectedRemoved, @"We should have removed %d meals but got %d",expectedRemoved, [removedMeals count]);    
}

- (void)test_mealsAdded
{
    // Set up the Test
    id<QuantitativeDietaryConstraint> quantConstraint = [DietaryConstraint createCaloricWithMax:800];
    curLocationId = @"Denny's";
    int expectedAdded   = 19;
    int expectedRemoved = 0;

    // Run the Test
    [testRestLayer findMealsForDiet:[NSArray arrayWithObject:quantConstraint]];

    // Check expecations
    STAssertTrue([addedMeals count]   == expectedAdded, @"We should have added %d meals but added %d", expectedAdded, [addedMeals count]);    
    STAssertTrue([removedMeals count] == expectedRemoved, @"We should have removed %d meals but got %d",expectedRemoved, [removedMeals count]);    
}

- (void)test_findAnnotationsForDietLocationsRemoved
{
    // Set up the Test
    id<QuantitativeDietaryConstraint> quantConstraint = [DietaryConstraint createCaloricWithMax:800];
    curLocationId = @"Denny's";

    // Run the Test
    [testRestLayer findMealsForDiet:[NSArray arrayWithObject:quantConstraint]];
    NSArray *meals = [testRestLayer getMealCellInfoForUniqueId:@"Denny's"];
    
    quantConstraint.maxValue = 2;
    [testRestLayer findMealsForDiet:[NSArray arrayWithObject:quantConstraint]];
    meals = [testRestLayer getMealCellInfoForUniqueId:@"Denny's"];

    // Check expecations
    STAssertTrue([meals count] == 0, @"We expected 0 meals but got %d",[meals count]);    
}

- (void)test_findAnnotationsForDiet
{
    // Set up the Test
    NSMutableDictionary *dietaryConstraints = [DietaryConstraint namesToConstraints];
    id<QuantitativeDietaryConstraint> quantConstraint = [dietaryConstraints objectForKey:@"Calories"];
    quantConstraint.maxValue = 800;

    // Run the Test
    curLocationId = @"Denny's";
    [testRestLayer findMealsForDiet:[dietaryConstraints allValues]];
    NSArray *meals = [testRestLayer getMealCellInfoForUniqueId:@"Denny's"];

    // Check expecations
    STAssertTrue([meals count] == 3, @"We expected 3 meals but got %d",[meals count]);    
    STAssertTrue([locationIds count] == 1, @"We expected 1 meals but got %d",[locationIds count]);    

}

@end
