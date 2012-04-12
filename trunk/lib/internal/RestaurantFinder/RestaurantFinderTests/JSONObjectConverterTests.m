//
//  JSONObjectConverterTests.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JSONObjectConverterTests.h"
#import "Restaurant.h"

@implementation JSONObjectConverterTests
- (void)setUp
{
    [super setUp];
    
    testConverter = [JSONObjectConverter create];
    [testConverter retain];

    error = nil;
}

- (void)tearDown
{
    [testConverter release];
    testConverter = nil;
    
    [super tearDown];
}

#if USE_APPLICATION_UNIT_TEST
// all code under test is in the iPhone Application

- (void)test_objectsForDataNoResults {
    NSString *noResults = @"{\"html_attributions\" : [],\"results\" : [],\"status\" : \"ZERO_RESULTS\"}";
    NSData   *testData = [NSData dataWithData:[noResults dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Run the Test
    NSArray *result = [testConverter objectsForData:testData error:&error];
    
    // Check expectations
    STAssertNil(error, @"We expected no error, but got %@!",error);
    STAssertTrue([result count] == 0, @"We expected 0 objects from this data source, but got %d instead!", [result count]);
}

- (void)test_objectsForDataMultipleUniqueResults 
{
    // Note that this data was haphazardly created by hand
    NSString *singleRestaurant = @"{\"html_attributions\" : [],\"results\" : [{\"geometry\" : {\"location\" : {\"lat\" : 37.2666310,\"lng\" : -121.940250}},\"icon\" : \"http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png\",\"id\" : \"464010f3d35d5485ebe527746264735c10438e4d\",\"name\" : \"KFC\",\"reference\" : \"CmRZAAAAe-Jw4n5Ie699scOB8iA5LWTNJo_umHLrC_x_oq9RnwVpiXVy0xxEHhB9M73D_APlulLOle_RyoTHclNemEDkNvLGB6yk-j2WXmFHM_8CN6RmDtSWy1Ug3g0LxNI4stMSEhBLRiGXaKW4bYVWWzFRL9EOGhSa21wa-oHm2Ak0LrCOmNjPyFs9uA\",\"types\" : [ \"restaurant\", \"food\", \"establishment\" ],\"vicinity\" : \"3144 South Bascom Avenue, San Jose\"}, {\"geometry\" : {\"location\" : {\"lat\" : 39.2666310,\"lng\" : -124.940250}},\"icon\" : \"http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png\",\"id\" : \"464010f3d35d5485ebe527746264735c10438e4d\",\"name\" : \"Subway\",\"reference\" : \"CmRZAAAAe-Jw4n5Ie699scOB8iA5LWTNJo_umHLrC_x_oq9RnwVpiXVy0xxEHhB9M73D_APlulLOle_RyoTHclNemEDkNvLGB6yk-j2WXmFHM_8CN6RmDtSWy1Ug3g0LxNI4stMSEhBLRiGXaKW4bYVWWzFRL9EOGhSa21wa-oHm2Ak0LrCOmNjPyFs9uA\",\"types\" : [ \"restaurant\", \"food\", \"establishment\" ],\"vicinity\" : \"3144 South Bascom Avenue, San Jose\"}],\"status\" : \"OK\"}";
    NSData  *testData = [NSData dataWithData:[singleRestaurant dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Run the Test
    NSArray *result = [testConverter objectsForData:testData error:&error];
    NSString *name = ((id<Restaurant>)[result objectAtIndex:0]).name;
    NSString *name2 = ((id<Restaurant>)[result objectAtIndex:1]).name;

    // Check expectations
    STAssertNil(error, @"We expected no error, but got %@!",error);
    STAssertTrue([result count] == 2, @"We expect 2 objects from this data source, but got %d instead!", [result count]);
    STAssertTrue([name isEqualToString:@"KFC"], @"We expect KFC to the be name, but get %@", name);
    STAssertTrue([name2 isEqualToString:@"Subway"], @"We expect Subway to the be name, but get %@", name2);
}

- (void)test_objectsForDataMultipleFranchiseResults 
{
    // Note that this data was haphazardly created by hand
    NSString *singleRestaurant = @"{\"html_attributions\" : [],\"results\" : [{\"geometry\" : {\"location\" : {\"lat\" : 37.2666310,\"lng\" : -121.940250}},\"icon\" : \"http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png\",\"id\" : \"464010f3d35d5485ebe527746264735c10438e4d\",\"name\" : \"KFC\",\"reference\" : \"CmRZAAAAe-Jw4n5Ie699scOB8iA5LWTNJo_umHLrC_x_oq9RnwVpiXVy0xxEHhB9M73D_APlulLOle_RyoTHclNemEDkNvLGB6yk-j2WXmFHM_8CN6RmDtSWy1Ug3g0LxNI4stMSEhBLRiGXaKW4bYVWWzFRL9EOGhSa21wa-oHm2Ak0LrCOmNjPyFs9uA\",\"types\" : [ \"restaurant\", \"food\", \"establishment\" ],\"vicinity\" : \"3144 South Bascom Avenue, San Jose\"}, {\"geometry\" : {\"location\" : {\"lat\" : 39.2666310,\"lng\" : -124.940250}},\"icon\" : \"http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png\",\"id\" : \"464010f3d35d5485ebe527746264735c10438e4d\",\"name\" : \"KFC\",\"reference\" : \"CmRZAAAAe-Jw4n5Ie699scOB8iA5LWTNJo_umHLrC_x_oq9RnwVpiXVy0xxEHhB9M73D_APlulLOle_RyoTHclNemEDkNvLGB6yk-j2WXmFHM_8CN6RmDtSWy1Ug3g0LxNI4stMSEhBLRiGXaKW4bYVWWzFRL9EOGhSa21wa-oHm2Ak0LrCOmNjPyFs9uA\",\"types\" : [ \"restaurant\", \"food\", \"establishment\" ],\"vicinity\" : \"3144 South Bascom Avenue, San Jose\"}],\"status\" : \"OK\"}";
    NSData  *testData = [NSData dataWithData:[singleRestaurant dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Run the Test
    NSArray *result = [testConverter objectsForData:testData error:&error];
    NSString *name = ((id<Restaurant>)[result objectAtIndex:0]).name;
    id<Restaurant> store = [result objectAtIndex:0];
    
    // Check expectations
    STAssertNil(error, @"We expected no error, but got %@!",error);
    STAssertTrue([result count] == 1, @"We expect 1 objects from this data source, but got %d instead!", [result count]);
    STAssertTrue([name isEqualToString:@"KFC"], @"We expect KFC to the be name, but get %@", name);
    STAssertTrue([store numLocations] == 2, @"We expected this store to have 2 francise results, but instead got %d", [store numLocations]);
}

- (void)test_objectsForDataOtherErrors {
    NSString *noResults = @"{\"html_attributions\" : [],\"results\" : [],\"status\" : \"INVALID_REQUEST\"}";
    NSData   *testData = [NSData dataWithData:[noResults dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Run the Test
    NSArray *result = [testConverter objectsForData:testData error:&error];
    
    // Check expectations
    STAssertNotNil(error, @"We expected an error, but got None!");
    STAssertTrue([result count] == 0, @"We expected 0 objects from this data source, but got %d instead!", [result count]);
}

- (void)test_objectsForDataSingleRestaurant {
    NSString *singleRestaurant = @"{\"html_attributions\" : [],\"results\" : [{\"geometry\" : {\"location\" : {\"lat\" : 37.2666310,\"lng\" : -121.940250}},\"icon\" : \"http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png\",\"id\" : \"464010f3d35d5485ebe527746264735c10438e4d\",\"name\" : \"KFC\",\"reference\" : \"CmRZAAAAe-Jw4n5Ie699scOB8iA5LWTNJo_umHLrC_x_oq9RnwVpiXVy0xxEHhB9M73D_APlulLOle_RyoTHclNemEDkNvLGB6yk-j2WXmFHM_8CN6RmDtSWy1Ug3g0LxNI4stMSEhBLRiGXaKW4bYVWWzFRL9EOGhSa21wa-oHm2Ak0LrCOmNjPyFs9uA\",\"types\" : [ \"restaurant\", \"food\", \"establishment\" ],\"vicinity\" : \"3144 South Bascom Avenue, San Jose\"}],\"status\" : \"OK\"}";
    NSData  *testData = [NSData dataWithData:[singleRestaurant dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Run the Test
    NSArray *result = [testConverter objectsForData:testData error:&error];
    id<Restaurant> restaurant = [result objectAtIndex:0];
    NSString *name = ((id<Restaurant>)restaurant).name;
    CLLocation *location = [restaurant.franchises objectAtIndex:0];

    // Check expectations
    STAssertNil(error, @"We expected no error, but got %@!",error);
    STAssertTrue([result count] == 1, @"We expect 1 objects from this data source, but got %d instead!", [result count]);
    STAssertTrue([name isEqualToString:@"KFC"], @"We expect KFC to the be name, but get %@", name);
    STAssertTrue(location.coordinate.latitude>37 && location.coordinate.latitude<38, @"");
    STAssertTrue(location.coordinate.latitude<38, @"");
    STAssertTrue(location.coordinate.longitude>-122 && location.coordinate.longitude<-121, @"location at %f is wrong",location.coordinate.longitude);
    
}

- (void)test_objectsForDataNoData {
    NSData  *emptyData = [NSData data];

    // Run the Test
    NSArray *result = [testConverter objectsForData:emptyData error:&error];
    
    // Check expectations
    STAssertTrue([result count] == 0, @"We expect no objects from an empty data source, but got one instead!");
}

- (void)test_canCreateObjectConverter {
    STAssertNotNil(testConverter, @"testConverter was not successfully created.");
}

#endif

@end
