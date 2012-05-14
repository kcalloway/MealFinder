//
//  MealRestaurantLayer.m
//  MealRestaurantLayer
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MealRestaurantLayer.h"
#import "Restaurant.h"
#import "Meal.h"
#import "StoreAnnotation.h"

@implementation MealRestaurantLayer
@synthesize displayDelegate;

-(NSArray *)getMealCellInfoForUniqueId:(NSString *)uniqueId;
{
    return [[_meals objectForKey:uniqueId] allObjects];
}

-(void)processResultData:(NSArray *)downloadedRestaurants
{
    // Disambiguate downloadedRestaurants
    downloadedRestaurants = [_restaurantDisambiguator disambiguateForRestaurants:downloadedRestaurants];
    NSMutableDictionary *restaurauntDiff = [NSMutableDictionary dictionary];
    
    // Find restaurants in downloadedRestaurants but not in _restaurants
    for (id<Restaurant> shop in downloadedRestaurants) {
        if (![restaurauntDiff objectForKey:shop.uniqueId] && ![_restaurants objectForKey:shop.uniqueId]) {
            [restaurauntDiff setObject:shop forKey:shop.uniqueId];
        }
    }

    // Combine _restaurants with restaurauntDiff, keeping original items in Restaurants (things reference this)
    [_restaurantDisambiguator uniqueifyOriginalRestaurants:_restaurants withInput:downloadedRestaurants];
    
    // Then find meals on restaurauntDiff
    [self findMealsForRestaurants:[restaurauntDiff allValues] andDiet:_diet];  
}

-(NSArray *)storeAnnotationsForMeals:(NSArray *)meals
{
    // We must create a new annotation for each and every meal
    // location that we've discovered
    NSMutableSet *seenStores = [NSMutableSet set];
    NSMutableArray *annotations = [NSMutableArray array];
    for (id<Meal> meal in meals) {
        if (![seenStores containsObject:meal.restaurantId]) {
            for (CLLocation *curLocation in [meal.origin franchises]) {
                [annotations addObject:[StoreAnnotation createWithMeal:meal andCoordinate:curLocation]];
            }
            [seenStores addObject:meal.restaurantId];
        }
    }
    return annotations;
}

-(NSMutableDictionary *)cacheMealsForNewMeals:(NSMutableSet *)meals andLocationId:(NSString *)locationId
{
    NSMutableSet *added, *changed, *removed;
    added   = [NSMutableSet set];
    changed = [NSMutableSet set];
    removed = [NSMutableSet set];
    
    NSMutableSet *previousLocations = [NSMutableSet setWithArray:[_meals allKeys]];
    
    NSMutableSet *locationMeals = [_meals objectForKey:locationId];    
    NSMutableSet *removedMeals = [NSMutableSet setWithSet:locationMeals];
    [removedMeals minusSet:meals];
    NSMutableSet *addedMeals = [NSMutableSet setWithSet:meals];
    [addedMeals minusSet:locationMeals];
    
    if ([removedMeals count]) {
        [self postMealsRemoved:removedMeals forLocationId:locationId];
    }
    if ([addedMeals count]) {
        [self postMealsAdded:addedMeals forLocationId:locationId];
    }

    if (locationMeals) {
        [changed addObject:locationId];
    }
    
    if ([meals count]) {
        if (!locationMeals) {
            locationMeals = [NSMutableSet set];
            [added addObject:locationId];
        }
        [_meals setObject:meals forKey:locationId];
    }

    if ([added count] > 0) {
        NSArray *uniqueRestaurantAnnotations = [self storeAnnotationsForMeals:[meals allObjects]];
        
        [self postLocationAdded:added andAnnotations:uniqueRestaurantAnnotations];
    }
    if ([changed count] > 0) {
        [self postLocationChanged:changed];
    }
    if ([meals count] == 0 && [previousLocations containsObject:locationId]) {
        [removed addObject:locationId];
        [_meals removeObjectForKey:locationId];
        [self postLocationRemoved:removed];
    }
    return nil;
}

-(void)processResultMeals:(NSArray*) mealsArr forLocationId:(NSString *)locationId
{
    NSMutableSet *mealsSet = [NSMutableSet setWithArray:mealsArr];
    [self cacheMealsForNewMeals:mealsSet andLocationId:locationId];
}

+(NSString *)MealAddedNotification
{
    return @"MealAddedNotification";
}

-(void)postMealsAdded:(NSSet *)addedMeals forLocationId:(NSString *)locationId
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:addedMeals forKey:locationId];
    NSNotification *myNotification = [NSNotification notificationWithName:[MealRestaurantLayer MealAddedNotification]
                                                                   object:self 
                                                                 userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}

+(NSString *)MealRemovedNotification
{
    return @"MealRemovedNotification";
}

-(void)postMealsRemoved:(NSSet *)removedMeals forLocationId:(NSString *)locationId
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:removedMeals forKey:locationId];
    NSNotification *myNotification = [NSNotification notificationWithName:[MealRestaurantLayer MealRemovedNotification]
                                                                   object:self 
                                                                 userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}

+(NSString *)LocationChangedNotification
{
    return @"LocationChangedNotification";
}

-(void)postLocationChanged:(NSSet *)restaurantIds
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:restaurantIds forKey:@"LocationIds"];
    NSNotification *myNotification = [NSNotification notificationWithName:[MealRestaurantLayer LocationChangedNotification]
                                                                   object:self 
                                                                 userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}

+(NSString *)LocationAddedNotification
{
    return @"LocationAddedNotification";
}

+(NSString *)userInfoAnnotationKey
{
    return @"LocationAddedNotification";
}

-(void)postLocationAdded:(NSSet *)restaurantIds andAnnotations:(NSArray *)annotations
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:restaurantIds forKey:[MealRestaurantLayer userInfoDataKey]];
    [userInfo setObject:annotations forKey:[MealRestaurantLayer userInfoAnnotationKey]];
    NSNotification *myNotification = [NSNotification notificationWithName:[MealRestaurantLayer LocationAddedNotification]
                                                                   object:self 
                                                                 userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}

+(NSString *)LocationRemovedNotification
{
    return @"LocationRemovedNotification";
}

+(NSString *)userInfoDataKey
{
    return @"LocationIds";
}

-(void)postLocationRemoved:(NSSet *)restaurantIds
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:restaurantIds forKey:@"LocationIds"];
    NSNotification *myNotification = [NSNotification notificationWithName:[MealRestaurantLayer LocationRemovedNotification]
                                                                   object:self 
                                                                 userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}

-(void)cancelDietSearch
{
    [self postLocationRemoved:[NSSet setWithArray:[_meals allKeys]]];
    [_meals removeAllObjects];
    [_mealGenerator cancelAllActiveTasks];    
}

-(void)cancelLocationSearch
{
    [_restaurants removeAllObjects];
    [_restaurantFinder cancelAllActiveTasks];
    [self cancelDietSearch];
}

-(void)findMealsForLocation:(CLLocationCoordinate2D)location andMeters:(int)meters
{
    [_restaurantFinder findRestaurantsAtLocation:location forDistance:meters];
}

-(void)findMealsForRestaurants:(NSArray *)restaurants andDiet:(NSArray *)diet
{
    [_mealGenerator findMealsForRestaurants:restaurants andDiet:diet];
}

-(void)findMealsForDiet:(NSArray *)diet
{
    _runningDietOnlySearch = YES;
    [self findMealsForRestaurants:[_restaurants allValues] andDiet:diet];
}


#pragma mark Create/Destroy
-(id)initWithRestaurantFinder:(id<RestaurantFinder>)restaurantFinder
             andMealGenerator:(id<MealGenerator>)mealGenerator
          andFoundRestaurants:(NSMutableDictionary *)restaurants
                     andMeals:(NSMutableDictionary *)meals
         andDietaryConstaints:(NSMutableArray *)diet 
   andRestaurantDisambiguator:(id<RestaurantDisambiguator>) disambiguator
{
    self = [super init];
    if (self) {
        _restaurantFinder        = restaurantFinder;
        _mealGenerator           = mealGenerator;
        _restaurants             = restaurants;
        _meals                   = meals;
        _diet                    = diet;
        _restaurantDisambiguator = disambiguator;

        [_restaurantFinder        retain];
        [_mealGenerator           retain];
        [_restaurants             retain];
        [_meals                   retain];
        [_diet                    retain];
        [_restaurantDisambiguator retain];
    }
    return self;
}

-(void)dealloc
{
    [_restaurantFinder        release];
    [_mealGenerator           release];
    [_restaurants             release];
    [_meals                   release];
    [_diet                    release];
    [_restaurantDisambiguator release];

    [super dealloc];
}

+(id<MealRestaurantLayer>)create
{
    // Create the Dependencies
    id<MealGenerator> mealGenerator = [MealGenerator create];
    
    NSArray *supportedRestaurants         = [RestaurantDisambiguator supportedRestaurants];
    NSMutableDictionary *meals            = [NSMutableDictionary dictionary];
    NSMutableArray *dietaryConstraints    = [NSMutableArray array];
    NSMutableDictionary *foundRestaurants = [NSMutableDictionary dictionary];

    id<RestaurantFinder> restaurantFinder     = [RestaurantFinder createForRestaurants:supportedRestaurants];
    id<RestaurantDisambiguator> disambiguator = [RestaurantDisambiguator create];
    
    // Create the object
    MealRestaurantLayer *restaurantLayer = [[MealRestaurantLayer alloc] initWithRestaurantFinder:restaurantFinder
                                                                                andMealGenerator:mealGenerator
                                                                             andFoundRestaurants:foundRestaurants
                                                                                        andMeals:meals
                                                                            andDietaryConstaints:dietaryConstraints
                                                                      andRestaurantDisambiguator:disambiguator];
    
    // Set the Delegates
    restaurantFinder.processDelegate = restaurantLayer;
    mealGenerator.taskDelegate       = restaurantLayer;
    
    // AutoRelease the created object
    [restaurantLayer autorelease];
    return restaurantLayer;
}
@end
