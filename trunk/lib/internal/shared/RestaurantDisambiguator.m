//
//  RestaurantDisambiguator.m
//  MealRestaurantLayer
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestaurantDisambiguator.h"
#import "Restaurant.h"

@implementation RestaurantDisambiguator
#pragma mark Restaurant Meta-info
+(NSDictionary *)restaurantAliases
{
    NSMutableDictionary *aliases = [NSMutableDictionary dictionary];
    [aliases setObject:@"KFC" forKey:@"Kentucky Fried Chicken"];
    [aliases setObject:@"KFC" forKey:@"KFC"];

    [aliases setObject:@"Denny's"    forKey:@"Denny's"];
    [aliases setObject:@"Pizza Hut"  forKey:@"Pizza Hut"];
    [aliases setObject:@"Subway"     forKey:@"Subway"];
    [aliases setObject:@"McDonalds" forKey:@"McDonald's"];

    return aliases;
}

+(NSSet *)allUniqueIds
{
    NSMutableSet *uniqueIds = [NSMutableSet setWithObject:@"KFC"];
    [uniqueIds addObject:@"Denny's"];
    [uniqueIds addObject:@"Pizza Hut"];
    [uniqueIds addObject:@"Subway"];
    [uniqueIds addObject:@"McDonalds"];

    return uniqueIds;
}


+(NSArray *)supportedRestaurants
{
    NSMutableArray *supportedRestaurants = [NSMutableArray array];
    [supportedRestaurants addObject:[Restaurant createWithId:@"KFC"]];
    [supportedRestaurants addObject:[Restaurant createWithId:@"Denny's"]];
    [supportedRestaurants addObject:[Restaurant createWithId:@"Pizza Hut"]];
    [supportedRestaurants addObject:[Restaurant createWithId:@"Subway"]];
    [supportedRestaurants addObject:[Restaurant createWithId:@"McDonald's"]];

    return supportedRestaurants;
}

#pragma mark Disambiguation heavy lifting
-(NSString *)uniqueIdForName:(NSString *)inputName
{
    NSString *uniqueId = nil;
    
    if ([_uniqueIds containsObject:inputName]) {
        uniqueId = inputName;
    }
    else if ([_aliases objectForKey:inputName]) {
        uniqueId = [_aliases objectForKey:inputName];
    }
    else {
        for (NSString *key in _aliases) {
            if ([inputName rangeOfString:key].location != NSNotFound) {
                uniqueId = [_aliases objectForKey:key];
                break;
            }
        }
    }
    
    return uniqueId;
}

-(BOOL)isSupportedRestaurant:(id<Restaurant>)shop
{
    if ([self uniqueIdForName:shop.name]) {
        return YES;
    }

    return NO;
}

-(BOOL)disambiguateRestaurant:(id<Restaurant>)shop
{
    NSString *curUniqueId;
    BOOL success = NO;
    curUniqueId = [self uniqueIdForName:shop.name];
    
    if (curUniqueId) {
        if (![curUniqueId isEqualToString:shop.uniqueId]) {
            [shop setUniqueId:curUniqueId]; 
        }
        success = YES;
    }
    return success;
}

-(void)uniqueifyOriginalRestaurants:(NSMutableDictionary *)originals withInput:(NSArray *)input
{
    NSMutableArray *acceptableRestaurants = [self disambiguateForRestaurants:input];
    for (id<Restaurant> shop in acceptableRestaurants) {
        id<Restaurant> originalShop = [originals objectForKey:shop.uniqueId];
        if (originalShop) {
            for (CLLocation *location in shop.franchises) {
                [originalShop addLocation:location];
            }
        }
        else {
            [originals setObject:shop forKey:shop.uniqueId];
        }
    }
}

-(NSMutableArray *)disambiguateForRestaurants:(NSArray *)toDisambiguate
{
    NSMutableArray *results = [NSMutableArray array];
    
    for (id<Restaurant> shop in toDisambiguate) {
        if ([self disambiguateRestaurant:shop]) {
            [results addObject:shop];
        }
    }
    
    return results;
}

#pragma mark Create/Destroy
-(id)initWithUniqueIds:(NSSet *)uniqueIds andAliases:(NSDictionary *)aliases
{
    self = [super init];
    if (self) {
        _uniqueIds = uniqueIds;
        _aliases   = aliases;
        
        [_aliases   retain];
        [_uniqueIds retain];
    }
    
    return self;
}

-(void)dealloc
{
    [_uniqueIds release];
    [_aliases   release];
    [super dealloc];
}

+(id<RestaurantDisambiguator>)create
{
    NSSet *uniqueIds = [RestaurantDisambiguator allUniqueIds];
    RestaurantDisambiguator *disambiguator = [[RestaurantDisambiguator alloc] initWithUniqueIds:uniqueIds andAliases:[RestaurantDisambiguator restaurantAliases]];
    [disambiguator autorelease];
    return disambiguator;
}

@end
