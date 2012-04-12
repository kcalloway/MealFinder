//
//  BatchProcessTests.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BatchProcessTests.h"

@implementation BatchProcessTests 

-(void)notificationCatcher:(NSNotification *)caughtNotification
{
    notificationData = [[caughtNotification userInfo] objectForKey:@"data"];
}

- (void)setUp
{
    [super setUp];
    
    testBatchProcess = [BatchTask createWithProcesses:nil];
    [testBatchProcess retain];
    
    myNotCenter = [NSNotificationCenter defaultCenter];
    [myNotCenter addObserver:self 
                    selector:@selector(notificationCatcher:)
                        name:[testBatchProcess SingleTaskCompleteNotification] 
                      object:testBatchProcess];
}

- (void)tearDown
{
    [testBatchProcess release];
    testBatchProcess = nil;

    [myNotCenter removeObserver:self];
    myNotCenter = nil;

    [super tearDown];
}

- (void)test_startInitiatesProcesses 
{
    //Will implement when we have mock objects
}

- (void)test_cancel 
{
    //Will implement when we have mock objects
}

- (void)test_done
{
    //Will implement when we have mock objects
}


- (void)test_throwsCompletionNotification
{
    NSString *expectedString = @"processedData";
    // Run the test
    [testBatchProcess processResultData:expectedString];
    STAssertTrue([notificationData isEqualToString:expectedString],@"The notification we received contained %@ as the data, but we expected %@!",notificationData, expectedString);
}

@end
