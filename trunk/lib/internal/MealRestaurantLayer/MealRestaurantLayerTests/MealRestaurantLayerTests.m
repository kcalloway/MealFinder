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
    id<FoodDataStore> dataStore = [DataStore createForTest];
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
//    NSArray *annotations = [[caughtNotification userInfo] objectForKey:[MealRestaurantLayer userInfoAnnotationKey]];
}

#pragma mark tests

- (void)test_findAnnotationsForDietLocationsRemoved
{
    // Set up the Test
    id<QuantitativeDietaryConstraint> quantConstraint = [DietaryConstraint createCaloricWithMax:800];
    
    // Run the Test
    [testRestLayer findMealsForDiet:[NSArray arrayWithObject:quantConstraint]];
    NSArray *meals = [testRestLayer getMealCellInfoForUniqueId:@"Denny's"];
    
    quantConstraint.maxValue = 2;
    [testRestLayer findMealsForDiet:[NSArray arrayWithObject:quantConstraint]];
    meals = [testRestLayer getMealCellInfoForUniqueId:@"Denny's"];

    // Check expecations
    STAssertTrue([meals count] == 0, @"We expected 19 meals but got %d",[meals count]);    
}

- (void)test_findAnnotationsForDiet
{
    // Set up the Test
    NSMutableDictionary *dietaryConstraints = [DietaryConstraint namesToConstraints];
    id<QuantitativeDietaryConstraint> quantConstraint = [dietaryConstraints objectForKey:@"Calories"];
    quantConstraint.maxValue = 800;

    // Run the Test
//    [testRestLayer findMealsForDiet:[NSArray arrayWithObject:quantConstraint]];
    [testRestLayer findMealsForDiet:[dietaryConstraints allValues]];
    NSArray *meals = [testRestLayer getMealCellInfoForUniqueId:@"Denny's"];

    // Check expecations
    STAssertTrue([meals count] == 3, @"We expected 19 meals but got %d",[meals count]);    
}

@end
