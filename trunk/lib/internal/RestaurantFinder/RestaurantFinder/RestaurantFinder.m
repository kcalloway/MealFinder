//
//  RestaurantFinder.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestaurantFinder.h"
#import "Restaurant.h"
#import "JSONConnection.h"
#import "RestaurantRequest.h"

// 8 miles
#define MILE_IN_METERS    1610
#define DRIVING_DISTANCE  MILE_IN_METERS*8
// 2/3 a mile
#define WALKING_DISTANCE  MILE_IN_METERS*(2/3)

@implementation RestaurantFinder
@synthesize processDelegate;

-(id<JSONConnection>) connectionForCoordinate:(CLLocationCoordinate2D) coordinate 
                                  andDistance:(int)meters
                                andRestaurant:(id<Restaurant>)restaurant
{
    NSString *latitude  = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString *distance  = [NSString stringWithFormat:@"%d",meters];
    id<URLWrapper> wrapper = [RestaurantRequest createWithLatitude:latitude andLongitude:longitude andRadius:distance andHasName:restaurant.name];

    id<JSONConnection> connection = [JSONConnection createWithURL:[wrapper url]];
    return connection;
}

-(void)cancelAllActiveTasks
{
    [_taskScheduler cancelAllActiveTasks];
}

-(void)findRestaurantsAtLocation:(CLLocationCoordinate2D)coordinate forDistance:(int)meters
{
    id<JSONConnection> curConnection;
    NSMutableArray *createdConnections = [NSMutableArray array];

    for (id<Restaurant> restaurant in _supportedRestaurants) {
        curConnection = [self connectionForCoordinate:coordinate andDistance:meters andRestaurant:restaurant];
        [createdConnections addObject:curConnection];
    }

    [self cancelAllActiveTasks];
    [_taskScheduler startTask:[BatchTask createWithProcesses:createdConnections]];
}
-(void)processResultData:(id) data
{
    [processDelegate processResultData:data];
}

#pragma mark Create/Destroy
- (id)initWithSupportedRestaurants:(NSArray *)supportedRestaurants
                  andTaskScheduler:(id<BatchTaskScheduler>)scheduler
{
    self = [super init];
    if (self) {
        _supportedRestaurants = supportedRestaurants;
        _taskScheduler        = scheduler;

        [_supportedRestaurants retain];
        [_taskScheduler        retain];
    }
    
    return self;
}

+(id<RestaurantFinder>)createForRestaurants:(NSArray *)supportedRestaurants
{
    id<BatchTaskScheduler> scheduler = [BatchTaskScheduler create];
    RestaurantFinder      *finder    = [[RestaurantFinder alloc] initWithSupportedRestaurants:supportedRestaurants andTaskScheduler:scheduler];
    scheduler.taskDelegate           = finder;

    [finder autorelease];
    return finder;
}

-(void) dealloc
{
    [_supportedRestaurants release];
    [_taskScheduler        release];
    [super dealloc];
}
@end
