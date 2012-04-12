//
//  BatchTaskScheduler.h
//  RestaurantFinder
//
//  Created by sebbecai on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatchTask.h"

@protocol BatchTaskScheduler <NSObject>
-(void)cancelAllActiveTasks;
-(void)startTask:(id<BatchTask>)batch;
@property (assign) id<BatchTaskDelegate> taskDelegate;
@end

@interface BatchTaskScheduler : NSObject <BatchTaskScheduler> {
    NSMutableArray *_activeTasks;
//    NSMutableArray *_canceledProcesses;
}

@property (assign) id<BatchTaskDelegate> taskDelegate;
//-(void)singleTaskComplete:(NSNotification *)caughtNotification;

+(id<BatchTaskScheduler>)create;
@end
