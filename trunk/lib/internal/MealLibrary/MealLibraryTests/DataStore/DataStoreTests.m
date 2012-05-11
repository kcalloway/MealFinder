//
//  DataStoreTests.m
//  MealLibrary
//
//  Created by sebbecai on 3/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DataStoreTests.h"
#import "Restaurant.h"

@implementation DataStoreTests

#ifndef USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void)testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void)setUp
{
    [super setUp];
    
    testDataStore = [DataStore createForTestWithCSV:@"chain_nutrition"];
    [testDataStore retain];
}

- (void)tearDown
{
    [testDataStore release];
    
    testDataStore = nil;
    
    [super tearDown];
}

- (void)test_datastoreFromBundleWorks {
    [testDataStore clearWorkingData];

    // Set expectations
    int expectedEntries = 93;
    
    // Run Test
    [testDataStore replaceStaticApplicationData];
    NSArray *menuItems = [testDataStore getAllMenuItemsForRestaurant:[Restaurant createWithId:@"KFC"] andDiet:[NSArray array]];
    
    // Check results
    STAssertNotNil(menuItems, @"Failed to populate Datastore");
    STAssertTrue([menuItems count] == expectedEntries, @"The datastore was seeded with %d entries, should have been %d", [menuItems count], expectedEntries);
}

- (void)test_seedsDataStore {
    [testDataStore clearWorkingData];

    [testDataStore seedDataStore];

    // Set expectations
    int expectedEntries = 93;

    // Run Test
    NSArray *menuItems = [testDataStore getAllMenuItemsForRestaurant:[Restaurant createWithId:@"KFC"] andDiet:[NSArray array]];
    
    // Check results
    STAssertNotNil(menuItems, @"Failed to populate Datastore");
    STAssertTrue([menuItems count] == expectedEntries, @"The datastore was seeded with %d entries, should have been %d", [menuItems count], expectedEntries);
}

- (void)test_canCreateDataStore {
    STAssertNotNil(testDataStore, @"Failed to create a DataStore");
}

#endif

@end
