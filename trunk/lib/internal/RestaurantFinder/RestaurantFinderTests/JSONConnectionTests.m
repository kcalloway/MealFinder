//
//  JSONConnectionTests.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSONConnectionTests.h"

@implementation JSONConnectionTests
- (void)setUp
{
    [super setUp];

    testConnection = [JSONConnection alloc];
}

- (void)tearDown
{
    [testConnection release];

    [super tearDown];
}

- (void)test_makeRequest {
    // This test will be written once we have ocmock    
}

- (void)test_makeRequestRunsOnlyOnce {
    // This test will be written once we have ocmock
}

- (void)test_reportsErrorNotification {
    // This test will be written once we have ocmock
}

- (void)test_reportsDownloadedObjectsNotification {
    // This test will be written once we have ocmock
}

- (void)test_appendsNewDataToRest {
    // Setup the test
    NSMutableData *objectData = [NSMutableData data];
    NSMutableData *inputData  = [NSMutableData dataWithData:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    [testConnection initWithRequest:nil 
                      andConnection:nil
                    andReceivedData:objectData
                         andStarted:YES 
                       andCompleted:NO 
                             andURL:nil
                       andConverter:nil];
    
    // Run the test
    [testConnection connection:nil didReceiveData:inputData];
    
    // Check expectations
    STAssertTrue([objectData length] == 4, @"We expected the connection's appended data length to be 4.  We got %d", [objectData length]);
}
@end
