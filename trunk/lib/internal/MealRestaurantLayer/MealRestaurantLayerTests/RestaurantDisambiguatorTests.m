//
//  RestaurantDisambiguatorTests.m
//  MealRestaurantLayer
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestaurantDisambiguatorTests.h"
#import "Restaurant.h"


@implementation RestaurantDisambiguatorTests
- (void)setUp
{
    [super setUp];
    
    testDisambiguator = [RestaurantDisambiguator create];

    inputRestaurants    = [NSMutableArray array];
    originalRestaurants = [NSMutableDictionary dictionary];
    
    [testDisambiguator   retain];
    [inputRestaurants    retain];
    [originalRestaurants retain];
}

- (void)tearDown
{
    [testDisambiguator   release];
    [inputRestaurants    release];
    [originalRestaurants release];
    
    [super tearDown];
}

- (void)test_multipleRestaurantsMatchAndDontMatch
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"KFC"]];
    [inputRestaurants addObject:[Restaurant createWithId:@"FAKESTORE"]];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expecations
    STAssertTrue([originalRestaurants count] == 1, @"We expected 1 Restaurant but got %d",[originalRestaurants count]);    
}

- (void)test_multipleRestaurantNamesShouldNotMatch
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"OTHERFAKESTORE"]];
    [inputRestaurants addObject:[Restaurant createWithId:@"FAKESTORE"]];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expecations
    STAssertTrue([originalRestaurants count] == 0, @"We expected 0 Restaurant but got %d",[originalRestaurants count]);
}

- (void)test_multipleRestaurantNamesShouldMatch
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"KFC"]];
    [inputRestaurants addObject:[Restaurant createWithId:@"Taco Bell"]];

    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expecations
    STAssertTrue([originalRestaurants count] == 2, @"We expected 2 Restaurant but got %d",[originalRestaurants count]);    
}

- (void)test_restaurantMatchesAlternateName
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"Kentucky Fried Chicken"]];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expectations
    STAssertTrue([originalRestaurants count] == 1, @"We expected 1 Restaurant but got %d",[originalRestaurants count]);
    NSString *uniqueId = [[originalRestaurants allKeys] objectAtIndex:0];
    STAssertTrue([uniqueId isEqualToString:@"KFC"], @"We expected the string 'KFC' but got %@", uniqueId);
}

- (void)test_restaurantHasDuplicates
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"KFC"]];
    [inputRestaurants addObject:[Restaurant createWithId:@"Kentucky Fried Chicken"]];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expectations
    STAssertTrue([originalRestaurants count] == 1, @"We expected 1 Restaurant but got %d",[originalRestaurants count]);    
}

- (void)test_restaurantHasDuplicatesButMultipleNames
{
    // Set up the Test
    CLLocation *loc1, *loc2;
    loc1 = [[CLLocation alloc] initWithLatitude:100 longitude:100];
    loc2 = [[CLLocation alloc] initWithLatitude:100 longitude:100];
    
    id<Restaurant> rest1 = [Restaurant createWithId:@"KFC"];
    id<Restaurant> rest2 = [Restaurant createWithId:@"Kentucky Fried Chicken"];
    [rest1 addLocation:loc1];
    [rest2 addLocation:loc2];
    [inputRestaurants addObject:rest1];
    [inputRestaurants addObject:rest2];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expectations
    STAssertTrue([originalRestaurants count] == 1, @"We expected 1 Restaurant but got %d",[originalRestaurants count]);
    id<Restaurant> restaurant = [[originalRestaurants allValues] objectAtIndex:0];
    STAssertTrue([restaurant.franchises count] == 1, @"We expected 1 Restaurant but got %d",[restaurant.franchises count]);     
}

- (void)test_restaurantHasMultipleFranchises
{
    // Set up the Test
    CLLocation *loc1, *loc2;
    loc1 = [[CLLocation alloc] initWithLatitude:100 longitude:100];
    loc2 = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    
    id<Restaurant> rest1 = [Restaurant createWithId:@"KFC"];
    id<Restaurant> rest2 = [Restaurant createWithId:@"Kentucky Fried Chicken"];
    [rest1 addLocation:loc1];
    [rest2 addLocation:loc2];
    [inputRestaurants addObject:rest1];
    [inputRestaurants addObject:rest2];

    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expectations
    STAssertTrue([originalRestaurants count] == 1, @"We expected 1 Restaurant but got %d",[originalRestaurants count]);
    id<Restaurant> restaurant = [[originalRestaurants allValues] objectAtIndex:0];
    STAssertTrue([restaurant.franchises count] == 2, @"We expected 2 Restaurant but got %d",[restaurant.franchises count]);     
}

#warning This may be best resolved by some sort of compound Restaurant
- (void)test_mixedRestaurantsMultipleMatches
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"KFC"]];
    [inputRestaurants addObject:[Restaurant createWithId:@"KFC-Taco Bell"]];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expectations
    STAssertTrue([originalRestaurants count] == 2, @"We expected 2 Restaurant but got %d",[originalRestaurants count]);
}

- (void)test_mixedRestaurantsMatch
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"KFC-Taco Bell"]];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expectations
    STAssertTrue([originalRestaurants count] == 1, @"We expected 2 Restaurant but got %d",[originalRestaurants count]);
}

- (void)test_mixedRestaurantNameSharesShopWithUnknownRestaurantName
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"KFC-FAKESTORE"]];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expecations
    STAssertTrue([originalRestaurants count] == 1, @"We expected 1 Restaurant but got %d",[originalRestaurants count]);
}

- (void)test_restaurantNameIsExactMatch
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"KFC"]];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expecations
    STAssertTrue([originalRestaurants count] == 1, @"We expected 1 Restaurant but got %d",[originalRestaurants count]);
}


- (void)test_restaurantNameDoesNotMatch
{
    // Set up the Test
    [inputRestaurants addObject:[Restaurant createWithId:@"FAKESTORE"]];

    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expecations
    STAssertTrue([originalRestaurants count] == 0, @"We expected no Restaurants but got %d",[originalRestaurants count]);

}

- (void)test_noRestaurants
{
    // Set up the Test
    [inputRestaurants removeAllObjects];
    
    // Run the Test
    [testDisambiguator uniqueifyOriginalRestaurants:originalRestaurants withInput:inputRestaurants];
    
    // Check expecations
    STAssertTrue([originalRestaurants count] == 0, @"We expected no Restaurants but got %d",[originalRestaurants count]);
}
@end
