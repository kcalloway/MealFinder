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
    return [_meals objectForKey:uniqueId];
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
            [_meals setObject:[NSMutableArray array] forKey:shop.uniqueId];
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

-(NSMutableDictionary *)cacheMealsForNewMeals:(NSArray *)meals
{
//    NSMutableDictionary *mealsByRestaurant = [NSMutableDictionary dictionary];
    NSMutableArray *shopMeals = [NSMutableArray array];
    NSString *prevUniqueId = @"";
    for (id<Meal> meal in meals) {
        if (![prevUniqueId isEqualToString:meal.restaurantId]) {
//            shopMeals = [_meals objectForKey:meal.restaurantId];
            shopMeals = [NSMutableArray array];
//            [_meals objectForKey:meal.restaurantId];
            
            if ([_meals objectForKey:meal.restaurantId]) {
                [self postLocationAdded];
            }
            [_meals setObject:shopMeals forKey:meal.restaurantId];

        }
        [shopMeals addObject:meal];
//        prevUniqueId = meal.restaurantId;
    }
    return nil;
//    return mealsByRestaurant;
}

-(void)processResultMeals:(NSArray *) mealsArr
{
    NSLog(@"processResultMeals.data = %@", mealsArr);
    
    [self cacheMealsForNewMeals:mealsArr];
    NSArray *uniqueRestaurantAnnotations = [self storeAnnotationsForMeals:mealsArr];
    if ([uniqueRestaurantAnnotations count] ){
        NSString *uniqueId = [((id<Meal>)[mealsArr objectAtIndex:0]).origin uniqueId];
        [_meals setObject:mealsArr forKey:uniqueId];
        [displayDelegate addNewRestaurantMeals:[self storeAnnotationsForMeals:mealsArr]];
    }
//    if ([mealsArr count] ){
//        NSString *uniqueId = [((id<Meal>)[mealsArr objectAtIndex:0]).origin uniqueId];
//        [_meals setObject:mealsArr forKey:uniqueId];
//        [displayDelegate addNewRestaurantMeals:[self storeAnnotationsForMeals:mealsArr]];
//    }


//    [_meals addObjectsFromArray:mealsArr];
//    
//    [displayDelegate addNewRestaurantMeals:[self storeAnnotationsForMeals:_meals]];
}

+(NSString *)LocationChangedNotification
{
    return @"LocationChangedNotification";
}

-(void)postLocationChanged
{
    NSNotification *myNotification = [NSNotification notificationWithName:[MealRestaurantLayer LocationChangedNotification]
                                                                   object:self 
                                                                 userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}


+(NSString *)LocationAddedNotification
{
    return @"LocationAddedNotification";
}

-(void)postLocationAdded
{
    NSNotification *myNotification = [NSNotification notificationWithName:[MealRestaurantLayer LocationAddedNotification]
                                                                   object:self 
                                                                 userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}

+(NSString *)LocationRemovedNotification
{
    return @"LocationRemovedNotification";
}

-(void)postLocationRemoved
{
    NSNotification *myNotification = [NSNotification notificationWithName:[MealRestaurantLayer LocationRemovedNotification]
                                                                   object:self 
                                                                 userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
}

-(void)cancelDietSearch
{
    [self postLocationRemoved];
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
