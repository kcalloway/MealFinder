//
//  RestaurantRequestTests.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestaurantRequestTests.h"

@implementation RestaurantRequestTests
- (void)setUp
{
    [super setUp];

    testRequest = [RestaurantRequest createWithLatitude:@"37.262" 
                                           andLongitude:@"-121.924" 
                                              andRadius:@"1500"
                                              andApiKey:@"AIzaSyBGSUuH2mhoD-zAUYb23D44kmSTpR038i0" 
                                               andIsGPS:YES 
                                             andHasName:@"KFC"];

    [testRequest retain];
}

- (void)tearDown
{
    [testRequest release];    
    testRequest = nil;

    [super tearDown];
}

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application
- (void)test_getURLWorks {
    // Set Expectations
    NSString *expectedURL = @"https://maps.googleapis.com/maps/api/place/search/json?types=food&name=KFC&key=AIzaSyBGSUuH2mhoD-zAUYb23D44kmSTpR038i0&location=37.262,-121.924&sensor=true&radius=1500";

    // Run test
    NSString *resultUrl = [[testRequest url] absoluteString];

    STAssertTrue([resultUrl isEqualToString:expectedURL], @"We expected the following url string %@, but got %@ instead!", expectedURL, resultUrl);
}

- (void)test_getURL_SpaceURLEncoding {
    // Setup the test
    [testRequest release];
    testRequest = [RestaurantRequest createWithLatitude:@"37.262" 
                                           andLongitude:@"-121.924" 
                                              andRadius:@"1500"
                                              andApiKey:@"AIzaSyBGSUuH2mhoD-zAUYb23D44kmSTpR038i0" 
                                               andIsGPS:YES 
                                             andHasName:@"Burger King"];
    [testRequest retain];
    
    // Set Expectations
    NSString *expectedURL = @"https://maps.googleapis.com/maps/api/place/search/json?types=food&name=Burger+King&key=AIzaSyBGSUuH2mhoD-zAUYb23D44kmSTpR038i0&location=37.262,-121.924&sensor=true&radius=1500";
    
    // Run test
    NSString *resultUrl = [[testRequest url] absoluteString];
    
    STAssertTrue([resultUrl isEqualToString:expectedURL], @"We expected the following url string %@, but got %@ instead!", expectedURL, resultUrl);
}

// This test is necessary because there's a bug in the ios 
// encoding framework that doesn't encode & andother various
// Characters
- (void)test_getURL_AmpersandURLEncoding {
    // Setup the test
    [testRequest release];
    testRequest = [RestaurantRequest createWithLatitude:@"37.262" 
                                           andLongitude:@"-121.924" 
                                              andRadius:@"1500"
                                              andApiKey:@"AIzaSyBGSUuH2mhoD-zAUYb23D44kmSTpR038i0" 
                                               andIsGPS:YES 
                                             andHasName:@"B&J's Burgers"];
    [testRequest retain];
    
    // Set Expectations
    NSString *expectedURL = @"https://maps.googleapis.com/maps/api/place/search/json?types=food&name=B%26J%27s+Burgers&key=AIzaSyBGSUuH2mhoD-zAUYb23D44kmSTpR038i0&location=37.262,-121.924&sensor=true&radius=1500";
    
    // Run test
    NSString *resultUrl = [[testRequest url] absoluteString];
    
    STAssertTrue([resultUrl isEqualToString:expectedURL], @"We expected the following url string %@, but got %@ instead!", expectedURL, resultUrl);
}

- (void)test_canCreateRestaurantRequest {
    STAssertNotNil(testRequest, @"testRequest was not successfully created.");
}

#endif

@end
