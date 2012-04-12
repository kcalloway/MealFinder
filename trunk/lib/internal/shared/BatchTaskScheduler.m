//
//  BatchTaskScheduler.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BatchTaskScheduler.h"

@implementation BatchTaskScheduler
@synthesize taskDelegate;

-(void)singleTaskComplete:(NSNotification *)caughtNotification
{
    [taskDelegate processResultData:[[caughtNotification userInfo] objectForKey:[BatchTask userInfoDataKey]]];
}

-(void)startTask:(id<BatchTask>)batch
{
    [_activeTasks addObject:batch];
    NSNotificationCenter *myNotCenter = [NSNotificationCenter defaultCenter];
    [myNotCenter addObserver:self 
                    selector:@selector(singleTaskComplete:)
                        name:[batch SingleTaskCompleteNotification] 
                      object:batch];
    [batch start];
}

-(void)cancelTask:(id<BatchTask>)batch
{
    NSNotificationCenter *myNotCenter = [NSNotificationCenter defaultCenter];
    [myNotCenter removeObserver:self 
                           name:[batch SingleTaskCompleteNotification]
                         object:batch];
    [batch cancel];
}

-(void)cancelAllActiveTasks
{
    for (id<BatchTask> batch in _activeTasks) {
        [self cancelTask:batch];
    }
    [_activeTasks removeAllObjects];
}

#pragma mark Create/Destroy
- (id)initWithActiveTasks:(NSMutableArray *)activeTasks
{
    self = [super init];
    if (self) {
        _activeTasks = activeTasks;
        [_activeTasks retain];
    }
    
    return self;
}

+(id<BatchTaskScheduler>)create
{
    BatchTaskScheduler *scheduler = [[BatchTaskScheduler alloc] initWithActiveTasks:[NSMutableArray array]];
    
    [scheduler autorelease];
    return scheduler;
}

-(void) dealloc
{
    [_activeTasks release];
    NSNotificationCenter *myNotCenter = [NSNotificationCenter defaultCenter];
    [myNotCenter removeObserver:self];

    [super dealloc];
}

@end
