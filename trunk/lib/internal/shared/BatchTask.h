//
//  BatchProcess.h
//  RestaurantFinder
//
//  Created by sebbecai on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BatchTaskDelegate <NSObject>
-(void)processResultData:(id) data;
@end

@protocol IndividualTask <NSObject>
// Note:In current implementation may only be called 
// once per object lifecyle!
-(void)start;
-(BOOL)done;
-(void)cancel;

@property (assign) id<BatchTaskDelegate> taskDelegate;
@end

@protocol BatchTask <NSObject, BatchTaskDelegate>
//-(BOOL)running;
//-(BOOL)done;
-(void)start;
-(void)cancel;

// When a subprocess completes, the batch
// process posts a notification with
// 1. NotificationName
// 2. The BatchProcess itself (so you know the data's origin)
// 3. Any data resulting from the process (using key='data')
-(NSString *) SingleTaskCompleteNotification;
@end

@interface BatchTask : NSObject <BatchTask> {
    NSMutableArray *_tasks;
    BOOL            _started;
}

+(NSString *)userInfoDataKey;
// Takes an array of IndividualPorcesses as input
+(id<BatchTask>) createWithProcesses:(NSMutableArray *)subProcesses;

@end
