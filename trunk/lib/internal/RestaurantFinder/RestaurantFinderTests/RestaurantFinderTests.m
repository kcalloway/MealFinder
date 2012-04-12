//
//  RestaurantFinderTests.m
//  RestaurantFinderTests
//
//  Created by sebbecai on 3/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestaurantFinderTests.h"
#import "Restaurant.h"

@implementation RestaurantFinderTests

- (void)setUp
{
    [super setUp];
    Restaurant *kfc = [Restaurant createWithId:@"KFC"];
    testFinder = [RestaurantFinder createForRestaurants:[NSArray arrayWithObject:kfc]];
    [testFinder retain];
}

- (void)tearDown
{
    // Tear-down code here.
    [testFinder release];
    [super tearDown];
}

- (void)testFindRestaurantsAtLocationCreatesConnections
{
//    CLLocationCoordinate2D location;
//    location.latitude  = 37;
//    location.longitude = 121;
//    [testFinder findRestaurantsAtLocation:location forDistance:1500];
}

@end
