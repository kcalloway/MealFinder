//
//  RestaurantFinder.h
//  RestaurantFinder
//
//  Created by sebbecai on 3/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "JSONObjectConverter.h"
#import "BatchTask.h"
#import "BatchTaskScheduler.h"

@protocol RestaurantFinder <NSObject, BatchTaskDelegate>
-(void)findRestaurantsAtLocation:(CLLocationCoordinate2D)coordinate forDistance:(int)meters;
-(void)cancelAllActiveTasks;
@property (assign) id<BatchTaskDelegate> processDelegate;
@end

@interface RestaurantFinder : NSObject <RestaurantFinder> {
    NSArray                *_supportedRestaurants;
    id<BatchTaskScheduler>  _taskScheduler;
    id<JSONObjectConverter> _jsonConverter;
}

@property (assign) id<BatchTaskDelegate> processDelegate;

#pragma mark Create/Destroy
+(id<RestaurantFinder>)createForRestaurants:(NSArray *)supportedRestaurants;
@end
