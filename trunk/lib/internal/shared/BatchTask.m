//
//  BatchProcess.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BatchTask.h"

@implementation BatchTask
-(void)start
{
    if (!_started)
    {
        for (id<IndividualTask> subProcess in _tasks) {
            subProcess.taskDelegate = self;
            [subProcess start];
        }
    }
    _started = YES;
}

-(void)cancel
{
    if (_started)
    {
        for (id<IndividualTask> subProcess in _tasks) {
            [subProcess cancel];
        }
    }    
}

-(NSString *) SingleTaskCompleteNotification
{
    return @"BatchProcess_SingleTaskCompleteNotification";
}

+(NSString *)userInfoDataKey
{
    return @"data";
}

-(void)processResultData:(id) data
{
    NSNotification *myNotification = [NSNotification notificationWithName:[self SingleTaskCompleteNotification]
                                                                   object:self 
                                                                 userInfo:[NSDictionary dictionaryWithObject:data forKey:[BatchTask userInfoDataKey]]];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}

#pragma mark Create/Destroy
- (id)initWithProcesses:(NSMutableArray *)subProcesses
{
    self = [super init];
    if (self) {
        _started = NO;
        
        _tasks = subProcesses;
        [_tasks retain];
    }
    
    return self;
}
-(void)dealloc
{
    [_tasks release];
    [super dealloc];
}

+(id<BatchTask>) createWithProcesses:(NSMutableArray *)subProcesses
{
    BatchTask *batch = [[BatchTask alloc] initWithProcesses:subProcesses];
    
    [batch autorelease];
    return batch;
}

@end
