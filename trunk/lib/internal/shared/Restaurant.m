//
//  Restaurant.m
//  MealGenerator
//
//  Created by sebbecai on 3/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#define LOCATION_DELTA  1
#import "Restaurant.h"

@interface Restaurant ()
@property (retain, readwrite) NSString *name;
@end

@implementation Restaurant
@synthesize franchises = _franchises;
@synthesize uniqueId;
@synthesize name;

-(int)numLocations
{
    return [_franchises count];
}

-(void)addLocation:(CLLocation *)location
{
    BOOL seenLocation = NO;
    for (CLLocation *knownLoc in _franchises) {
        if ([knownLoc distanceFromLocation:location] < LOCATION_DELTA) {
            seenLocation = YES;
        }
    }
    
    if (!seenLocation) {
        [_franchises addObject:location];
    }
}

#pragma mark Create/Destroy
- (id)initWithId:(NSString *)theId andName:(NSString *) _name andFranchises:(NSMutableArray *) franchises
{
    self = [super init];
    if (self) {
        self.name     = _name;
        self.uniqueId = theId;
        _franchises = franchises;
        [_franchises retain];
    }
    
    return self;
}

-(void)dealloc
{
    [_franchises release];
    [name        release];
    [uniqueId    release];
    [super dealloc];
}

+(id <Restaurant>) createWithId:(NSString *) restaurantName
{
    NSMutableArray *franchises = [NSMutableArray array];
    Restaurant *restaurant = [[Restaurant alloc] initWithId:restaurantName andName:restaurantName andFranchises:franchises];
    [restaurant autorelease];
    
    return restaurant;
}

+(id <Restaurant>) createWithId:(NSString *)myId
                        andName:(NSString *)restaurantName
                  andFranchises:(NSMutableArray *)franchises
{
    Restaurant *restaurant = [[Restaurant alloc] initWithId:myId andName:restaurantName andFranchises:franchises];
    [restaurant autorelease];
    
    return restaurant;

}


@end
