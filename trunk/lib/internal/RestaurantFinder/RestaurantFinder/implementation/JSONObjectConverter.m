//
//  JSONObjectConverter.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JSONObjectConverter.h"
#import <Foundation/NSJSONSerialization.h>
#import "Restaurant.h"
#import <CoreLocation/CoreLocation.h>

@implementation JSONObjectConverter
// This is SUPER PLACES API dependent
-(NSArray *)objectsForData:(NSData *) data error:(NSError **) error
{
    NSMutableArray      *objects       = [NSMutableArray array];
    NSMutableDictionary *seenFrancises = [NSMutableDictionary dictionary];
    NSDictionary        *jsonObject    = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
    NSString            *curName;
    CLLocation          *location;

    NSString *status = [jsonObject objectForKey:@"status"];
    
    if (!*error) {
        if ([status isEqualToString:@"OK"]) {
            NSArray *results = [jsonObject objectForKey:@"results"];
            for (NSDictionary *jsonRestaurant in results) {
                curName = [jsonRestaurant objectForKey:@"name"];

                id<Restaurant> store = [seenFrancises objectForKey:curName];
                if (!store) {
                    store = [Restaurant createWithId:curName];
                    [seenFrancises setObject:store forKey:curName];
                    [objects addObject:store];                    
                }

                // Take care of the coordinates
                NSDictionary *coordinates = [[jsonRestaurant objectForKey:@"geometry"] objectForKey:@"location"];
                NSNumber *latitude, *longitude;
                latitude  = [coordinates objectForKey:@"lat"];
                longitude = [coordinates objectForKey:@"lng"];

                // NOT DEPENDENCY INJECTION... ME NO LIKE.
                location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
                [store addLocation:location];
                [location release];
            }
        }
        else {
            if (![status isEqualToString:@"ZERO_RESULTS"]) {
                NSString *errString = [NSString stringWithFormat:@"The Google Places Api is malfunctioning right now, gives error:%@", status];
                *error = [NSError errorWithDomain:errString code:-1 userInfo:nil];                
            }
        }
    }

    return objects;
}

#pragma mark Create/Destroy
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(id<JSONObjectConverter>)create
{
    JSONObjectConverter *converter = [[JSONObjectConverter alloc] init];
    [converter autorelease];
    return converter;
}
                                 
@end
