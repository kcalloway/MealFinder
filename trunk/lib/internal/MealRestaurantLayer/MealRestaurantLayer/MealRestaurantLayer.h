//
//  MealRestaurantLayer.h
//  MealRestaurantLayer
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatchTask.h"
#import "RestaurantFinder.h"
#import "MealGenerator.h"
#import "RestaurantDisambiguator.h"

@protocol MealDisplayDelegate <NSObject>
// An array of meal arrays
-(void)addNewRestaurantMeals:(NSArray *)meals;
@end

@protocol MealRestaurantLayer <NSObject, BatchTaskDelegate, MealGeneratorDelegate>
-(void)findMealsForLocation:(CLLocationCoordinate2D)location andMeters:(int)meters;
-(void)findMealsForDiet:(NSArray *)diet;
-(void)cancelLocationSearch;
-(void)cancelDietSearch;
@property (assign) id<MealDisplayDelegate> displayDelegate;

-(NSArray *)getMealCellInfoForUniqueId:(NSString *)uniqueId;
@end

@interface MealRestaurantLayer : NSObject <MealRestaurantLayer> {
    id<RestaurantFinder>        _restaurantFinder;
    id<MealGenerator>           _mealGenerator;
    id<RestaurantDisambiguator> _restaurantDisambiguator;

    NSMutableDictionary *_restaurants;
    NSMutableDictionary *_meals;
    NSMutableArray *_diet;
    
    BOOL            _runningDietOnlySearch;

    id<MealDisplayDelegate> displayDelegate;
}
@property (assign) id<MealDisplayDelegate> displayDelegate;

#pragma mark NotificationStuff
+(NSString *)LocationAddedNotification;
+(NSString *)LocationChangedNotification;
+(NSString *)LocationRemovedNotification;
+(NSString *)userInfoDataKey;
+(NSString *)userInfoAnnotationKey;

#pragma mark Create/Destroy
+(id<MealRestaurantLayer>)create;

-(id)initWithRestaurantFinder:(id<RestaurantFinder>)restaurantFinder
             andMealGenerator:(id<MealGenerator>)mealGenerator
          andFoundRestaurants:(NSMutableDictionary *)restaurants
                     andMeals:(NSMutableDictionary *)meals
         andDietaryConstaints:(NSMutableArray *)diet 
   andRestaurantDisambiguator:(id<RestaurantDisambiguator>) disambiguator;
@end
